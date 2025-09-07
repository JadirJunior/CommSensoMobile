import 'package:commsensomobile/app/app.dart';
import 'package:commsensomobile/core/http/auth_http_client.dart';
import 'package:commsensomobile/core/services/session_service.dart';
import 'package:commsensomobile/features/auth/data/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Storage único e permanente
  final storage = Get.put<FlutterSecureStorage>(const FlutterSecureStorage(),
      permanent: true);

  // 2) SessionService iniciando assincronamente
  final session = await Get.putAsync<SessionService>(() async {
    return SessionService(Get.find<FlutterSecureStorage>()).init();
  });

  // 3) AuthService com dependência do SessionService e Storage
  final authService = Get.put<AuthService>(
      AuthService(
          'https://api.minhaempresa.com', storage),
      permanent: true
  );

  Get.put<http.Client>(AuthHttpClient(
      http.Client(), session, authService),
      permanent: true
  );// Agora Get.find<http.Client>() retorna o interceptor
  
  runApp(const MyApp());
}