import 'package:commsensomobile/core/services/session_service.dart';
import 'package:commsensomobile/features/auth/data/auth_service.dart';
import 'package:commsensomobile/features/devices/data/device_service.dart';
import 'package:commsensomobile/features/devices/domain/device.dart';
import 'package:commsensomobile/features/live/presentation/live_page_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DeviceController extends GetxController {
  DeviceController(this._service);

  final DeviceService _service;

  final devices = <Device>[].obs; // lista exibida
  final allDevices = <Device>[].obs; // fonte (último fetch)
  final isLoading = false.obs;
  final error = RxnString();
  final chipSelected = 0.obs; // 0=all, 1=active, 2=inactive
  final selectedDevice = Rxn<Device>();

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = null;
    try {
      //Fake list
      // final list = await _fakeList();
      final list = await _service.list(); // implementado no seu service
      allDevices.assignAll(list);
      _applyFilter();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Device>> _fakeList() async {
    await Future.delayed(const Duration(milliseconds: 600)); // simula rede

    DeviceStatus statusFor(int i) {
      if (i % 5 == 0) return DeviceStatus.blocked;
      if (i % 3 == 0) return DeviceStatus.provisioned;
      return DeviceStatus.active;
    }

    return List.generate(10, (i) {
      return Device(
        id: 'dev-${i + 1}',
        name: 'Device ${i + 1}',
        tenantId: 'ten-${(i % 3) + 1}',
        tenantName: 'Tenant ${(i % 3) + 1}',
        appId: 'app-${(i % 2) + 1}',
        appName: 'App ${(i % 2) + 1}',
        status: statusFor(i), // <-- enum, não string
      );
    });
  }

  Future<void> refreshList() => fetch(); // para RefreshIndicator

  void selectChip(int index) {
    chipSelected.value = index;
    _applyFilter();
  }

  void _applyFilter() {
    switch (chipSelected.value) {
      case 0: // Todos
        devices.assignAll(allDevices);
        break;
      case 1: // Ativos
        devices.assignAll(
          allDevices.where((d) => d.status == DeviceStatus.active).toList(),
        );
        break;
      case 2: // Inativos
        devices.assignAll(
          allDevices
              .where((d) => d.status == DeviceStatus.provisioned)
              .toList(),
        );
        break;
      case 3: // Bloqueados
        devices.assignAll(
          allDevices
              .where((d) => d.status == DeviceStatus.blocked)
              .toList(),
        );
        break;
      default:
        devices.assignAll(allDevices);
    }
  }

  void goLive(Device device) {
    // Navigation to live view
    Get.to(() => LivePageUi(device: device));
  }

  void selectDevice(Device device) {
    selectedDevice.value = device;
  }
}
