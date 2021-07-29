import 'dart:io';

import 'package:dio/dio.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swspider/network/http.dart';
import 'package:swspider/utils/toast_util.dart';
import 'package:xpath_parse/xpath_selector.dart';

const HOME_URL = 'http://www.shxsw.com.cn';

class HomePage extends StatefulWidget {
  static const String routeName = 'HomePage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String tag = '_HomePageState';

  // 文件保存地址
  String? _savePath;

  var excel = Excel.createExcel();

  // 结果数据
  Map<String, List<String>> _result = {};

  bool _running = false;

  // 日志数据
  List<String> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('水文信息采集'),
        actions: [
          IconButton(
            onPressed: () {
              if (_savePath != null) {
                if (File(_savePath!).existsSync()) {
                  Share.shareFiles([_savePath!], text: '水情信息数据');
                } else {
                  ToastUtil.show('文件不存在，请先进行数据采集。');
                }
              }
            },
            icon: Icon(Icons.share),
            tooltip: '转发文件',
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Text('点击开始按钮，进行数据采集。'),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemBuilder: (c, i) => Text(_items[i]),
                    itemCount: _items.length,
                  ),
          ),
          SafeArea(
            child: Container(
              child: ElevatedButton(
                  onPressed: _running ? null : _start,
                  child: Text(_running ? '运行中' : '开始')),
              margin: EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  /// 1. 获取首页中的模块地址
  /// 2. 并发请求多个模块中的所有页数据。
  void _start() async {
    await _initPath();
    setState(() {
      _running = true;
      _items.clear();
      _items.add('开始解析...');
    });
    // 解析主要模块地址
    try {
      List<String> urls = await _getResourceUrls();
      setState(() {
        _items.add('解析模块地址成功：');
        for (var value in urls) {
          _items.add(HOME_URL + value);
        }
        _items.add('解析总页数：');
      });
      // 获取各模块数据总页数
      List data = await Future.wait(
          List.generate(urls.length, (index) => _getAllTableData(urls[index])));
      // 存入表格
      data.forEach((element) async {
        await _save2Excel(element.first, element.last);
      });
    } catch (e) {
      print(e);
      setState(() {
        _running = false;
        _items.add('数据采集失败。');
      });
    }
    print('采集结束');
    setState(() {
      _running = false;
      _items.add('数据采集完成。');
      _items.add('文件存储路径：\n$_savePath');
    });
    ToastUtil.show('数据采集完成。');
  }

  /// 获取资源地址
  /// [/water/21052619M6gAf, /reservoir/21052619kKXHT]
  Future<List<String>> _getResourceUrls() async {
    Response response = await XHttp.instance.get(HOME_URL);
    if (response.statusCode == 200) {
      String html = response.data;
      List<String> result = XPath.source(html)
          .query('//*[@class="main3-2-dl"]/dl/dd/a/@href')
          .list();
      List<String> titles = XPath.source(html)
          .query('//*[@class="main3-2-dl"]/dl/dd/a/text()')
          .list();
      for (var value in titles) {
        _result[value] = [];
      }
      return result;
    }
    return [];
  }

  /// 获取总页数
  Future<int> _getTotalPages(String resourceUrl) async {
    Response response = await XHttp.instance.get('$HOME_URL$resourceUrl');
    if (response.statusCode == 200) {
      String html = response.data;
      String result = XPath.source(html)
          .query('//*[@class="pagination"]/li[last()]/a/text()')
          .get();
      print('$result');
      return int.parse(result);
    }
    return 1;
  }

  Future<List> _getTablePageData(String resourceUrl, int pageIndex) async {
    Response response = await XHttp.instance
        .get('$HOME_URL$resourceUrl', queryParameters: {'page': pageIndex});
    if (response.statusCode == 200) {
      String html = response.data;
      String title = XPath.source(html)
          .query('//*[@class="erji-title"]/*[@class="fl"]/text()')
          .get();
      List<List<String>> result = [];
      List<String> data = XPath.source(html)
          .query(
              '//*[@class="table table-bordered table-striped"]/tbody/tr/text()')
          .list();
      data.forEach((element) {
        var list = element.split('\n');
        var newList = list.map((e) => e.trim()).toList();
        result.add(newList);
      });
      return [title, result];
    }
    return [];
  }

  Future<List> _getAllTableData(String resourceUrl) async {
    int count = await _getTotalPages(resourceUrl);
    setState(() {
      _items.add('$resourceUrl: $count');
      _items.addAll(
          List.generate(count, (index) => '$resourceUrl?page=${index + 1}'));
    });
    List data = await Future.wait(List.generate(
        count, (index) => _getTablePageData(resourceUrl, index + 1)));
    String title = '';
    List<List> items = [];
    for (int i = 0; i < data.length; i++) {
      if (i == 0) {
        title = data[i].first;
      }
      for (int a = 0; a < data[i].last.length; a++) {
        if (i == 0 || a != 0) {
          items.add(data[i].last[a]);
        }
      }
    }
    return [title, items];
  }

  /// 保存在excel
  /// [ignoreFirstLineData] 是否忽略第一行数据，第一行数据是表格的头
  Future _save2Excel(String sheetName, List<List> tableData) async {
    if (Platform.isAndroid) {
      Sheet sheetObject = excel[sheetName];
      for (int i = 0; i < tableData.length; i++) {
        sheetObject.appendRow(tableData[i]);
      }
      var fileBytes = excel.save();
      if (fileBytes != null && _savePath != null) {
        File(_savePath!)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        print('save success');
        print(_savePath);
      }
    }
  }

  Future _initPath() async {
    if (Platform.isAndroid) {
      var directory = await getExternalStorageDirectory();
      _savePath = "${directory!.path}/sw_info.xlsx";
      if (File(_savePath!).existsSync()) {
        await File(_savePath!).delete();
      }
    }
  }
}
