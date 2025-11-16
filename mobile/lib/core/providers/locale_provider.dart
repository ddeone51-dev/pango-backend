import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../services/storage_service.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('sw', 'TZ');
  
  LocaleProvider() {
    _loadLocale();
  }
  
  Locale get locale => _locale;
  
  Future<void> _loadLocale() async {
    final languageCode = StorageService.getString(AppConstants.languageKey);
    if (languageCode != null) {
      _locale = Locale(languageCode, languageCode == 'sw' ? 'TZ' : 'US');
      notifyListeners();
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await StorageService.setString(AppConstants.languageKey, locale.languageCode);
    notifyListeners();
  }
  
  void toggleLanguage() {
    if (_locale.languageCode == 'sw') {
      setLocale(const Locale('en', 'US'));
    } else {
      setLocale(const Locale('sw', 'TZ'));
    }
  }
}

























