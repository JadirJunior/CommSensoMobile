import 'package:commsensomobile/core/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthGuard extends GetMiddleware {

  @override
  RouteSettings? redirect(String? route) {
    final session = Get.find<SessionService>();
    final logged = session.isLoggedIn;

    if (!logged && route != '/login') {
      return const RouteSettings(name: '/login');
    }

    if (logged && route == '/login') {
      return const RouteSettings(name: '/home');
    }

    return null;
  }


}