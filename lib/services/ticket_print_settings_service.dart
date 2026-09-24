import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:code_initial/config/app_config.dart';
import 'package:code_initial/models/ticket_print_settings.dart';

class TicketPrintSettingsService {
  Future<TicketPrintSettings> getSettings() async {
    final response = await http
        .get(Uri.parse('${AppConfig.apiBaseUrl}/public/settings'))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Impossible de charger la configuration du billet.');
    }

    final decoded = jsonDecode(response.body);
    final settings = decoded is Map ? decoded['settings'] : null;
    if (settings is! Map) {
      throw Exception('Configuration du billet invalide.');
    }

    return TicketPrintSettings.fromMap(Map<String, dynamic>.from(settings));
  }
}
