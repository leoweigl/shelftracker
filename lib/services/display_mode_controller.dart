import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplayModeController extends ValueNotifier<ThemeMode> {
  static const _prefsKey = 'display_mode';

  DisplayModeController() : super(ThemeMode.system);

  Future<void> loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_prefsKey);
    if (savedName != null) {
      value = ThemeMode.values.firstWhere(
        (m) => m.name == savedName,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}
