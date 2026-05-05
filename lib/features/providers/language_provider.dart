import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLanguage(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  // Optional: Add method to get language name
  String getLanguageName() {
    switch (_locale.languageCode) {
      case 'ur':
        return 'اردو';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }
}
