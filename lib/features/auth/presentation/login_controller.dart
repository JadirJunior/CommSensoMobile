import 'package:commsensomobile/core/config/build_env.dart';
import 'package:commsensomobile/core/services/mqtt/mqtt_client_service.dart';
import 'package:commsensomobile/core/services/mqtt/mqtt_config.dart';
import 'package:commsensomobile/core/services/session_service.dart';
import 'package:commsensomobile/features/auth/data/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  LoginController(this._auth);

  final AuthService _auth;

  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final error = RxnString();
  final obscure = true.obs;

  Future<void> onLogin() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    error.value = null;

    try {
      await Future.delayed(const Duration(seconds: 2));

      final tokens = await _auth.login(userCtrl.text.trim(), passCtrl.text);

      await Get.find<SessionService>().saveTokens(
          accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);

      final mqttService = Get.find<MqttClientService>();

      final cfg = MqttConfig(
          host: BuildEnv.brokerHost,
          port: BuildEnv.brokerPort,
          clientId: 'app_${DateTime.now().millisecondsSinceEpoch}',
          username: BuildEnv.brokerUser,
          password: tokens.accessToken,
          secure: BuildEnv.brokerTls,
          useWebSocket: BuildEnv.brokerWs);

      await mqttService.init(cfg);

      Get.offAllNamed('/home'); //Navega se deu certo
    } catch (e) {
      error.value = 'Usuário ou senha incorretos';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleObscure() => obscure.value = !obscure.value;

  @override
  void onClose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }
}
