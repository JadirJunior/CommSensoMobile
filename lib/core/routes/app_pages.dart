import 'package:commsensomobile/features/auth/presentation/login_binding.dart';
import 'package:flutter/material.dart';
import 'package:commsensomobile/core/routes/auth_guard.dart';
import 'package:commsensomobile/features/auth/presentation/login_page.dart';
import 'package:commsensomobile/app/presentation/app_shell_page.dart';
import 'package:get/get.dart';

class AppPages {
  static const initial = '/home';

  static final routes = <GetPage>[
    GetPage(
        name: '/login',
        page: () => const LoginPage(),
        middlewares: [AuthGuard()],
        binding: LoginBinding()),
    GetPage(
        name: '/home',
        page: () => const AppShellPage(),
        middlewares: [AuthGuard()]),
  ];
}
