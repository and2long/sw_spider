import 'package:flutter/material.dart';
import 'package:flutter_project_template/pages/page1.dart';
import 'package:flutter_project_template/pages/page2.dart';

class HomePage extends StatefulWidget {
  static const String routeName = 'HomePage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String tag = '_HomePageState';

  int _tabIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          Page1(),
          Page2(),
        ],
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Tab1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tab2',
          ),
        ],
        currentIndex: _tabIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
