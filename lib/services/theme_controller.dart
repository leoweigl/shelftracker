import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ValueNotifier<FlexScheme> {
  static const _prefsKey = 'selected_theme';

  ThemeController() : super(FlexScheme.ebonyClay);

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_prefsKey);
    if (savedName != null) {
      value = FlexScheme.values.firstWhere(
        (s) => s.name == savedName,
        orElse: () => FlexScheme.ebonyClay,
      );
    }
  }

  Future<void> setScheme(FlexScheme scheme) async {
    value = scheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, scheme.name);
  }
}
