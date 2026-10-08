import 'dart:convert';

import 'package:fofanavoyage/config/app_config.dart';
import 'package:fofanavoyage/models/colis_print_settings.dart';
import 'package:http/http.dart' as http;

class ColisPrintSettingsService {
  static Future<ColisPrintSettings>? _settingsFuture;

  Future<ColisPrintSettings> getSettings() {
    return _settingsFuture ??= _loadSettings();
  }

  Future<ColisPrintSettings> _loadSettings() async {
    final response = await http
        .get(Uri.parse('${AppConfig.apiBaseUrl}/public/settings'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('Impossible de charger le bordereau colis.');
    }

    final decoded = jsonDecode(response.body);
    final settings = decoded is Map ? decoded['settings'] : null;
    if (settings is! Map) {
      throw Exception('Configuration du bordereau colis invalide.');
    }

    return ColisPrintSettings.fromMap(Map<String, dynamic>.from(settings));
  }
}
