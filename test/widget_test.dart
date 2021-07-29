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
<div class="erji-content">
					<div class="erji-title">
						<div class="fl">主要江河水情</div>
						<div class="clear"></div>
					</div>
					<div class="erji-table table-responsive">
						<table class="table table-bordered table-striped">
							<tbody><tr>
								<th>河名</th>
								<th>站名</th>
								<th>时间</th>
								<th>水位</th>
								<th>流量</th>
								<th>水势</th>
								<th>警戒流量</th>
								<th>保证流量</th>
							</tr>
														<tr>
								<td>黄河                          </td>
								<td>府谷                          </td>
								<td>29日 08时</td>
								<td>807.760</td>
								<td>844.000</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>黄河                          </td>
								<td>吴堡                          </td>
								<td>29日 08时</td>
								<td>635.670</td>
								<td>330.000</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>黄河                          </td>
								<td>龙门                          </td>
								<td>29日 08时</td>
								<td>376.750</td>
								<td>345.000</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>黄河                          </td>
								<td>潼关                          </td>
								<td>29日 08时</td>
								<td>326.180</td>
								<td>718.000</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>延河                          </td>
								<td>延安                          </td>
								<td>29日 08时</td>
								<td>961.050</td>
								<td>1.160</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>渭河                          </td>
								<td>拓石                          </td>
								<td>29日 08时</td>
								<td>868.330</td>
								<td>34.300</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>渭河                          </td>
								<td>林家村                        </td>
								<td>29日 08时</td>
								<td>600.100</td>
								<td>28.000</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>渭河                          </td>
								<td>魏家堡                        </td>
								<td>29日 08时</td>
								<td>486.610</td>
								<td>29.200</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>渭河                          </td>
								<td>咸阳                          </td>
								<td>29日 08时</td>
								<td>376.600</td>
								<td>111.000</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>渭河                          </td>
								<td>临潼                          </td>
								<td>29日 08时</td>
								<td>351.060</td>
								<td>234.000</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>渭河                          </td>
								<td>华县                          </td>
								<td>29日 08时</td>
								<td>334.980</td>
								<td>351.000</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>泾河                          </td>
								<td>景 村                         </td>
								<td>29日 08时</td>
								<td>814.000</td>
								<td>28.400</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>泾河                          </td>
								<td>张家山                        </td>
								<td>29日 08时</td>
								<td>420.040</td>
								<td>29.300</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>泾河                          </td>
								<td>桃园                          </td>
								<td>29日 08时</td>
								<td>360.700</td>
								<td>35.200</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
															<tr>
								<td>北洛河                        </td>
								<td>刘家河                        </td>
								<td>29日 08时</td>
								<td>1116.350</td>
								<td>3.600</td>
								<td></td>
								<td></td>
								<td></td>
							</tr>
														</tbody></table>
					</div>
					<div class="fenye">
						<ul class="pagination" role="navigation">
        
                    <li class="page-item disabled" aria-disabled="true" aria-label="pagination.previous">
                <span class="page-link" aria-hidden="true">‹</span>
            </li>
        
        
                    
            
            
                                                                        <li class="page-item active" aria-current="page"><span class="page-link">1</span></li>
                                                                                <li class="page-item"><a class="page-link" href="http://www.shxsw.com.cn/water/21052619M6gAf?page=2">2</a></li>
                                                                                <li class="page-item"><a class="page-link" href="http://www.shxsw.com.cn/water/21052619M6gAf?page=3">3</a></li>
                                                                                <li class="page-item"><a class="page-link" href="http://www.shxsw.com.cn/water/21052619M6gAf?page=4">4</a></li>
                                                                                <li class="page-item"><a class="page-link" href="http://www.shxsw.com.cn/water/21052619M6gAf?page=5">5</a></li>
                                                                                <li class="page-item"><a class="page-link" href="http://www.shxsw.com.cn/water/21052619M6gAf?page=6">6</a></li>
                                                                                <li class="page-item"><a class="page-link" href="http://www.shxsw.com.cn/water/21052619M6gAf?page=7">7</a></li>
                                                                                <li class="page-item"><a class="page-link" href="http://www.shxsw.com.cn/water/21052619M6gAf?page=8">8</a></li>
                                                                    
                            <li class="page-item disabled" aria-disabled="true"><span class="page-link">...</span></li>
            
            
                                
            
            
                                                                        <li class="page-item"><a class="page-link" href="http://www.shxsw.com.cn/water/21052619M6gAf?page=19">19</a></li>
                                                                                <li class="page-item"><a class="page-link" href="http://www.shxsw.com.cn/water/21052619M6gAf?page=20">20</a></li>
                                                        
        
                    <li class="page-item">
                <a class="page-link" href="http://www.shxsw.com.cn/water/21052619M6gAf?page=2" rel="next" aria-label="pagination.next">›</a>
            </li>
            </ul>

					</div>
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
    String title = XPath.source(html)
        .query('//*[@class="erji-title"]/*[@class="fl"]/text()')
        .get();
    print(title);
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
}
