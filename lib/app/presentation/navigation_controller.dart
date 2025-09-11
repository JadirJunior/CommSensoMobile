import 'package:commsensomobile/features/devices/presentation/devices_page_ui.dart';
import 'package:commsensomobile/features/live/presentation/live_page_ui.dart';
import 'package:commsensomobile/features/settings/presentation/settings_page_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  NavigationController();

  final currentIndex = 0.obs;

  final _pages = const [
    DevicesPageUi(),
    LivePageUi(),
    // AppsPageUi(),
    SettingsPageUi(),
  ];

  List<Widget> get pages => _pages;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  void goToPage(int index) {
    currentIndex.value = index;
  }


}
