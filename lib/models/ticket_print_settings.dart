class TicketPrintSettings {
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
  final bool showCancellationNotice;
  final int cancellationDelayDays;
  final int cancellationPenaltyPercent;

  const TicketPrintSettings({
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
    required this.showCancellationNotice,
    required this.cancellationDelayDays,
    required this.cancellationPenaltyPercent,
  });

  factory TicketPrintSettings.fromMap(Map<String, dynamic> values) {
    bool booleanValue(String key, bool fallback) {
      final value = values[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        return value == '1' || value.toLowerCase() == 'true';
      }
      return fallback;
    }

    int integerValue(String key, int fallback) {
      return int.tryParse(values[key]?.toString() ?? '') ?? fallback;
    }

    final configuredWidth = values['documents.ticket.width']?.toString();
    return TicketPrintSettings(
      enabled: booleanValue('documents.ticket.enabled', true),
      title: values['documents.ticket.title']?.toString() ?? 'Ticket de voyage',
      headerText:
          values['documents.ticket.headerText']?.toString() ?? 'Ticket de voyage',
      footerText: values['documents.ticket.footerText']?.toString() ??
          'Merci pour votre confiance',
      accentColor:
          values['documents.ticket.accentColor']?.toString() ?? '#2563eb',
      width: configuredWidth == '58mm' ? '58mm' : '80mm',
      showBarcode: booleanValue('documents.ticket.showBarcode', true),
      agencyName:
          values['general.nomEntreprise']?.toString() ?? 'Fofana Voyage',
      agencyLogo: values['branding.primaryLogo']?.toString(),
      telephone: _telephone(values),
      email: values['general.email']?.toString() ?? '',
      showEmetteur: booleanValue('documents.ticket.showEmetteur', true),
      showContact: booleanValue('documents.ticket.showContact', false),
      showEnregistrePar:
          booleanValue('documents.ticket.showEnregistrePar', true),
      showDgi: booleanValue('documents.ticket.showDgi', true),
      showCancellationNotice:
          booleanValue('documents.ticket.showCancellationNotice', true),
      cancellationDelayDays:
          integerValue('annulation.delai_jours', 1).clamp(0, 365),
      cancellationPenaltyPercent:
          integerValue('annulation.penalite_pourcent', 15).clamp(0, 100),
    );
  }

  static String _telephone(Map<String, dynamic> values) {
    final primary = values['general.telephone']?.toString() ?? '';
    final secondary = values['general.telephoneSecondaire']?.toString() ?? '';
    if (primary.isEmpty) return secondary;
    if (secondary.isEmpty) return primary;
    return '$primary / $secondary';
  }
}
