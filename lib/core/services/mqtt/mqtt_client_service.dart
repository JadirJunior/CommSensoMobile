import 'dart:async';

import 'package:commsensomobile/core/config/build_env.dart';
import 'package:commsensomobile/core/services/mqtt/mqtt_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttAppMessage {
  final String topic;
  final String payload;

  MqttAppMessage(this.topic, this.payload);
}


class MqttClientService extends GetxService {
  final _stream = StreamController<MqttAppMessage>.broadcast();

  Stream<MqttAppMessage> get messages => _stream.stream;

  final _subs = <String, MqttQos>{}.obs;
  final _failedSubs = <String>{};
  MqttClient? _client;
  late MqttConfig _cfg;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<MqttClientService> init(MqttConfig cfg) async {
    _cfg = cfg;
    await _connect();
    return this;
  }

  Future<void> reconfigure(MqttConfig cfg) async {
    _cfg = cfg;
    await _disconnect();
    await _connect();
  }


  Future<void> _connect() async {
    final c = MqttServerClient.withPort(_cfg.host, _cfg.clientId, _cfg.port);

    c.setProtocolV311();
    c.logging(on: false);
    c.keepAlivePeriod = 30;
    c.autoReconnect = false;
    c.onConnected = () => _resubscribe(c);
    c.onDisconnected = () {
      debugPrint('MQTT disconnected');
      
      Get.snackbar('Conexão Perdida', 'Conexão com o servidor MQTT foi perdida.',
          snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(onPressed: () { reconnect(); Get.back(); }, child: Text('Reconectar')));
    };

    c.secure = _cfg.secure;
    c.useWebSocket = _cfg.useWebSocket;

    c.connectionMessage =
        MqttConnectMessage().withClientIdentifier(_cfg.clientId).startClean();

    try {
      await c.connect(_cfg.username, _cfg.password);
    } catch (_) {
      c.disconnect();
    }

    if (c.connectionStatus?.state == MqttConnectionState.connected) {
      debugPrint('MQTT connected');
      _client = c;
      c.updates?.listen((events) {
        for (final e in events) {
          final msg = e.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);
          debugPrint('MQTT message received: ${e.topic} -> $payload');
          _stream.add(MqttAppMessage(e.topic, payload));
        }
      });
      _resubscribe(c);
    } else {
      debugPrint(
          'MQTT connection failed - disconnecting, status is ${c
              .connectionStatus}');
      c.disconnect();
    }
  }
  
  Future<void> _disconnect() async {
    unsubscribeAll();
    _client?.disconnect();
    _client = null;
  }

  Future<void> reconnect() async {
    try {

      if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
        debugPrint('Já conectado, não é necessário reconectar.');
        return;
      }

      _subs.clear();
      _failedSubs.clear();


      await _client?.connect(_cfg.username, _cfg.password);
      if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
        debugPrint('Reconectado com sucesso');
        Get.snackbar('Conectado', 'Conexão com o servidor MQTT restabelecida.',
            snackPosition: SnackPosition.BOTTOM);
        _resubscribe(_client!);
      } else {
        debugPrint('Falha ao reconectar MQTT');
      }
    } catch (e) {
      debugPrint('Erro na reconexão MQTT: $e');
    }
  }



  void _resubscribe(MqttClient c) {
    _subs.forEach((topic, qos) => c.subscribe(topic, qos));
  }

  void subscribe(String topic, [MqttQos qos = MqttQos.atMostOnce]) {
    if (_failedSubs.contains(topic)) {
      debugPrint('MQTT: Subscribe ignorado para $topic, pois falhou antes.');
      return;
    }

    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      debugPrint('MQTT: Não conectado, subscribe ignorado para $topic');
      return;
    }

    try {
      var res = _client!.subscribe(topic, qos);
      if (res == null) {
        debugPrint(
            'MQTT: Subscribe falhou para $topic - marcando para não tentar novamente automático.');
        _failedSubs.add(topic); // marca falha
        return;
      }
      _subs[topic] = qos;
      debugPrint('MQTT: Subscribe realizado com sucesso para $topic');
    } catch (e) {
      debugPrint('MQTT: Erro ao inscrever $topic: $e');
      _failedSubs.add(topic); // marca falha
    }
  }

  void publish(String topic, String payload, [MqttQos qos = MqttQos.atMostOnce]) {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      debugPrint('MQTT: Não conectado, publish ignorado para $topic');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);

    try {
      _client!.publishMessage(topic, qos, builder.payload!);
      debugPrint('MQTT: Publish realizado com sucesso para $topic');
    } catch (e) {
      debugPrint('MQTT: Erro ao publicar em $topic: $e');
    }
  }


  void retrySubscribe(String topic) {
    _failedSubs.remove(topic);
    subscribe(topic, _subs[topic] ?? MqttQos.atMostOnce);
  }

  void unsubscribe(String topic) {
    _client?.unsubscribe(topic);
    _subs.remove(topic);
    _failedSubs.remove(topic);
  }


  void unsubscribeAll({String? prefix}) {
    final keys = _subs.keys.toList();
    for (final t in keys) {
      if (prefix == null || t.startsWith(prefix)) unsubscribe(t);
    }
  }


  @override
  void onClose() {
    // _stream.close();
    _disconnect();
    super.onClose();
  }


}