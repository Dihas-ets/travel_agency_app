class SessionStore {
  static String? currentClientPhone;

  static bool get hasClientPhone {
    return currentClientPhone != null && currentClientPhone!.trim().isNotEmpty;
  }

  static void setCurrentClientPhone(String phone) {
    currentClientPhone = phone.trim();
  }

  static void clearCurrentClientPhone() {
    currentClientPhone = null;
  }
}
