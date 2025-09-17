import 'package:commsensomobile/features/devices/domain/device.dart';
import 'package:commsensomobile/features/devices/presentation/device_controller.dart';
import 'package:commsensomobile/features/live/presentation/live_controller.dart';
import 'package:commsensomobile/features/live/presentation/measurement_controller.dart';
import 'package:commsensomobile/features/live/presentation/measurement_detail_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LivePageUi extends StatelessWidget {
  const LivePageUi({super.key, this.device});

  final Device? device;

  @override
  Widget build(BuildContext context) {
    final deviceController = Get.find<DeviceController>();
    final measurementController = Get.find<MeasurementController>();
    final liveController = Get.find<LiveController>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top bar: dropdown + status icons
            Obx(() {
              final items = deviceController.devices
                  .where((d) => d.status == DeviceStatus.active)
                  .toList();
              final sel = deviceController.selectedDevice.value;
              final isValid = sel != null && items.any((d) => d.id == sel.id);
              final isMeasuring =
                  (deviceController.selectedDevice.value != null &&
                      deviceController.selectedDevice.value!.isMeasuring.value);
              final isOnline = (deviceController.selectedDevice.value != null &&
                  deviceController.selectedDevice.value!.isOnline.value);

              return Row(
                children: [
                  // Dropdown
                  Expanded(
                    child: DropdownButton<Device>(
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(10),
                      hint: const Text('Selecione um dispositivo'),
                      value: isValid
                          ? items.firstWhere((d) => d.id == sel!.id)
                          : null,
                      onChanged: (newDevice) {
                        if (newDevice != null) {
                          deviceController.selectDevice(newDevice);
                        }
                      },
                      items: items.map((d) {
                        return DropdownMenuItem<Device>(
                          value: d,
                          child: Text(
                            d.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Ícone: conexão (online/offline)
                  Tooltip(
                    message: isOnline ? 'Conectado à internet' : 'Offline',
                    child: Icon(
                      isOnline ? Icons.wifi : Icons.wifi_off,
                      color: isOnline ? Colors.green : Colors.red,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Ícone: medindo (on/off)
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return MeasurementControlModal();
                        },
                      );
                    },
                    child: Tooltip(
                      message:
                          isMeasuring ? 'Realizando medição' : 'Medidor parado',
                      child: Icon(
                        isMeasuring ? Icons.sensors : Icons.sensors_off,
                        color: isMeasuring ? Colors.green : Colors.grey,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 16),

            // Conteúdo
            Expanded(child: Obx(() {
              final selectedDeviceId =
                  deviceController.selectedDevice.value?.id;
              if (selectedDeviceId == null)
                return const Text('Nenhum dispositivo selecionado');

              final measurementMap =
                  measurementController.deviceMeasurements[selectedDeviceId];
              final sensors = measurementController.sensors;

              final lastUpdate =
                  measurementController.lastUpdatedByDevice[selectedDeviceId];
              final formattedDate = lastUpdate != null
                  ? DateFormat('dd/MM/yyyy HH:mm:ss').format(lastUpdate)
                  : '-';

              final currentContainer = deviceController
                  .selectedDevice.value?.currentContainerId?.value;
              final containerName = liveController.containers
                      .firstWhereOrNull((c) => c.id == currentContainer)
                      ?.name ??
                  '-';

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Text(
                          'Última atualização: $formattedDate',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sensores disponíveis: ${sensors.length}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Container atual: $containerName',
                          style: const TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: sensors.map((sensor) {
                        final measurement = measurementMap?[sensor.id];
                        return MeasurementCard(
                          name: sensor.name,
                          unit: sensor.unit,
                          value: measurement?.value,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            })),
          ],
        ),
      ),
    );
  }
}

class MeasurementCard extends StatelessWidget {
  const MeasurementCard({
    super.key,
    required this.name,
    required this.unit,
    this.value,
  });

  final String name;
  final String unit;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                value != null ? '${value?.toStringAsFixed(2)} $unit' : '-',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
