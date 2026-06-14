import 'package:flutter/foundation.dart';
import '../config/admin_config.dart';

class BlogAuthService {
  final ValueNotifier<bool> isAdmin = ValueNotifier(false);

  void login(String password) {
    if (password == AdminConfig.password) {
      isAdmin.value = true;
    }
  }

  void logout() {
    isAdmin.value = false;
  }
}
