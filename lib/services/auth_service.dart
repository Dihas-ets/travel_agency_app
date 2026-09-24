import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:code_initial/config/app_config.dart';

class AuthService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  /// INSCRIPTION CLIENT : Envoyer l'OTP
  Future<Map<String, dynamic>> verifierNumeroInscription(String telephone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/client/otp/verifier-numero-inscription'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'numero': telephone}),
    );
    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200 && data['available'] == true,
      'message': data['message']?.toString() ?? 'Numéro indisponible.',
    };
  }

  Future<Map<String, dynamic>> envoyerOtp(String telephone) async {
    final url = Uri.parse('$baseUrl/auth/client/otp/envoyer');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'numero': telephone}),
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }
  }

  /// CONNEXION CLIENT : Vérifier si le numéro existe et envoyer l'OTP
  Future<Map<String, dynamic>> connexionOtp(String telephone) async {
    final url = Uri.parse('$baseUrl/auth/client/otp/connexion');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'numero': telephone}),
      );
      final data = jsonDecode(response.body);
      
      return {
        'success': response.statusCode == 200,
        'isStaff': response.statusCode == 409,
        'message': data['message']?.toString() ?? 'Connexion impossible.',
      };

    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  Future<Map<String, dynamic>> renvoyerOtp({
    required String telephone,
    required String flow,
  }) async {
    String normalizedPhone = telephone.trim();
    normalizedPhone = normalizedPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!normalizedPhone.startsWith('+')) {
      normalizedPhone = '+$normalizedPhone';
    }

    final endpoint = flow == 'register'
        ? 'auth/client/otp/envoyer'
        : 'auth/client/otp/connexion';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'numero': normalizedPhone}),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': data['message']?.toString() ?? 'Impossible de renvoyer le code.',
      };
    } catch (_) {
      return {'success': false, 'message': 'Erreur de connexion au serveur.'};
    }
  }

  /// VÉRIFICATION OTP (Commune Inscription & Connexion Client)
  Future<Map<String, dynamic>> verifierOtp({
    required String telephone,
    required String code,
    String? nom,
    String? prenom,
  }) async {
    final url = Uri.parse('$baseUrl/auth/client/otp/verifier');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'numero': telephone,
          'code': code,
          'nom': nom,
          'prenom': prenom,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'token': data['token'], 'user': data['user']};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }

  /// CONNEXION STAFF : Par mot de passe
  /// CONNEXION STAFF : Par mot de passe
  Future<Map<String, dynamic>> connexionStaff(String telephone, String password) async {
    final url = Uri.parse('$baseUrl/auth/staff/connexion');

    // --- NORMALISATION COMME SUR LE WEB ---
    String finalPhone = telephone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!finalPhone.startsWith('+')) {
      finalPhone = '+$finalPhone';
    }
    // ---------------------------------------

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'numero': finalPhone, // On envoie le numéro avec le "+"
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'token': data['token'], 'user': data['user']};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
    }
  }
}