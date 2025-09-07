import 'dart:convert';
import 'dart:developer' as dev;
import 'package:commsensomobile/core/http/api_config.dart';
import 'package:commsensomobile/features/devices/domain/device.dart';
import 'package:http/http.dart' as http;

class DeviceService {
  DeviceService(this._client, this._cfg);

  final http.Client _client; //Interceptado com Authorization
  final ApiConfig _cfg; // ex: https://api.example.com

  Uri _u(String path, [Map<String, String>? qp]) => Uri.parse('${_cfg.baseUrl}$path').replace(queryParameters: qp);


  Future<List<Device>> list({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? status,
    String? appId,
  }) async {
    final qp = {
      'page': '$page',
      'pageSize': '$pageSize',
      if (query != null && query.isNotEmpty) 'query': query,
      if (status != null && status.isNotEmpty) 'status': status,
      if (appId != null && appId.isNotEmpty) 'appId': appId,
    };

    final res = await _client.get(_u('/device'));

    if (res.statusCode != 200) {
      throw Exception('Failed to load devices: ${res.statusCode}');
    }

    final body = jsonDecode(res.body);

    final list = (body is List) ? body : (body['data'] as List? ?? []);

    dev.log('DeviceService.list: $list', name: 'DeviceService');

    return list
        .cast<Map<String, dynamic>>()
        .map((j) => Device.fromJson(j))
        .toList();
  }
}
