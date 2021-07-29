import 'package:flutter/material.dart';

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar({
    required this.color,
    required this.tabBar,
    this.width,
  }) : super(color: color, child: tabBar, width: width);

  final Color color;
  final TabBar tabBar;
  final double? width;

  @override
  Size get preferredSize => tabBar.preferredSize;
}
