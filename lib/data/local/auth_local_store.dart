import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStore {
  static const _clientPhonesKey = 'client_phone_numbers';

  static String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\s+'), '').trim();
  }

  static Future<void> saveClientPhone(String phone) async {
    final normalizedPhone = normalizePhone(phone);
    if (normalizedPhone.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final phones = prefs.getStringList(_clientPhonesKey) ?? <String>[];
    if (!phones.contains(normalizedPhone)) {
      await prefs.setStringList(_clientPhonesKey, [...phones, normalizedPhone]);
    }
  }

  static Future<bool> isRegisteredClientPhone(String phone) async {
    final normalizedPhone = normalizePhone(phone);
    if (normalizedPhone.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final phones = prefs.getStringList(_clientPhonesKey) ?? <String>[];
    return phones.contains(normalizedPhone);
  }
}
