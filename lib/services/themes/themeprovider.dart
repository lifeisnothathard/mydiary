import 'package:flutter/material.dart';
import 'package:mydiary/services/themes/darkmode.dart';
import 'package:mydiary/services/themes/lightmode.dart';

// You'll need to add the 'provider' package to your pubspec.yaml:
// dependencies:
//   provider: ^latest_version

class ThemeProvider extends ChangeNotifier {
  // By default, start with light mode
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // Get the current ThemeData based on the selected theme mode
  ThemeData get currentThemeData {
    return _themeMode == ThemeMode.dark ? darkModeTheme : lightModeTheme;
  }

  /// Toggles the theme between light and dark mode.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify all listeners that the theme has changed
  }

  /// Sets the theme mode explicitly.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }
}
