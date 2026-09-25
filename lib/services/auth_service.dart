import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:code_initial/config/app_config.dart';
import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/models/user_model.dart';
import 'package:code_initial/data/local/session_store.dart';

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
  Future<Map<String, dynamic>> connexionStaff(String telephone, String password) async {
    final url = Uri.parse('$baseUrl/auth/staff/connexion');

    // --- NORMALISATION COMME SUR LE WEB ---
    String finalPhone = telephone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!finalPhone.startsWith('+')) {
      finalPhone = '+$finalPhone';
    }

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

  /// PROFIL DE L'UTILISATEUR CONNECTÉ : GET /api/auth/moi
  Future<UserModel?> getProfile() async {
    final token = await AuthLocalStore.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/moi'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userJson = data['user'] as Map<String, dynamic>?;
        if (userJson != null) {
          final user = UserModel.fromJson(userJson);
          SessionStore.setCurrentUser(user);
          await AuthLocalStore.saveCurrentUser(user);
          return user;
        }
      }
    } catch (_) {}
    return null;
  }

  /// MODIFIER LE PROFIL DU CLIENT : POST /api/auth/client/modifier-profil
  Future<Map<String, dynamic>> updateProfile({
    String? nom,
    String? prenom,
    String? email,
    String? country,
    File? photo,
  }) async {
    final token = await AuthLocalStore.getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Non authentifié.'};
    }

    final uri = Uri.parse('$baseUrl/auth/client/modifier-profil');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';

    if (nom != null && nom.trim().isNotEmpty) {
      request.fields['nom'] = nom.trim();
    }
    if (prenom != null && prenom.trim().isNotEmpty) {
      request.fields['prenom'] = prenom.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      request.fields['email'] = email.trim();
    }
    if (country != null && country.trim().isNotEmpty) {
      request.fields['country'] = country.trim();
    }

    if (photo != null && photo.existsSync()) {
      final multipartFile = await http.MultipartFile.fromPath('profil', photo.path);
      request.files.add(multipartFile);
    }

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userJson = data['user'] as Map<String, dynamic>?;
        UserModel? updatedUser;
        if (userJson != null) {
          updatedUser = UserModel.fromJson(userJson);
          SessionStore.setCurrentUser(updatedUser);
          await AuthLocalStore.saveCurrentUser(updatedUser);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Profil mis à jour avec succès.',
          'user': updatedUser,
          'photo_url': data['photo_url'],
        };
      } else {
        String msg = data['message']?.toString() ?? 'Erreur de mise à jour du profil.';
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final firstKey = errors.keys.first;
          final firstVal = errors[firstKey];
          if (firstVal is List && firstVal.isNotEmpty) {
            msg = firstVal.first.toString();
          }
        }
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion : $e'};
    }
  }

  /// DÉCONNEXION CLIENT : POST /api/auth/client/deconnexion
  Future<void> deconnexion() async {
    final token = await AuthLocalStore.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('$baseUrl/auth/client/deconnexion'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
    await AuthLocalStore.removeToken();
    await AuthLocalStore.removeCurrentUser();
    SessionStore.clear();
  }
}