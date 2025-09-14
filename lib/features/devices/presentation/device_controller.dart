import 'dart:convert';

import 'package:commsensomobile/app/presentation/navigation_controller.dart';
import 'package:commsensomobile/core/services/mqtt/mqtt_client_service.dart';
import 'package:commsensomobile/features/devices/data/device_service.dart';
import 'package:commsensomobile/features/devices/domain/device.dart';
import 'package:commsensomobile/features/live/domain/measure.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceController extends GetxController {
  DeviceController(this._service);

  final DeviceService _service;

  final devices = <Device>[].obs; // lista exibida
  final allDevices = <Device>[].obs; // fonte (último fetch)
  final isLoading = false.obs;
  final error = RxnString();
  final chipSelected = 0.obs; // 0=all, 1=active, 2=inactive
  final selectedDevice = Rxn<Device>();

  final RxMap<String, RxMap<String, Measurement>> deviceMeasurements = <String, RxMap<String, Measurement>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('DeviceController initialized');

    final mqtt = Get.find<MqttClientService>();

    mqtt.messages.listen((MqttAppMessage msg) {
      final device = selectedDevice.value;
      if (device == null) return;

      debugPrint("MQTT Message: ${msg.topic} -> ${msg.payload}");
      if (msg.topic == '${device.tenantId}/${device.appId}/devices/${device.id}/state') {
        final isOnline = msg.payload == 'online';
        allDevices.firstWhere((d) => d.id == device.id).isOnline.value = isOnline;

        if (!isOnline) {
          allDevices.firstWhere((d) => d.id == device.id).isMeasuring.value = false;
        }

        update();
      } else if (msg.topic == '${device.tenantId}/${device.appId}/devices/${device.id}/measure') {
        device.isMeasuring.value = true;

        final data = jsonDecode(msg.payload);

        updateDeviceMeasurements(device.id, data);
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
    selectDevice(device);
    final navigationController = Get.find<NavigationController>();
    navigationController.goToPage(1);
  }

  void selectDevice(Device device) {
    final mqtt = Get.find<MqttClientService>();

    // Desinscreve tópicos antigos da conexão atual, mas NÃO fecha a conexão
    if (selectedDevice.value != null) {
      mqtt.unsubscribeAll(prefix: '${selectedDevice.value!.tenantId}/${selectedDevice.value!.appId}/devices');
    }

    selectedDevice.value = device;

    mqtt.subscribe('${device.tenantId}/${device.appId}/devices/${device.id}/state');
    mqtt.subscribe('${device.tenantId}/${device.appId}/devices/${device.id}/cmd/ack');
    mqtt.subscribe('${device.tenantId}/${device.appId}/devices/${device.id}/measure');
  }

  void startMeasurement(String containerName, int interval) {

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
      "containerName": containerName,
      "interval": interval,
    });

    final mqttClient = Get.find<MqttClientService>();

    mqttClient.publish('${selectedDevice.value?.tenantId}/${selectedDevice.value?.appId}/devices/${selectedDevice.value?.id}/cmd/power', payload);
    selectedDevice.value!.isMeasuring.value = true;
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
  }

  void updateDeviceMeasurements(String deviceId, Map<String, dynamic> json) {
    final measurements = deviceMeasurements.putIfAbsent(deviceId, () => <String, Measurement>{}.obs);

    measurements['temperature'] = Measurement(name: 'Temperatura', value: json['value'], unit: '°C', sensorId: json['sensorId'], containerId: json['containerId']);
    measurements['humidity'] = Measurement(name: 'Umidade', value: json['value'], unit: '%', sensorId: json['sensorId'], containerId: json['containerId']);
    measurements['ph'] = Measurement(name: 'pH', value: json['value'], unit: '', sensorId: json['sensorId'], containerId: json['containerId']);
    measurements['ec'] = Measurement(name: 'Condutividade Elétrica', value: json['value'], unit: 'µS/cm', sensorId: json['sensorId'], containerId: json['containerId']);
    measurements['nitrogen'] = Measurement(name: 'Nitrogênio', value: json['value'], unit: 'mg/kg', sensorId: json['sensorId'], containerId: json['containerId']);
    measurements['phosphorus'] = Measurement(name: 'Fósforo', value: json['value'], unit: 'mg/kg', sensorId: json['sensorId'], containerId: json['containerId']);
    measurements['potassium'] = Measurement(name: 'Potássio', value: json['value'], unit: 'mg/kg', sensorId: json['sensorId'], containerId: json['containerId']);

    measurements.refresh();
  }
}
