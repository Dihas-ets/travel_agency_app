class SessionStore {
  static String? currentClientPhone;
  static String? currentClientFullName;

  static bool get hasClientPhone {
    return currentClientPhone != null && currentClientPhone!.trim().isNotEmpty;
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

  static void clearCurrentClientPhone() {
    currentClientPhone = null;
  }

  static void clearCurrentClientName() {
    currentClientFullName = null;
  }
}
