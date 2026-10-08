/// Configuration injectée au moment de la compilation.
///
/// Les secrets privés des agrégateurs ne doivent jamais être embarqués dans
/// l'application mobile. Ces valeurs sont uniquement destinées aux paramètres
/// publics nécessaires au SDK Flutter.
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get apiBaseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:8000/api');

  static String get feexPayApiKey =>
      dotenv.get('FEEXPAY_API_KEY', fallback: '');

  static String get feexPayShopId =>
      dotenv.get('FEEXPAY_SHOP_ID', fallback: '');

  // Alias conservés pour compatibilité avec le service existant.
  static String get feezpayApiKey => feexPayApiKey;
  static String get feezpayShopId => feexPayShopId;
}
