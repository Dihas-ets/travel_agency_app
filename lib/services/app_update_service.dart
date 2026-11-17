import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:fofanavoyage/config/app_config.dart';

class AppUpdate {
  final String version;
  final String storeUrl;
  final String? releaseNotes;

  const AppUpdate({
    required this.version,
    required this.storeUrl,
    this.releaseNotes,
  });

  factory AppUpdate.fromJson(Map<String, dynamic> json) => AppUpdate(
    version: json['version']?.toString() ?? '',
    storeUrl: json['store_url']?.toString() ?? '',
    releaseNotes: json['release_notes']?.toString(),
  );
}

class AppUpdateService {
  Future<AppUpdate?> getAvailableUpdate() async {
    final platform = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
        ? 'ios'
        : null;
    if (platform == null) return null;

    final baseUrl = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/$'), '');
    final response = await http
        .get(
          Uri.parse('$baseUrl/public/app-updates/$platform'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw HttpException(
        'Échec de la vérification des mises à jour (${response.statusCode}).',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawUpdate = data['update'];
    if (rawUpdate is! Map) return null;

    final update = AppUpdate.fromJson(Map<String, dynamic>.from(rawUpdate));
    if (update.storeUrl.isEmpty ||
        update.version.isEmpty ||
        !await _isNewerVersion(update.version)) {
      return null;
    }
    return update;
  }

  Future<bool> _isNewerVersion(String availableVersion) async {
    final installedVersion = (await PackageInfo.fromPlatform()).version;
    final installed = _parseVersion(installedVersion);
    final available = _parseVersion(availableVersion);
    if (installed == null || available == null) return false;

    for (var index = 0; index < installed.length; index++) {
      if (available[index] != installed[index]) {
        return available[index] > installed[index];
      }
    }
    return false;
  }

  List<int>? _parseVersion(String version) {
    final parts = version.split('.');
    if (parts.length != 3) return null;
    final numbers = parts.map(int.tryParse).toList();
    if (numbers.any((part) => part == null)) return null;
    return numbers.cast<int>();
  }
}
