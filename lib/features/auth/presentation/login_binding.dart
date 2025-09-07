import 'package:commsensomobile/features/auth/data/auth_service.dart';
import 'package:commsensomobile/features/auth/presentation/login_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
        () => LoginController(Get.find<AuthService>())
    );
  }
}
