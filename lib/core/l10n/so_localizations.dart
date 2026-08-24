import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SomaliMaterialLocalizations extends DefaultMaterialLocalizations {
  const SomaliMaterialLocalizations();

  @override String get okButtonLabel => 'OK';
  @override String get cancelButtonLabel => 'Jooji';
  @override String get closeButtonLabel => 'Xir';
  @override String get searchFieldLabel => 'Raadi';
  @override String get backButtonTooltip => 'Dib u noqo';
  @override String get copyButtonLabel => 'Nuqul';
  @override String get cutButtonLabel => 'Jar';
  @override String get pasteButtonLabel => 'Dhaji';
  @override String get selectAllButtonLabel => 'Dhammaan dooro';
  @override String get drawerLabel => 'Menu';
  @override String get popupMenuLabel => 'Menu';
  @override String get dialogLabel => 'Dialog';
  @override String get alertDialogLabel => 'Ogeysiis';
  @override String get searchWebButtonLabel => 'Raadi Web-ka';
  @override String get shareButtonLabel => 'Wadaag';
  
  static const LocalizationsDelegate<MaterialLocalizations> delegate = _SomaliMaterialLocalizationsDelegate();
}

class _SomaliMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _SomaliMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<MaterialLocalizations> load(Locale locale) => SynchronousFuture<MaterialLocalizations>(const SomaliMaterialLocalizations());

  @override
  bool shouldReload(_SomaliMaterialLocalizationsDelegate old) => false;
}

class SomaliCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const SomaliCupertinoLocalizations();

  @override String get alertDialogLabel => 'Ogeysiis';
  @override String get searchTextFieldPlaceholderLabel => 'Raadi';
  @override String get cutButtonLabel => 'Jar';
  @override String get copyButtonLabel => 'Nuqul';
  @override String get pasteButtonLabel => 'Dhaji';
  @override String get selectAllButtonLabel => 'Dhammaan dooro';
  @override String get todayLabel => 'Maanta';
  @override String get lookUpButtonLabel => 'Raadi';
  @override String get menuDismissLabel => 'Xir';
  @override String get shareButtonLabel => 'Wadaag';
  @override String get backButtonLabel => 'Dib';
  @override String get cancelButtonLabel => 'Jooji';
  @override String get clearButtonLabel => 'Nadiifi';

  static const LocalizationsDelegate<CupertinoLocalizations> delegate = _SomaliCupertinoLocalizationsDelegate();
}

class _SomaliCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _SomaliCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<CupertinoLocalizations> load(Locale locale) => SynchronousFuture<CupertinoLocalizations>(const SomaliCupertinoLocalizations());

  @override
  bool shouldReload(_SomaliCupertinoLocalizationsDelegate old) => false;
}
