import 'package:commsensomobile/features/devices/domain/device.dart';
import 'package:commsensomobile/features/devices/presentation/device_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LivePageUi extends StatelessWidget {
  const LivePageUi({super.key, this.device});

  final Device? device;

  @override
  Widget build(BuildContext context) {
    // Aqui você acessa o dispositivo que foi passado por parâmetro

    final deviceController = Get.find<DeviceController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Seleção de Dispositivo')),
      body: Column(
        children: [
          // Dropdown para selecionar o dispositivo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              return DropdownButton<Device>(
                hint: const Text('Selecione um dispositivo'),
                value: deviceController.selectedDevice.value,
                onChanged: (newDevice) {
                  if (newDevice != null) {
                    deviceController.selectDevice(newDevice);
                  }
                },
                items: deviceController.devices.map((device) {
                  return DropdownMenuItem<Device>(
                    value: device,
                    child: Text(device.name),
                  );
                }).toList(),
              );
            }),
          ),

          // Exibindo informações do dispositivo selecionado
          Expanded(
            child: Obx(() {
              final selectedDevice = deviceController.selectedDevice.value;

              if (selectedDevice == null) {
                return const Center(
                    child: Text('Nenhum dispositivo selecionado.'));
              }

              return Center(
                child: Text('Visualizando ao vivo: ${selectedDevice.name}'),
              );
            }),
          ),
        ],
      ),
    );
  }
}
