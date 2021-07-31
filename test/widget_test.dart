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
    List<String> result =
        XPath.source(html).query('//*[@class="menu fl"]//li/a/@href').list();
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

  test('get cookie', () {
    String setCookie =
        "XSRF-TOKEN=eyJpdiI6Ik95UEtiY2xsOHhYZmcrY0JLNnpKRnc9PSIsInZhbHVlIjoiZXczVklVcThiaGZ5Y2lQMjArZjgzeUY5Q29HdGNmMDJ5dHNxdmk3QnBydU1hOFVwOElaT3pjMHBUV3ByRFI1QiIsIm1hYyI6IjFmMzgwMWQxOGQyMDFhZjY3ZDkzZjFlNWE4ZDIwMGJmN2E0N2JlZTYxMjYxOTc0MzFiNTJhODNlMzFjODJkMDYifQ%3D%3D; expires=Sat, 31-Jul-2021 04:45:40 GMT; Max-Age=7200; path=/";
    RegExp rxToken = RegExp(r'XSRF-TOKEN=\s*([\s\S]*?)\s*;');
    RegExpMatch? matchToken = rxToken.firstMatch(setCookie);
    if (matchToken != null) {
      print(matchToken.group(1));
    }

    String setCookie1 =
        'alps_session=eyJpdiI6ImU3d1ZLckpraGJDU1B3OUFTMkh4eEE9PSIsInZhbHVlIjoienppNXpTTXJISE04VXhja1FIRVlpaVNGVTM1dVhIN2x3TDczTDhMMldZemUrRXMycThEaWxlcXNjdDd5V2xScCIsIm1hYyI6ImZmMmNmMDVkMjYxMTdhYjI4OGQ3MzU3OTBmMThkZjJiYWE1YzI2YzVmZDIzZjI2MTIyYThmNmNjMTM2YjJmNzkifQ%3D%3D; expires=Sat, 31-Jul-2021 04:28:42 GMT; Max-Age=7200; path=/; httponly';
    RegExp rxSession = RegExp(r'alps_session=\s*([\s\S]*?)\s*;');
    RegExpMatch? matchSession = rxSession.firstMatch(setCookie1);
    if (matchSession != null) {
      print(matchSession.group(1));
    }
  });
}
