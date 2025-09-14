import 'dart:convert';

import 'package:commsensomobile/features/live/domain/container.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:commsensomobile/core/http/api_config.dart';

class LiveService {
  LiveService(this._client, this._cfg);

  final http.Client _client; //Interceptado com Authorization
  final ApiConfig _cfg; // ex: https://api.example.com


  Uri _u(String path, [Map<String, String>? qp]) => Uri.parse('${_cfg.baseUrl}$path').replace(queryParameters: qp);


  Future<List<CContainer>> fetchContainers() async {
    final res = await _client.get(_u('/container'));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);

      final list = (body is List) ? body : (body['data'] as List? ?? []);

      return list
          .cast<Map<String, dynamic>>()
          .map((j) => CContainer.fromJson(j))
          .toList();
    } else {
      throw Exception('Falha ao carregar containers');
    }
  }
}