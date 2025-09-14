import 'package:commsensomobile/features/devices/domain/device.dart';
import 'package:commsensomobile/features/devices/presentation/device_controller.dart';
import 'package:commsensomobile/features/live/presentation/live_controller.dart';
import 'package:commsensomobile/features/live/presentation/measurement_detail_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LivePageUi extends StatelessWidget {
  const LivePageUi({super.key, this.device});

  final Device? device;

  @override
  Widget build(BuildContext context) {
    final deviceController = Get.find<DeviceController>();

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
              final isMeasuring = (deviceController.selectedDevice.value != null &&
                  deviceController
                      .selectedDevice.value!.isMeasuring.value);
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
                    message: isOnline
                        ? 'Conectado à internet'
                        : 'Offline',
                    child: Icon(
                      isOnline
                          ? Icons.wifi
                          : Icons.wifi_off,
                      color: isOnline
                          ? Colors.green
                          : Colors.red,
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
                      message: isMeasuring
                          ? 'Realizando medição'
                          : 'Medidor parado',
                      child: Icon(
                        isMeasuring
                            ? Icons.sensors
                            : Icons.sensors_off,
                        color: isMeasuring
                            ? Colors.green
                            : Colors.grey,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 16),

            // Conteúdo
            Expanded(
              child: Obx(() {

                return const Center(child: Text('Em desenvolvimento...'));
                // final measurementList = deviceController.deviceMeasurements[deviceController.selectedDevice?.value?.id!]?.values ?? [];

                // if (measurementList.isEmpty) {
                //   return Center(child: Text('Nenhuma medição disponível'));
                // }

                // return GridView.count(
                //   crossAxisCount: 2,
                //   childAspectRatio: 3 / 2,  // largura/altura do card
                //   shrinkWrap: true,
                //   physics: NeverScrollableScrollPhysics(),
                //   children: measurementList.map((m) {
                //     return Card(
                //       margin: EdgeInsets.all(8),
                //       elevation: 3,
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                //       child: Padding(
                //         padding: EdgeInsets.all(12),
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Text(m.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                //             SizedBox(height: 8),
                //             Text('${m.value.toStringAsFixed(2)} ${m.unit}',
                //                 style: TextStyle(fontSize: 14)),
                //           ],
                //         ),
                //       ),
                //     );
                //   }).toList(),
                // );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
