import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swspider/i18n/i18n.dart';
import 'package:swspider/utils/sp_utils.dart';

/// 状态管理
class Store {
  Store._internal();

  // 全局初始化
  static init(Widget child) {
    return MultiProvider(
      providers: [
        // 国际化
        ChangeNotifierProvider.value(
            value: LocaleStore(SPUtils.getLanguageCode())),
      ],
      child: child,
    );
  }
}

/// 语言
class LocaleStore with ChangeNotifier {
  String? _languageCode;

  LocaleStore(this._languageCode);

  String? get languageCode => _languageCode;

  set languageCode(String? languageCode) {
    if (languageCode != null && languageCode != _languageCode) {
      _languageCode = languageCode;
      S.locale = Locale(languageCode);
      SPUtils.setLanguageCode(languageCode);
      notifyListeners();
    }
  }

  void setLanguageCode(String languageCode) {
    _languageCode = languageCode;
    SPUtils.setLanguageCode(languageCode);
  }
}
