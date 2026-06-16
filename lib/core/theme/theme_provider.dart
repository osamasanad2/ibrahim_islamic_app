import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import '../storage/local_storage.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final storage = LocalStorage();
    final saved = storage.getString('theme_mode', defaultValue: 'dark');
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  void setThemeMode(ThemeMode mode) {
    final storage = LocalStorage();
    state = mode;
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
      case ThemeMode.system:
        value = 'system';
      default:
        value = 'dark';
    }
    storage.saveString('theme_mode', value);
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.dark:
        setThemeMode(ThemeMode.light);
      case ThemeMode.light:
        setThemeMode(ThemeMode.system);
      case ThemeMode.system:
        setThemeMode(ThemeMode.dark);
    }
  }
}
