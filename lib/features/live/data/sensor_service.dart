

import 'dart:convert';

import 'package:commsensomobile/core/http/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:commsensomobile/features/live/domain/sensor.dart';

class SensorService {

  SensorService( this._client, this._cfg);

  final http.Client _client;
  final ApiConfig _cfg;

  Uri _u(String path, [Map<String, String>? qp]) => Uri.parse('${_cfg.baseUrl}$path').replace(queryParameters: qp);

  Future<List<Sensor>> fetchSensors() async {

    final res = await _client.get(_u('/sensores'));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);

      final list = (body is List) ? body : (body['data'] as List? ?? []);

      return list
          .cast<Map<String, dynamic>>()
          .map((j) => Sensor.fromJson(j))
          .toList();
    } else {
      throw Exception('Falha ao carregar containers');
    }


  }

}
