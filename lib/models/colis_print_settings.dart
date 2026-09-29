class ColisPrintSettings {
  final bool enabled;
  final String title;
  final String headerText;
  final String footerText;
  final String accentColor;
  final String width;
  final bool showBarcode;
  final String agencyName;
  final String? agencyLogo;
  final String telephone;
  final String email;
  final bool showEmetteur;
  final bool showContact;
  final bool showEnregistrePar;
  final bool showDgi;

  const ColisPrintSettings({
    required this.enabled,
    required this.title,
    required this.headerText,
    required this.footerText,
    required this.accentColor,
    required this.width,
    required this.showBarcode,
    required this.agencyName,
    required this.agencyLogo,
    required this.telephone,
    required this.email,
    required this.showEmetteur,
    required this.showContact,
    required this.showEnregistrePar,
    required this.showDgi,
  });

  factory ColisPrintSettings.fromMap(Map<String, dynamic> values) {
    bool booleanValue(String key, bool fallback) {
      final value = values[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        return value == '1' || value.toLowerCase() == 'true';
      }
      return fallback;
    }

    String stringValue(String key, String fallback) {
      final value = values[key]?.toString();
      return value == null || value.isEmpty ? fallback : value;
    }

    final primaryPhone = stringValue('general.telephone', '');
    final secondaryPhone = stringValue('general.telephoneSecondaire', '');
    final telephone = [
      if (primaryPhone.isNotEmpty) primaryPhone,
      if (secondaryPhone.isNotEmpty) secondaryPhone,
    ].join(' / ');

    return ColisPrintSettings(
      enabled: booleanValue('documents.bordereau_colis.enabled', true),
      title: stringValue(
        'documents.bordereau_colis.title',
        'Bordereau de colis',
      ),
      headerText: stringValue(
        'documents.bordereau_colis.headerText',
        stringValue('documents.bordereau_colis.title', 'Bordereau de colis'),
      ),
      footerText: stringValue(
        'documents.bordereau_colis.footerText',
        'Colis à retirer',
      ),
      accentColor: stringValue(
        'documents.bordereau_colis.accentColor',
        '#0f766e',
      ),
      width: stringValue('documents.bordereau_colis.width', '80mm') == '58mm'
          ? '58mm'
          : '80mm',
      showBarcode: booleanValue('documents.bordereau_colis.showBarcode', true),
      agencyName: stringValue('general.nomEntreprise', 'Fofana Voyage'),
      agencyLogo: values['branding.primaryLogo']?.toString(),
      telephone: telephone,
      email: stringValue('general.email', ''),
      showEmetteur: booleanValue(
        'documents.bordereau_colis.showEmetteur',
        true,
      ),
      showContact: booleanValue('documents.bordereau_colis.showContact', false),
      showEnregistrePar: booleanValue(
        'documents.bordereau_colis.showEnregistrePar',
        true,
      ),
      showDgi: booleanValue('documents.bordereau_colis.showDgi', true),
    );
  }
}
