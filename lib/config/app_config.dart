/// Configuration injectée au moment de la compilation.
///
/// Les secrets privés des agrégateurs ne doivent jamais être embarqués dans
/// l'application mobile. Ces valeurs sont uniquement destinées aux paramètres
/// publics nécessaires au SDK Flutter.
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const String feexPayApiKey = String.fromEnvironment(
    'FEEXPAY_API_KEY',
  );

  static const String feexPayShopId = String.fromEnvironment(
    'FEEXPAY_SHOP_ID',
  );

  // Alias conservés pour compatibilité avec le service existant.
  static const String feezpayApiKey = feexPayApiKey;
  static const String feezpayShopId = feexPayShopId;
}
