import 'package:flutter/material.dart';
import 'package:swspider/pages/home.dart';

/// 页面路由映射表
class RouteMap {
  static final routes = <String, WidgetBuilder>{
    HomePage.routeName: (context) => HomePage(),
  };
}
