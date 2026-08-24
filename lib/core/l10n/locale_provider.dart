import 'package:flutter/material.dart';
import 'package:hakabo/core/l10n/app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  AppLanguage _lang = AppLanguage.en;

  AppLanguage get language => _lang;
  bool get isSomali => _lang == AppLanguage.so;
  bool get isArabic => _lang == AppLanguage.ar;
  bool get isRTL => _lang == AppLanguage.ar;

  void setLanguage(AppLanguage lang) {
    if (_lang == lang) return;
    _lang = lang;
    notifyListeners();
  }

  String t(String key) => AppStrings.get(key, _lang);
}
