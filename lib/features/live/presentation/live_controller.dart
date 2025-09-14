import 'package:commsensomobile/features/live/data/live_service.dart';
import 'package:commsensomobile/features/live/domain/container.dart';
import 'package:commsensomobile/features/live/domain/measure.dart';
import 'package:get/get.dart';

class LiveController extends GetxController {
  LiveController(this._service);

  final LiveService _service;

  RxList<CContainer> containers = <CContainer>[].obs;
  Rxn<CContainer> selectedContainer = Rxn<CContainer>();

  RxInt measurementInterval = 30.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContainers();
  }

  Future<void> fetchContainers() async {
    try {
      final list = await _service.fetchContainers();
      containers.value = list;

      // Se não tiver selecionado ou selecionado errado, define o primeiro
      if (selectedContainer.value == null ||
          !containers.contains(selectedContainer.value)) {
        selectedContainer.value = containers.isNotEmpty ? containers[0] : null;
      }
    } catch (e) {
      // tratar erro
      rethrow;
    }
  }

  void selectContainer(CContainer container) {
    selectedContainer.value = container;
  }

  void selectInterval(int interval) {
    measurementInterval.value = interval;
  }
}
