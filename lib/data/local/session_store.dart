import 'package:flutter/foundation.dart';
import 'package:code_initial/models/user_model.dart';

class SessionStore {
  static String? currentClientPhone;
  static String? currentClientFullName;
  static UserModel? currentUser;

  static final ValueNotifier<UserModel?> currentUserNotifier =
      ValueNotifier<UserModel?>(null);

  static bool get hasClientPhone {
    return (currentClientPhone != null && currentClientPhone!.trim().isNotEmpty) ||
        (currentUser?.numero != null && currentUser!.numero.trim().isNotEmpty);
  }

  static void setCurrentClientPhone(String phone) {
    currentClientPhone = phone.trim();
  }

  static void setCurrentClientName({
    required String nom,
    required String prenom,
  }) {
    currentClientFullName = '$nom $prenom'.trim();
  }

  static void setCurrentUser(UserModel? user) {
    currentUser = user;
    if (user != null) {
      if (user.numero.isNotEmpty) {
        currentClientPhone = user.numero;
      }
      currentClientFullName = user.fullName;
    }
    currentUserNotifier.value = user;
  }

  static void clearCurrentClientPhone() {
    currentClientPhone = null;
  }

  static void clearCurrentClientName() {
    currentClientFullName = null;
  }

  static void clear() {
    currentClientPhone = null;
    currentClientFullName = null;
    currentUser = null;
    currentUserNotifier.value = null;
  }
}
