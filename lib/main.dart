import 'package:commsensomobile/app/app.dart';
import 'package:commsensomobile/core/http/api_config.dart';
import 'package:commsensomobile/core/http/auth_http_client.dart';
import 'package:commsensomobile/core/services/session_service.dart';
import 'package:commsensomobile/core/services/theme_controller.dart';
import 'package:commsensomobile/features/auth/data/auth_service.dart';
import 'package:commsensomobile/features/devices/data/device_service.dart';
import 'package:commsensomobile/features/devices/presentation/device_controller.dart';
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

  final cfg = const ApiConfig(String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://192.168.1.102:3000'));

  Get.put<ApiConfig>(cfg, permanent: true);

  // 2) SessionService iniciando assincronamente
  final session = await Get.putAsync<SessionService>(() async {
    return SessionService(Get.find<FlutterSecureStorage>()).init();
  });

  // 3) AuthService com dependência do SessionService e Storage
  final authService = Get.put<AuthService>(
      AuthService(Get.find<ApiConfig>().baseUrl, storage),
      permanent: true);

  final interceptorHttp = Get.put<http.Client>(AuthHttpClient(http.Client(), session, authService),
      permanent: true); // Agora Get.find<http.Client>() retorna o interceptor

  Get.put<DeviceService>(
    DeviceService(interceptorHttp, cfg),
    permanent: true,
  );

  Get.lazyPut<DeviceController>(
        () => DeviceController(Get.find<DeviceService>()),
    fenix: true, // recria se for coletado
  );

  await Get.putAsync<ThemeController>(() async => ThemeController(GetStorage()).init(), permanent: true);

  runApp(const MyApp());
}
