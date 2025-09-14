import 'package:commsensomobile/core/services/mqtt/mqtt_client_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SessionService extends GetxService {
  SessionService(this._storage);

  final FlutterSecureStorage _storage;

  final RxnString _accessToken = RxnString();

  Future<SessionService> init() async {
    _accessToken.value = await _storage.read(key: 'access_token');
    return this;
  }

  bool get isLoggedIn => (_accessToken.value?.isNotEmpty ?? false);

  String? get accessToken => _accessToken.value;

  Future<String?> readRefreshToken() => _storage.read(key: 'refresh_token');

  Future<void> saveTokens({ required String accessToken, required String refreshToken }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    _accessToken.value = accessToken;
  }

  Future<void> clear() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    Get.find<MqttClientService>().onClose();
    _accessToken.value = null;
  }
}