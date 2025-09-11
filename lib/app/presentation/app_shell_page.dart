import 'package:commsensomobile/app/presentation/navigation_controller.dart';
import 'package:commsensomobile/features/apps/presentation/apps_page.dart';
import 'package:commsensomobile/features/devices/presentation/devices_page_ui.dart';
import 'package:commsensomobile/features/live/presentation/live_page_ui.dart';
import 'package:commsensomobile/features/settings/presentation/settings_page_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});
  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  int index = 0;

  // final _pages = const [
  //   DevicesPageUi(),
  //   LivePageUi(),
  //   // AppsPageUi(),
  //   SettingsPageUi(),
  // ];
  final _titles = const ['Dispositivos', 'Ao vivo', 'Ajustes'];

  @override
  Widget build(BuildContext context) {
    NavigationController navigationController = Get.find<NavigationController>();

    return Scaffold(
      appBar: AppBar(title: Text(_titles[index])),
      body: IndexedStack(index: navigationController.currentIndex.value, children: navigationController.pages), // preserva estado das abas
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationController.currentIndex.value,
        onDestinationSelected: (i) => setState(() => navigationController.goToPage(i)),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.devices_other), label: _titles[0]),
          NavigationDestination(icon: Icon(Icons.timeline), label: _titles[1]),
          // NavigationDestination(icon: Icon(Icons.apps), label: _titles[2]),
          NavigationDestination(icon: Icon(Icons.settings), label: _titles[2]),
        ],
      ),

      floatingActionButton: navigationController.currentIndex.value == 0
          ? FloatingActionButton.extended(
        onPressed: () {/* Get.toNamed('/onboarding'); */},
        icon: const Icon(Icons.add),
        label: const Text('Adicionar dispositivo'),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
