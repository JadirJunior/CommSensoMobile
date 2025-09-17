import 'package:commsensomobile/features/devices/presentation/device_controller.dart';
import 'package:commsensomobile/features/live/presentation/live_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:commsensomobile/features/live/domain/container.dart';
import 'package:get_storage/get_storage.dart';

class MeasurementControlModal extends StatefulWidget {
  @override
  _MeasurementControlModalState createState() =>
      _MeasurementControlModalState();
}

class _MeasurementControlModalState extends State<MeasurementControlModal> {
  final liveController = Get.find<LiveController>();
  final deviceController = Get.find<DeviceController>();

  @override
  void initState() {
    super.initState();
    liveController.fetchContainers();
  }

  void startMeasurement() {
    if (liveController.selectedContainer.value == null) {
      Get.snackbar('Erro', 'Selecione um container antes de iniciar');
      return;
    }

    deviceController.startMeasurement(liveController.selectedContainer.value!,
        liveController.measurementInterval.value);
    Navigator.pop(context);
  }

  void stopMeasurement() {
    deviceController.stopMeasurement();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Controle da Medição', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<CContainer>(
                value: liveController.selectedContainer.value,
                items: liveController.containers
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                decoration: InputDecoration(labelText: 'Container'),
                onChanged: (c) => liveController.selectContainer(c!),
              )),
              const SizedBox(height: 16),
              Obx(() => TextFormField(
                initialValue: liveController.measurementInterval.value.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Intervalo (segundos)'),
                onChanged: (v) {
                  final val = int.tryParse(v);
                  if (val != null) liveController.selectInterval(val);
                },
              )),
              const SizedBox(height: 24),
              Obx(() {
                final isMeasuring = deviceController.selectedDevice.value?.isMeasuring.value ?? false;
                return ElevatedButton(
                  onPressed: isMeasuring ? stopMeasurement : startMeasurement,
                  style: isMeasuring
                      ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                      : null,
                  child: Text(isMeasuring ? 'Parar Medição' : 'Iniciar Medição'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
