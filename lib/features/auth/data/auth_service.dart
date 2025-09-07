import 'dart:convert';

import 'package:commsensomobile/features/auth/domain/tokens.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService(this._baseUrl, this._storage);

  final String _baseUrl;
  final FlutterSecureStorage _storage;

  Future<Tokens> login(String user, String password) async {
    final res = await http.post(Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user': user, 'password': password}));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final tokens = Tokens(
          accessToken: body['access_token'] as String,
          refreshToken: body['refresh_token'] as String);

      await _storage.write(key: 'access_token', value: tokens.accessToken);

      if (tokens.refreshToken.isNotEmpty) {
        await _storage.write(key: 'refresh_token', value: tokens.refreshToken);
      }

      return tokens;
    } else {
      throw Exception('Falha no login: ${res.statusCode}');
    }
  }

  Future<Tokens> refresh(String refreshToken) async {
    final res = await http.post(Uri.parse('$_baseUrl/auth/refresh}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}));
    if (res.statusCode != 200) {
      throw Exception('Falha ao renovar token');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;

    return Tokens(
        accessToken: body['access_token'] as String,
        refreshToken: body['refresh_token'] as String
    );
  }
}
