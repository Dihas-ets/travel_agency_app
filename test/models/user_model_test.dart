import 'package:flutter_test/flutter_test.dart';
import 'package:fofanavoyage/config/app_config.dart';
import 'package:fofanavoyage/models/user_model.dart';

void main() {
  String expectedStorageUrl(String path) {
    final apiUri = Uri.parse(AppConfig.apiBaseUrl);
    final basePath = apiUri.path.replaceFirst(RegExp(r'/api/?$'), '');
    return '${apiUri.scheme}://${apiUri.authority}$basePath/storage/$path';
  }

  group('UserModel.photoUrl', () {
    test('builds a public storage URL from a Laravel profile path', () {
      final user = UserModel.fromJson({
        'id': 1,
        'numero': '22900000000',
        'profil': 'profiles/avatar.jpg',
      });

      expect(user.photoUrl, expectedStorageUrl('profiles/avatar.jpg'));
    });

    test('replaces a local APP_URL host with the mobile API host', () {
      final user = UserModel.fromJson({
        'id': 1,
        'numero': '22900000000',
        'profil': 'http://localhost:8000/storage/profiles/avatar.jpg',
      });

      expect(user.photoUrl, expectedStorageUrl('profiles/avatar.jpg'));
    });

    test('uses photo_url when profil is empty', () {
      final user = UserModel.fromJson({
        'id': 1,
        'numero': '22900000000',
        'profil': '',
        'photo_url': 'http://localhost:8000/storage/profiles/avatar.jpg',
      });

      expect(user.photoUrl, expectedStorageUrl('profiles/avatar.jpg'));
    });
  });
}
