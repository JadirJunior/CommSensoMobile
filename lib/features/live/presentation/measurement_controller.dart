
import 'package:commsensomobile/features/live/data/sensor_service.dart';
import 'package:commsensomobile/features/live/domain/measure.dart';
import 'package:commsensomobile/features/live/domain/sensor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MeasurementController extends GetxController {
  final RxMap<String, RxMap<int, Measurement>> deviceMeasurements = <String, RxMap<int, Measurement>>{}.obs;

  final RxList<Sensor> sensors = <Sensor>[].obs;
  final RxMap<String, DateTime> lastUpdatedByDevice = <String, DateTime>{}.obs;

  void updateMeasurementsFromPayload(String deviceId, Map<String, dynamic> json) {
    final measurement = Measurement.fromJson(json);

    final deviceMap = deviceMeasurements.putIfAbsent(deviceId, () => <int, Measurement>{}.obs);

    deviceMap[measurement.sensorId] = measurement;
    deviceMap.refresh();

    lastUpdatedByDevice[deviceId] = DateTime.now();
  }

  void setSensors(List<Sensor> newSensors) {
    sensors.assignAll(newSensors);
  }

  void clearMeasurements(String deviceId) {
    deviceMeasurements.remove(deviceId);
  }

  Future<void> fetchSensors() async {
    final sensorService = Get.find<SensorService>();

    try {
      final fetchedSensors = await sensorService.fetchSensors();
      setSensors(fetchedSensors);
    } catch (e) {
      debugPrint('Error fetching sensors: $e');
      Get.snackbar("Erro", "Erro ao tentar buscar sensores");
    }
  }


}