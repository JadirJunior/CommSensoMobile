import 'package:commsensomobile/app/app.dart';
import 'package:commsensomobile/app/presentation/navigation_controller.dart';
import 'package:commsensomobile/core/config/build_env.dart';
import 'package:commsensomobile/core/http/api_config.dart';
import 'package:commsensomobile/core/http/auth_http_client.dart';
import 'package:commsensomobile/core/services/mqtt/mqtt_client_service.dart';
import 'package:commsensomobile/core/services/mqtt/mqtt_config.dart';
import 'package:commsensomobile/core/services/session_service.dart';
import 'package:commsensomobile/core/services/theme_controller.dart';
import 'package:commsensomobile/features/auth/data/auth_service.dart';
import 'package:commsensomobile/features/devices/data/device_service.dart';
import 'package:commsensomobile/features/devices/presentation/device_controller.dart';
import 'package:commsensomobile/features/live/data/live_service.dart';
import 'package:commsensomobile/features/live/data/sensor_service.dart';
import 'package:commsensomobile/features/live/presentation/live_controller.dart';
import 'package:commsensomobile/features/live/presentation/measurement_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Storage único e permanente
  final storage = Get.put<FlutterSecureStorage>(const FlutterSecureStorage(),
      permanent: true);

  final cfg = const ApiConfig(BuildEnv.apiBaseUrl);

  Get.put<ApiConfig>(cfg, permanent: true);

  // 2) SessionService iniciando assincronamente
  final session = await Get.putAsync<SessionService>(() async {
    return SessionService(Get.find<FlutterSecureStorage>()).init();
  });

  // 3) AuthService com dependência do SessionService e Storage
  final authService = Get.put<AuthService>(
      AuthService(Get.find<ApiConfig>().baseUrl, storage),
      permanent: true);

  final interceptorHttp = Get.put<http.Client>(
      AuthHttpClient(http.Client(), session, authService),
      permanent: true); // Agora Get.find<http.Client>() retorna o interceptor

  Get.put(MqttClientService(), permanent: true);

  Get.put<DeviceService>(
    DeviceService(interceptorHttp, cfg),
    permanent: true,
  );

  Get.put<LiveService>(
    LiveService(interceptorHttp, cfg),
    permanent: true,
  );

  Get.put<SensorService>(
    SensorService(interceptorHttp, cfg),
    permanent: true,
  );

  Get.lazyPut<DeviceController>(
    () => DeviceController(Get.find<DeviceService>()),
    fenix: true, // recria se for coletado
  );

  Get.lazyPut<NavigationController>(
    () => NavigationController(),
    fenix: true, // recria se for coletado
  );

  Get.lazyPut<LiveController>(
    () => LiveController(Get.find<LiveService>()),
    fenix: true,
  );

   Get.lazyPut<MeasurementController>(() => MeasurementController(), fenix: true);

  final measurementController = Get.find<MeasurementController>();

  await measurementController.fetchSensors();

  await Get.putAsync<ThemeController>(
      () async => ThemeController(GetStorage()).init(),
      permanent: true);

  await startMqttIfAuthenticated(
    storage: storage,
    mqttService: Get.find<MqttClientService>(),
    brokerHost: BuildEnv.brokerHost,
    brokerPort: BuildEnv.brokerPort,
    brokerUser: BuildEnv.brokerUser,
    useWebSocket: BuildEnv.brokerWs,
    secure: BuildEnv.brokerTls,
  );

  runApp(const MyApp());
}

// Helper: Conecta ao mqtt se houver access_token
Future<void> startMqttIfAuthenticated({
  required FlutterSecureStorage storage,
  required MqttClientService mqttService,
  required String brokerHost,
  required int brokerPort,
  required String brokerUser,
  required bool useWebSocket,
  required bool secure,
}) async {
  String? access_token = await storage.read(key: 'access_token');

  if (access_token == null) return;

  final cfg = MqttConfig(
      host: brokerHost,
      port: brokerPort,
      clientId: 'app_${DateTime.now().millisecondsSinceEpoch}',
      username: brokerUser,
      password: access_token);

  await mqttService.init(cfg);
}
