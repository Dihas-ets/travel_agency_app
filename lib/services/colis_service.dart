import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:code_initial/config/app_config.dart';
import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/models/colis_model.dart';

class ColisService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  /// Créer / Enregistrer un colis sur le backend Laravel (`POST /api/colis`)
  Future<Map<String, dynamic>> createColis({
    required int agenceDepotId,
    required int agenceRetraitId,
    required String expediteurNom,
    required String expediteurTel,
    required String destinataireNom,
    required String destinataireTel,
    required String modePaiement,
    required double valeurEstime,
    required List<Map<String, dynamic>> colisDetails,
    List<XFile?>? images,
  }) async {
    final uri = Uri.parse('$baseUrl/colis');
    final token = await AuthLocalStore.getToken();

    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['agence_depot_id'] = agenceDepotId.toString();
    request.fields['agence_retrait_id'] = agenceRetraitId.toString();
    request.fields['expediteur_nom'] = expediteurNom;
    request.fields['expediteur_tel'] = expediteurTel;
    request.fields['destinataire_nom'] = destinataireNom;
    request.fields['destinataire_tel1'] = destinataireTel;
    request.fields['mode_paiement'] = modePaiement;
    request.fields['valeur_estime'] = valeurEstime.toString();

    for (int i = 0; i < colisDetails.length; i++) {
      final detail = colisDetails[i];
      request.fields['colis_details[$i][nature]'] =
          detail['nature']?.toString() ?? 'Colis';
      request.fields['colis_details[$i][poids]'] = (detail['poids'] ?? 0)
          .toString();
      request.fields['colis_details[$i][nombre]'] = (detail['nombre'] ?? 1)
          .toString();
      request.fields['colis_details[$i][description]'] =
          detail['description']?.toString() ?? '';

      final image = (images != null && i < images.length) ? images[i] : null;
      if (image != null &&
          image.path.isNotEmpty &&
          File(image.path).existsSync()) {
        final multipartFile = await http.MultipartFile.fromPath(
          'colis_details[$i][image]',
          image.path,
        );
        request.files.add(multipartFile);
      }
    }

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 25),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final colisJson = data['colis'] as Map<String, dynamic>? ?? data;
        return {
          'success': true,
          'message': data['message'] ?? 'Colis enregistré avec succès.',
          'colis': ColisModel.fromJson(colisJson),
        };
      } else {
        String msg =
            data['message']?.toString() ??
            'Erreur lors de l\'enregistrement du colis.';
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
      return {
        'success': false,
        'message': 'Erreur de connexion au serveur : ${e.toString()}',
      };
    }
  }

  /// Historique client des colis (`GET /api/auth/client/colis/historique`)
  Future<List<ColisModel>> getHistoriqueClient({
    String? statut,
    int page = 1,
  }) async {
    final token = await AuthLocalStore.getToken();
    final queryParams = <String, String>{
      'page': page.toString(),
      if (statut != null && statut.isNotEmpty) 'statut': statut,
    };
    final uri = Uri.parse(
      '$baseUrl/auth/client/colis/historique',
    ).replace(queryParameters: queryParams);

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['data'] is List
          ? data['data']
          : (data is List ? data : []);
      return items
          .map((e) => ColisModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Erreur ${response.statusCode} lors du chargement de l\'historique colis.',
      );
    }
  }

  /// Suivi public d'un colis par sa référence (`GET /api/colis/show/{reference}`)
  Future<ColisModel?> showColis(String reference) async {
    final token = await AuthLocalStore.getToken();
    final uri = Uri.parse('$baseUrl/colis/show/$reference');

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final colisJson = data['colis'] as Map<String, dynamic>? ?? data;
      return ColisModel.fromJson(colisJson);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Erreur ${response.statusCode} lors du suivi du colis.');
    }
  }

  /// Récupérer la liste des configurations de tarifs de colis (`GET /api/configuration-colis?statut=actif`)
  Future<List<Map<String, dynamic>>> getConfigurations() async {
    final token = await AuthLocalStore.getToken();
    final uri = Uri.parse('$baseUrl/configuration-colis?statut=actif');

    final response = await http
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['data'] is List
          ? data['data']
          : (data is List ? data : []);
      return List<Map<String, dynamic>>.from(items);
    }
    return [];
  }
}
