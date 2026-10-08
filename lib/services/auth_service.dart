import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fofanavoyage/config/app_config.dart';
import 'package:fofanavoyage/auth/stockage_auth_local.dart';
import 'package:fofanavoyage/models/user_model.dart';
import 'package:fofanavoyage/data/local/session_store.dart';

class AuthService {
  
  String get _baseUrl => AppConfig.apiBaseUrl;

  Future<Map<String, dynamic>> inscrireClient({
    required String nom,
    required String prenom,
    required String telephone,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _postAuthentication('auth/mobile/inscription-client', {
      'nom': nom,
      'prenom': prenom,
      'numero': telephone,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<Map<String, dynamic>> connexionMobile({
    required String telephone,
    required String password,
  }) async {
    return _postAuthentication('auth/mobile/connexion', {
      'numero': telephone,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> _postAuthentication(
    String endpoint,
    Map<String, String> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is! Map<String, dynamic>) {
          return {'success': false, 'message': 'Réponse invalide du serveur.'};
        }
        return {
          'success': true,
          'token': decoded['token'],
          'user': decoded['user'],
          'message': decoded['message'],
        };
      }
      return {
        'success': false,
        'message': decoded is Map
            ? decoded['message']?.toString() ?? 'Authentification impossible.'
            : 'Authentification impossible.',
      };
    } on FormatException {
      return {'success': false, 'message': 'Réponse invalide du serveur.'};
    } catch (_) {
      return {'success': false, 'message': 'Erreur de connexion au serveur.'};
    }
  }

  /// CONNEXION STAFF : Par mot de passe
  Future<Map<String, dynamic>> connexionStaff(
    String telephone,
    String password,
  ) async {
    final url = Uri.parse('$_baseUrl/auth/staff/connexion');

    // --- NORMALISATION COMME SUR LE WEB ---
    String finalPhone = telephone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!finalPhone.startsWith('+')) {
      finalPhone = '+$finalPhone';
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
      final response = await http
          .get(
            Uri.parse('$_baseUrl/auth/moi'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

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

  /// Charge le profil connecté et remonte les erreurs au lieu de les masquer.
  Future<UserModel> refreshCurrentProfile() async {
    final token = await AuthLocalStore.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Votre session a expiré. Veuillez vous reconnecter.');
    }

    final response = await http
        .get(
          Uri.parse('$_baseUrl/auth/moi'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));
    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final message = decoded is Map ? decoded['message']?.toString() : null;
      throw Exception(
        message ??
            'Erreur ${response.statusCode} lors du chargement du profil.',
      );
    }
    if (decoded is! Map || decoded['user'] is! Map) {
      throw const FormatException(
        'Réponse invalide lors du chargement du profil.',
      );
    }

    final user = UserModel.fromJson(
      Map<String, dynamic>.from(decoded['user'] as Map),
    );
    SessionStore.setCurrentUser(user);
    await AuthLocalStore.saveCurrentUser(user);
    return user;
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

    final uri = Uri.parse('$_baseUrl/auth/client/modifier-profil');
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
      final multipartFile = await http.MultipartFile.fromPath(
        'profil',
        photo.path,
      );
      request.files.add(multipartFile);
    }

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 25),
      );
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
        String msg =
            data['message']?.toString() ?? 'Erreur de mise à jour du profil.';
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
        await http
            .post(
              Uri.parse('$_baseUrl/auth/client/deconnexion'),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
    await AuthLocalStore.removeToken();
    await AuthLocalStore.removeCurrentUser();
    SessionStore.clear();
  }
}
