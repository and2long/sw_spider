import 'dart:io';

import 'package:dio/dio.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:swspider/network/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xpath_parse/xpath_selector.dart';

const HOME_URL = 'http://www.shxsw.com.cn/';

class HomePage extends StatefulWidget {
  static const String routeName = 'HomePage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String tag = '_HomePageState';
  var excel = Excel.createExcel();

  /// 文件保存地址
  late String _savePath;

  @override
  void initState() {
    super.initState();
    _initPath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _getTableData('/water/21052619kKXHT', 1),
          child: Text('get home html'),
        ),
      ),
    );
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

  void _getTableData(String resourceUrl, int pageIndex) async {
    Response response = await XHttp.instance
        .get('$HOME_URL$resourceUrl', queryParameters: {'page': pageIndex});
    if (response.statusCode == 200) {
      String html = response.data;
      String title = XPath.source(html)
          .query('//*[@class="erji-title"]/*[@class="fl"]/text()')
          .get();
      print(title);
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
      print(result);
      _save2Excel(title, result, ignoreFirstLineData: false);
    }
  }

  /// 保存在excel
  /// [ignoreFirstLineData] 是否忽略第一行数据，第一行数据是表格的头
  void _save2Excel(String sheetName, List<List<String>> tableData,
      {bool ignoreFirstLineData = true}) async {
    if (await Permission.storage.request().isGranted) {
      Sheet sheetObject = excel[sheetName];
      for (int i = 0; i < tableData.length; i++) {
        if (i != 0 || !ignoreFirstLineData) {
          sheetObject.appendRow(tableData[i]);
        }
      }
      var fileBytes = excel.save();
      if (fileBytes != null) {
        File(_savePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        print('save success');
        print(_savePath);
      }
    } else {
      openAppSettings();
    }
  }

  void _initPath() async {
    var directory = await getExternalStorageDirectory();
    _savePath = "${directory!.path}/sw_info.xlsx";
  }
}
