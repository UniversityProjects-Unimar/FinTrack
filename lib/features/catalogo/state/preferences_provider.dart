import 'package:flutter/material.dart';

class PreferencesProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _currencySymbol = 'R\$';

  ThemeMode get themeMode => _themeMode;
  String get currencySymbol => _currencySymbol;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setCurrencySymbol(String symbol) {
    final next = symbol.trim();
    if (next.isEmpty) return;
    if (_currencySymbol == next) return;
    _currencySymbol = next;
    notifyListeners();
  }
}
