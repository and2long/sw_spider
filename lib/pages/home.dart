import 'dart:io';

import 'package:dio/dio.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
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

  bool _running = false;

  // 日志数据
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _initPath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('水文信息采集'),
        actions: !_running &&
                _savePath != null &&
                File(_savePath!).existsSync() &&
                Platform.isAndroid
            ? [
                IconButton(
                  onPressed: () => OpenFile.open(_savePath!),
                  icon: Icon(Icons.open_in_new),
                  tooltip: '打开文件',
                ),
                IconButton(
                  onPressed: _shareFile,
                  icon: Icon(Icons.share),
                  tooltip: '转发文件',
                )
              ]
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Text(
              '文件存储路径：\n$_savePath',
            ),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Text('点击开始按钮，进行数据采集。'),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  void _shareFile() {
    if (_savePath != null) {
      if (File(_savePath!).existsSync()) {
        Share.shareFiles([_savePath!], text: '水情信息数据');
      } else {
        ToastUtil.show('文件不存在，请先进行数据采集。');
      }
    }
  }

  /// 1. 获取首页中的模块地址
  /// 2. 并发请求多个模块中的所有页数据。
  void _start() async {
    if (kReleaseMode && _savePath == null) {
      ToastUtil.show('存储路径初始化失败，不支持该平台。');
      return;
    }
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
      // 获取各模块数据
      await Future.wait(
          List.generate(urls.length, (index) => _getModelData(urls[index])));
      _saveExcel();
      setState(() {
        _running = false;
        _items.add('数据采集完成。');
      });
      ToastUtil.show('数据采集完成。');
    } catch (e) {
      print('main process error:$e');
      setState(() {
        _running = false;
        _items.add('数据采集失败。');
      });
      ToastUtil.show('出现异常，数据采集失败。');
    }
  }

  void _saveExcel() async {
    excel.delete('Sheet1');
    var fileBytes = excel.save();
    if (fileBytes != null && _savePath != null) {
      if (File(_savePath!).existsSync()) {
        await File(_savePath!).delete();
      }
      File(_savePath!)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      print('save success');
    }
  }

  /// 获取资源地址
  /// [/water/21052619M6gAf, /reservoir/21052619kKXHT]
  Future<List<String>> _getResourceUrls() async {
    List<String> result = [];
    Response response = await XHttp.instance.get(HOME_URL);
    if (response.statusCode == 200) {
      String html = response.data;
      List<String> urls = XPath.source(html)
          .query('//*[@class="main3-2-dl"]/dl/dd/a/@href')
          .list();
      result.addAll(urls);
    }
    if (result.isNotEmpty) {
      // 雨水信息
      Response r1 = await XHttp.instance.get('$HOME_URL${result.first}');
      if (r1.statusCode == 200) {
        result = XPath.source(r1.data)
            .query('//*[@class="menu fl"]//li/a/@href')
            .list();
      }
    }
    return result;
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

  Future<List> _getTableData(String resourceUrl, int pageIndex) async {
    try {
      Response response =
          await XHttp.instance.get('$HOME_URL$resourceUrl?page=$pageIndex');
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
    } on DioError catch (e) {
      setState(() {
        _items.add(
            'error:${e.response?.statusCode} ${e.response?.requestOptions.path.replaceAll(HOME_URL, '')}');
      });
    } catch (e) {
      print('_getTableData error:$e');
    }
    return [];
  }

  Future<List> _getModelData(String resourceUrl) async {
    int count = await _getTotalPages(resourceUrl);
    setState(() {
      _items.add('$resourceUrl: $count');
    });
    List data = await Future.wait(
        List.generate(count, (index) => _getTableData(resourceUrl, index + 1)));
    String title = '';
    List<List> items = [];
    if (data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        if (i == 0) {
          title = data[i].first;
        }
        if (data[i].isEmpty) {
          print('data[$i]:${data[i]}');
          continue;
        }
        for (int a = 0; a < data[i].last.length; a++) {
          if (i == 0 || a != 0) {
            items.add(data[i].last[a]);
          }
        }
      }
      await _save2Sheet(title, items);
    }
    return [title, items];
  }

  /// 保存在excel
  /// [ignoreFirstLineData] 是否忽略第一行数据，第一行数据是表格的头
  Future _save2Sheet(String sheetName, List<List> tableData) async {
    Sheet sheetObject = excel[sheetName];
    for (int i = 0; i < tableData.length; i++) {
      sheetObject.appendRow(tableData[i]);
    }
  }

  Future _initPath() async {
    Directory? directory;
    String today = DateTime.now().toString().substring(0, 10);
    String fileName = 'sw_info_$today.xlsx';
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    }
    if (Platform.isWindows) {
      directory = await getDownloadsDirectory();
    }
    _savePath = p.join(directory?.path ?? '', fileName);
    setState(() {});
  }
}
