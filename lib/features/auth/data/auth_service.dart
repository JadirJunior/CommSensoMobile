import 'dart:convert';
import 'dart:developer' as dev;
import 'package:commsensomobile/features/auth/domain/tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService(this._baseUrl, this._storage);

  final String _baseUrl;
  final FlutterSecureStorage _storage;

  Future<Tokens> login(String user, String password) async {

    dev.log('Iniciando login para usuário: $user');
    final res = await http.post(Uri.parse('$_baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': user, 'password': password}));

    dev.log(res.body);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;


      // dev.log('Login bem-sucedido: $body');
      final tokens = Tokens(
          accessToken: body['data']['accessToken'] as String,
          refreshToken: body['data']['refreshToken'] as String);

      dev.log("Entrou aqui?");
      dev.log(tokens.accessToken);
      dev.log(tokens.refreshToken);

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
