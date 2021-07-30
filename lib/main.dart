import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:swspider/network/http.dart';
import 'package:swspider/utils/common_util.dart';
import 'package:provider/provider.dart';
import 'package:swspider/i18n/i18n.dart';
import 'package:swspider/init/provider.dart';
import 'package:swspider/init/route_map.dart';
import 'package:swspider/init/theme.dart';
import 'package:swspider/pages/home.dart';
import 'package:swspider/utils/log_utils.dart';
import 'package:swspider/utils/sp_utils.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SPUtils.init().then((value) {
    XHttp.init();
    runApp(Store.init(MyApp()));
  });
  // 安卓透明状态栏
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleStore>(builder: (context, localeStore, _) {
      return OKToast(
        child: MaterialApp(
          onGenerateTitle: (context) => S.of(context).appName,
          theme: AppTheme.lightTheme(context),
          localizationsDelegates: [
            SLocalizationsDelegate.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.supportedLocales,
          locale: localeStore.languageCode == null
              ? S.supportedLocales.first
              : Locale(localeStore.languageCode!),
          localeResolutionCallback:
              (Locale? locale, Iterable<Locale> supportedLocales) {
            Log.d('MyApp',
                'deviceLocale: $locale, supportedLocales: $supportedLocales, languageCode: ${localeStore.languageCode}');
            // 默认系统语言，如果不支持，则使用支持语言的第一个。
            if (localeStore.languageCode == null) {
              Log.d('MyApp', 'localeStore.languageCode is null');
              List<String> supportedLanguageCodeList =
                  S.supportedLocales.map((e) => e.languageCode).toList();
              if (supportedLanguageCodeList.contains(locale!.languageCode)) {
                localeStore.setLanguageCode(locale.languageCode);
              } else {
                localeStore
                    .setLanguageCode(S.supportedLocales.first.languageCode);
              }
              return locale;
            }
            return Locale(localeStore.languageCode!);
          },
          routes: RouteMap.routes,
          home: HomePage(),
          builder: (context, child) => Scaffold(
            body: GestureDetector(
              onTap: () {
                CommonUtils.hideKeyboard(context);
              },
              child: child,
            ),
          ),
        ),
      );
    });
  }
}
