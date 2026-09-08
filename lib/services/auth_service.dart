import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Ton IP locale
  static const String baseUrl = "http://192.168.1.73:8000/api"; 

  /// INSCRIPTION CLIENT : Envoyer l'OTP
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
      
      // Si le code est 200, c'est un client, on renvoie succès
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        // Si 404 ou autre, ce n'est pas un client (ce sera sans doute un staff)
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion'};
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