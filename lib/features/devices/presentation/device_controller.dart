import 'dart:convert';

import 'package:commsensomobile/app/presentation/navigation_controller.dart';
import 'package:commsensomobile/core/services/mqtt/mqtt_client_service.dart';
import 'package:commsensomobile/features/devices/data/device_service.dart';
import 'package:commsensomobile/features/devices/domain/device.dart';
import 'package:commsensomobile/features/live/domain/container.dart';
import 'package:commsensomobile/features/live/domain/measure.dart';
import 'package:commsensomobile/features/live/presentation/live_controller.dart';
import 'package:commsensomobile/features/live/presentation/measurement_controller.dart';
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
    debugPrint('DeviceController initialized');

    final mqtt = Get.find<MqttClientService>();

    mqtt.messages.listen((MqttAppMessage msg) {

      debugPrint("MQTT Message Received: ${msg.topic} -> ${msg.payload}");

      final measurementController = Get.find<MeasurementController>();
      final liveController = Get.find<LiveController>();

      final device = selectedDevice.value;
      if (device == null) return;
      if (msg.topic == '${device.tenantId}/${device.appId}/devices/${device.id}/state') {
        final isOnline = msg.payload == 'online';
        allDevices.firstWhere((d) => d.id == device.id).isOnline.value = isOnline;

        if (!isOnline) {
          allDevices.firstWhere((d) => d.id == device.id).isMeasuring.value = false;
        }

        update();
      } else if (msg.topic == '${device.tenantId}/${device.appId}/devices/${device.id}/measure') {

        final data = jsonDecode(msg.payload);

        final container = liveController.containers.firstWhereOrNull((c) => c.id == data['containerId']);

        if (container == null) {
          debugPrint('Container with id ${data['containerId']} not found');
          return;
        }

        if (device.currentContainerId?.value == 0) {
          device.currentContainerId?.value = container!.id;
        }

        if (device.currentContainerId?.value != container.id) return;


        device.isMeasuring.value = true;

        allDevices.firstWhere((d) => d.id == device.id).isOnline.value = true;

        measurementController.updateMeasurementsFromPayload(device.id, data);
        update();
      }
    });


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
      // error.value = e.toString();
      error.value = 'Falha ao carregar dispositivos. Verifique sua conexão e tente novamente.';
    } finally {
      isLoading.value = false;
    }
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
    selectDevice(device);
    final navigationController = Get.find<NavigationController>();
    navigationController.goToPage(1);
  }

  void selectDevice(Device device) {
    final mqtt = Get.find<MqttClientService>();

    final measurementController = Get.find<MeasurementController>();


    // Desinscreve tópicos antigos da conexão atual, mas NÃO fecha a conexão
    if (selectedDevice.value != null) {
      mqtt.unsubscribeAll(prefix: '${selectedDevice.value!.tenantId}/${selectedDevice.value!.appId}/devices');
    }

    selectedDevice.value = device;

    measurementController.fetchSensors();
    mqtt.subscribe('${device.tenantId}/${device.appId}/devices/${device.id}/state');
    mqtt.subscribe('${device.tenantId}/${device.appId}/devices/${device.id}/cmd/ack');
    mqtt.subscribe('${device.tenantId}/${device.appId}/devices/${device.id}/measure');


  }

  void startMeasurement(CContainer container, int interval) {
    final measurementController = Get.find<MeasurementController>();

    if (selectedDevice.value == null) {
      Get.snackbar('Erro', 'Nenhum dispositivo selecionado');
      return;
    }

    if (selectedDevice.value?.isMeasuring == true) {
      Get.snackbar('Info', 'A medição já está em andamento');
      return;
    }

    if (selectedDevice.value?.isOnline == false) {
      Get.snackbar('Erro', 'O dispositivo está offline');
      return;
    }


    final payload = jsonEncode({
      "action": "start",
      "containerName": container.name,
      "interval": interval,
    });

    final mqttClient = Get.find<MqttClientService>();

    mqttClient.publish('${selectedDevice.value?.tenantId}/${selectedDevice.value?.appId}/devices/${selectedDevice.value?.id}/cmd/power', payload);
    selectedDevice.value!.isMeasuring.value = true;
    selectedDevice.value!.currentContainerId?.value = container.id;
    measurementController.deviceMeasurements[selectedDevice.value!.id]?.clear();

  }

  void stopMeasurement() {

    if (selectedDevice.value == null) {
      Get.snackbar('Erro', 'Nenhum dispositivo selecionado');
      return;
    }


    if (selectedDevice.value?.isMeasuring == false) {
      Get.snackbar('Info', 'A medição já está parada');
      return;
    }

    final payload = jsonEncode({"action": "stop"});

    final mqttClient = Get.find<MqttClientService>();

    mqttClient.publish('${selectedDevice.value?.tenantId}/${selectedDevice.value?.appId}/devices/${selectedDevice.value?.id}/cmd/power', payload);
    selectedDevice.value?.isMeasuring.value = false;
    selectedDevice.value?.currentContainerId?.value = 0;
  }
}
