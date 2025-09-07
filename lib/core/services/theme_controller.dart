


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxService {
  ThemeController(this._box);

  final GetStorage _box;

  final themeMode = ThemeMode.system.obs;
  static const _key = 'theme_mode';

  Future<ThemeController> init() async {
    final raw = _box.read<String>(_key);
    themeMode.value = _parse(raw) ?? ThemeMode.system;
    return this;
  }

  void set(ThemeMode mode) {
    themeMode.value = mode;
    _box.write(_key, mode.name); // 'system' | 'light' | 'dark'
  }

  // alterna 3 estados: system -> light -> dark -> system
  void cycle() {
    final next = switch (themeMode.value) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light  => ThemeMode.dark,
      ThemeMode.dark   => ThemeMode.system,
    };
    set(next);
  }

  ThemeMode? _parse(String? s) => switch (s) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => null,
  };
}