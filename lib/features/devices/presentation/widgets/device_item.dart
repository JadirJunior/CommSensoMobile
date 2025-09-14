import 'package:commsensomobile/features/devices/presentation/device_controller.dart';
import 'package:flutter/material.dart';
import 'package:commsensomobile/features/devices/domain/device.dart';
import 'package:get/get.dart';


class DeviceItem extends StatelessWidget {
  const DeviceItem({
    super.key,
    required this.statusColor,
    required this.cs,
    required this.d,
    required this.controller,
  });

  final Color statusColor;
  final ColorScheme cs;
  final Device d;
  final DeviceController controller;

  @override
  Widget build(BuildContext context) {

    final bool isActive = d.status == DeviceStatus.active;

    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          const CircleAvatar(child: Icon(Icons.memory)),
          Positioned(
            right: -2, bottom: -2,
            child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(d.name),
      subtitle: Text(d.appName), // placeholder
      trailing: isActive
          ? FilledButton.tonal(
        onPressed: () {
          controller.goLive(d);
        },
        child: const Text('Live'),
      )
          : FilledButton.tonal(
        onPressed: () {
          Get.snackbar('Dispositivo inativo',
              'O dispositivo não está ativo no momento.');
        },
        child: const Text('Live'),
      ),
      onTap: () { /* abrir detalhe */ },
    );
  }
}