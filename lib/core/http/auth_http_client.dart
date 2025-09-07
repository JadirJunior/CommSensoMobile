import 'dart:async';
import 'package:commsensomobile/core/services/session_service.dart';
import 'package:commsensomobile/features/auth/data/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class AuthHttpClient extends http.BaseClient {
  AuthHttpClient(this._inner, this._session, this._auth);

  final http.Client _inner;
  final SessionService _session;
  final AuthService _auth;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Injeta Authorization se tiver token
    final accessToken = _session.accessToken;

    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    // 1º tentativa
    var response = await _inner.send(request);

    if (response.statusCode != 401) return response;

    // 401 => Tentar refresh
    final refreshToken = await _session.readRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await _session.clear();
      return response;
    }

    try {
      final newTokens = await _auth.refresh(refreshToken);
      await _session.saveTokens(
          accessToken: newTokens.accessToken,
          refreshToken: newTokens.refreshToken
      );


      // Refaz a requisição original com o novo token
      final retry = await _retryWithNewToken(request, newTokens.accessToken);
      return retry;
    } catch (_) {
      await _handleLogout();
      return response;
    }
  }

  Future<http.StreamedResponse> _retryWithNewToken(http.BaseRequest original, String accessToken) {
    final cloned = _cloneRequest(original);
    cloned.headers['Authorization'] = 'Bearer $accessToken';
    return _inner.send(cloned);
  }

  http.BaseRequest _cloneRequest(http.BaseRequest r) {
    if (r is http.Request) {
      final c = http.Request(r.method, r.url);
      c.headers.addAll(r.headers);
      c.bodyBytes = r.bodyBytes;
      return c;
    }
    if (r is http.MultipartRequest) {
      final c = http.MultipartRequest(r.method, r.url);
      c.headers.addAll(r.headers);
      c.fields.addAll(r.fields);
      c.files.addAll(r.files);
      return c;
    }
    // fallback: pode não cobrir todos os tipos
    final c = http.Request(r.method, r.url)..headers.addAll(r.headers);
    return c;
  }

  Future<void> _handleLogout() async {
    await _session.clear();
    if (Get.currentRoute != '/login') {
      Get.offAllNamed('/login');
    }
  }
}
