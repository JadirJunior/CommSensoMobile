import 'package:commsensomobile/features/devices/presentation/widgets/device_filters.dart';
import 'package:commsensomobile/features/devices/presentation/widgets/device_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:commsensomobile/features/devices/presentation/device_controller.dart';

class DevicesPageUi extends GetView<DeviceController> {
  const DevicesPageUi({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.isLoading.value && controller.devices.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value != null && controller.devices.isEmpty) {
        return _ErrorState(
          message: controller.error.value!,
          onRetry: controller.fetch,
        );
      }

      if (controller.allDevices.isEmpty) {
        return _EmptyState(onAdd: () {
          // Get.toNamed('/onboarding');
        });
      }

      // Lista normal com pull-to-refresh
      return RefreshIndicator(
        onRefresh: controller.refreshList,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            DeviceFilters(controller: controller),
            SliverList.separated(
              itemCount: controller.devices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final d = controller.devices[i];
                final statusColor = _statusColor(d.status.name, cs);
                return DeviceItem(statusColor: statusColor, cs: cs, d: d, controller: controller);
              },
            ),
            // Loading de rodapé (para futuras paginações)
            if (controller.isLoading.value)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      );
    });
  }
}

Color _statusColor(String status, ColorScheme cs) {
  switch (status.toLowerCase()) {
    case 'active': return cs.primary;
    case 'blocked': return cs.error;
    default: return cs.outline;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.devices_other, size: 72),
            const SizedBox(height: 12),
            Text('Nenhum dispositivo ainda',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Adicione seu primeiro dispositivo para começar.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Adicionar dispositivo'),
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 12),
            Text('Falha ao carregar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
