import 'package:flutter/material.dart';
import 'app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  AppLanguage _lang = AppLanguage.en;

  AppLanguage get language => _lang;
  bool get isSomali => _lang == AppLanguage.so;

  void setLanguage(AppLanguage lang) {
    if (_lang == lang) return;
    _lang = lang;
    notifyListeners();
  }

  void toggle() =>
      setLanguage(_lang == AppLanguage.en ? AppLanguage.so : AppLanguage.en);

  String t(String key) => AppStrings.get(key, _lang);
}
