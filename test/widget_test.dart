// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swspider/main.dart';
import 'package:xpath_parse/xpath_selector.dart';

const html = """
<div class="menu fl">
					<h1>水情信息</h1>
					<ul class="list-unstyled">
													<li class="active"><a href="/water/21052619M6gAf">主要江河水情</a></li>
														<li><a href="/reservoir/21052619kKXHT">大型及重点中型水库水情</a></li>
														<li><a href="/regime/21052619bmBrd">雨情信息</a></li>
												</ul>
				</div>
""";

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  test('get title', () {
    List<String> result = XPath.source(html)
        .query('//*[@class="menu fl"]//li/a/@href')
        .list();
    print(result);
  });

  test('get table data', () {
    List<String> data = XPath.source(html)
        .query(
            '//*[@class="table table-bordered table-striped"]/tbody/tr/text()')
        .list();
    data.forEach((element) {
      var list = element.split('\n');
      var newList = list.map((e) => e.trim()).toList();
      print(newList);
    });
  });

  test('date', () {
    print(DateTime.now().toString().substring(0, 10));
  });
}
