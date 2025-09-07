import 'package:commsensomobile/core/routes/app_pages.dart';
import 'package:commsensomobile/core/services/theme_controller.dart';
import 'package:commsensomobile/core/theme/app_theme.dart';
import 'package:commsensomobile/core/theme/tokens/app_colors.dart';
import 'package:commsensomobile/features/auth/data/auth_service.dart';
import 'package:commsensomobile/features/auth/presentation/login_controller.dart';
import 'package:commsensomobile/features/auth/presentation/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: theme.themeMode.value,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        ));
  }
}
