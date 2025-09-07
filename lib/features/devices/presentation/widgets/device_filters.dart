import 'package:commsensomobile/features/devices/presentation/device_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceFilters extends StatelessWidget {
  const DeviceFilters({
    super.key,
    required this.controller,
  });

  final DeviceController controller;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: const Text('Todos'), selected: controller.chipSelected == 0.obs, onSelected: (_) => controller.selectChip(0)),
                FilterChip(label: const Text('Ativos'), selected: controller.chipSelected == 1.obs, onSelected: (_) => controller.selectChip(1)),
                FilterChip(label: const Text('Inativos'), selected: controller.chipSelected == 2.obs, onSelected: (_) => controller.selectChip(2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}