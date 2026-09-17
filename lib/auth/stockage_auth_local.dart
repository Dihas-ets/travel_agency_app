import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStore {
  static const _clientPhonesKey = 'client_phone_numbers';
  static const _clientProfilesKey = 'client_profiles';
  // 1. On ajoute la clé pour le Token
  static const _tokenKey = 'auth_token';
  static const _secureStorage = FlutterSecureStorage();

  static String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\s+'), '').trim();
  }

  // --- NOUVELLES MÉTHODES POUR LE TOKEN ---

  /// Sauvegarde le token d'authentification (Laravel Sanctum)
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Récupère le token pour les appels API futurs
  static Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  /// Supprime le token (pour la déconnexion)
  static Future<void> removeToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // --- TES MÉTHODES EXISTANTES (NE PAS CHANGER) ---

  static Future<void> saveClientPhone(String phone) async {
    final normalizedPhone = normalizePhone(phone);
    if (normalizedPhone.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final phones = prefs.getStringList(_clientPhonesKey) ?? <String>[];
    if (!phones.contains(normalizedPhone)) {
      await prefs.setStringList(_clientPhonesKey, [...phones, normalizedPhone]);
    }
  }

  static Future<void> saveClientProfile({
    required String phone,
    required String nom,
    required String prenom,
  }) async {
    final normalizedPhone = normalizePhone(phone);
    final fullName = '$nom $prenom'.trim();
    if (normalizedPhone.isEmpty || fullName.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final profiles = _readProfiles(prefs);
    profiles[normalizedPhone] = fullName;
    await prefs.setString(_clientProfilesKey, jsonEncode(profiles));
  }

  static Future<String?> getClientFullName(String phone) async {
    final normalizedPhone = normalizePhone(phone);
    if (normalizedPhone.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final name = _readProfiles(prefs)[normalizedPhone]?.trim();
    if (name == null || name.isEmpty) return null;
    return name;
  }

  static Future<bool> isRegisteredClientPhone(String phone) async {
    final normalizedPhone = normalizePhone(phone);
    if (normalizedPhone.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final phones = prefs.getStringList(_clientPhonesKey) ?? <String>[];
    return phones.contains(normalizedPhone);
  }

  static Map<String, String> _readProfiles(SharedPreferences prefs) {
    final rawProfiles = prefs.getString(_clientProfilesKey);
    if (rawProfiles == null || rawProfiles.trim().isEmpty) {
      return <String, String>{};
    }

    try {
      final decoded = jsonDecode(rawProfiles);
      if (decoded is! Map) return <String, String>{};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return <String, String>{};
    }
  }
}