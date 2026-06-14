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

  void toggleTheme() {
    final storage = LocalStorage();
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      storage.saveString('theme_mode', 'light');
    } else {
      state = ThemeMode.dark;
      storage.saveString('theme_mode', 'dark');
    }
  }
}
