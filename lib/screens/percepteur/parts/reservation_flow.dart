import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fofanavoyage/models/models_and_stores.dart';
import 'package:fofanavoyage/models/ligne_model.dart';
import 'package:fofanavoyage/models/tax_group_model.dart';
import 'package:fofanavoyage/models/voyage_programme_model.dart';
import 'package:fofanavoyage/navigation.dart';
import 'package:fofanavoyage/services/ligne_service.dart';
import 'package:fofanavoyage/services/tax_service.dart';
import 'package:fofanavoyage/services/ticket_service.dart';
import 'package:fofanavoyage/services/affectation_service.dart';
import 'package:fofanavoyage/services/staff_ticket_service.dart';
import 'package:fofanavoyage/services/payment_service.dart';
import 'package:fofanavoyage/models/payment_provider_model.dart';
import 'package:fofanavoyage/services/feexpay_service.dart';
import 'package:fofanavoyage/services/kkiapay_service.dart';
import 'package:fofanavoyage/data/local/session_store.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fofanavoyage/screens/percepteur/parts/notifications_section.dart';
import 'package:fofanavoyage/screens/percepteur/parts/ticket_validation_section.dart';
import 'package:fofanavoyage/screens/percepteur/parts/assignments_section.dart';
import 'package:fofanavoyage/screens/percepteur/parts/percepteur_ticket_print_page.dart';
import 'package:fofanavoyage/screens/percepteur/parts/history_news_section.dart';

// Reservation percepteur: donnees, formulaire, paiement, billet et presence.

class _CityPickerSelection {
  const _CityPickerSelection({
    this.city,
    this.isFreeCity = false,
    this.isCurrentLocation = false,
    this.segmentStart,
    this.segmentEnd,
    this.assignedTrip,
  });

  final String? city;
  final bool isFreeCity;
  final bool isCurrentLocation;
  final String? segmentStart;
  final String? segmentEnd;
  final _AssignedTripDetails? assignedTrip;
}

class _AssignedTripDetails {
  const _AssignedTripDetails({
    required this.line,
    required this.trip,
    required this.departureTime,
  });

  final Ligne line;
  final VoyageProgramme trip;
  final String departureTime;
}

String formatPercepteurTicketDate(String value) {
  final normalized = value.trim();
  final dateMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(normalized);
  final dayFirstMatch = RegExp(
    r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$',
  ).firstMatch(normalized);
  final year = int.tryParse(
    dateMatch?.group(1) ?? dayFirstMatch?.group(3) ?? '',
  );
  final month = int.tryParse(
    dateMatch?.group(2) ?? dayFirstMatch?.group(2) ?? '',
  );
  final day = int.tryParse(
    dateMatch?.group(3) ?? dayFirstMatch?.group(1) ?? '',
  );
  if (year == null ||
      month == null ||
      day == null ||
      month < 1 ||
      month > 12 ||
      day < 1 ||
      day > DateTime(year, month + 1, 0).day) {
    return value;
  }

  const months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
  return '$day ${months[month - 1]} $year';
}

String formatPercepteurTicketTime(String value) {
  final normalized = value.trim();
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})(?::\d{2})?$',
  ).firstMatch(normalized);
  if (match == null) return value;
  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  if (hour == null || hour > 23 || minute == null || minute > 59) return value;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

String formatPercepteurMecefDate(String value) {
  final normalized = value.trim();
  final isoMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(normalized);
  if (isoMatch != null) {
    return '${isoMatch.group(3)}/${isoMatch.group(2)}/${isoMatch.group(1)}';
  }

  final localMatch = RegExp(
    r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})',
  ).firstMatch(normalized);
  if (localMatch != null) {
    return '${localMatch.group(1)!.padLeft(2, '0')}/'
        '${localMatch.group(2)!.padLeft(2, '0')}/'
        '${localMatch.group(3)}';
  }

  return normalized;
}

String formatPercepteurMecefTime(String value) {
  final match = RegExp(
    r'(?:T|\s)(\d{1,2}):(\d{2})(?::(\d{2}))?',
  ).firstMatch(value.trim());
  if (match == null) return 'Heure non renseignée';

  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  final second = int.tryParse(match.group(3) ?? '0');
  if (hour == null ||
      hour > 23 ||
      minute == null ||
      minute > 59 ||
      second == null ||
      second > 59) {
    return 'Heure non renseignée';
  }

  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}:'
      '${second.toString().padLeft(2, '0')}';
}

void _returnToPercepteurHistory(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const PercepteurHistoryPage()),
    (route) => route.isFirst,
  );
}

class PercepteurReservationRecord {
  final int? ticketId;
  final String reference;
  final String departure;
  final String destination;
  final String date;
  final String time;
  final int passengerCount;
  final String passengerName;
  final String phone;
  final String price;
  final String busMatricule;
  final String status;
  final String rawStatus;
  final String? paymentStatus;
  final int? ligneId;
  final int? voyageId;
  final int? busId;
  final int? userId;
  final DateTime? travelDate;
  final int? taxGroupId;
  final double? baseAmount;
  final double? taxAmount;
  final double? taxRate;
  final String? taxGroupLabel;
  final String? taxGroupCode;
  final bool enTrajet;
  final String? villeDepartEntreDebut;
  final String? villeDepartEntreFin;
  final String? villeArriveeEntreDebut;
  final String? villeArriveeEntreFin;
  final String? mecefCode;
  final String? mecefNim;
  final String? mecefCounters;
  final String? mecefDate;
  final String? mecefQrCode;
  final String issuerName;
  final String passengerFirstName;
  final String passengerLastName;

  bool get isPaid {
    final normalized = (paymentStatus ?? '').trim().toLowerCase().replaceAll(
      'é',
      'e',
    );
    return const {'paye', 'paid', 'success', 'successful'}.contains(normalized);
  }

  bool get canPrint => reference.isNotEmpty && isPaid;
  bool get canCancel => ticketId != null && rawStatus == 'en_cours';

  const PercepteurReservationRecord({
    this.ticketId,
    required this.reference,
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengerCount,
    required this.passengerName,
    required this.phone,
    required this.price,
    required this.busMatricule,
    required this.status,
    this.rawStatus = '',
    this.paymentStatus,
    this.ligneId,
    this.voyageId,
    this.busId,
    this.userId,
    this.travelDate,
    this.taxGroupId,
    this.baseAmount,
    this.taxAmount,
    this.taxRate,
    this.taxGroupLabel,
    this.taxGroupCode,
    this.mecefCode,
    this.mecefNim,
    this.mecefCounters,
    this.mecefDate,
    this.mecefQrCode,
    this.issuerName = '',
    this.passengerFirstName = '',
    this.passengerLastName = '',
    this.enTrajet = false,
    this.villeDepartEntreDebut,
    this.villeDepartEntreFin,
    this.villeArriveeEntreDebut,
    this.villeArriveeEntreFin,
  });

  PercepteurReservationRecord copyWith({
    int? ticketId,
    String? status,
    String? rawStatus,
    String? busMatricule,
    String? reference,
    double? baseAmount,
    double? taxAmount,
    double? taxRate,
    String? taxGroupLabel,
    String? taxGroupCode,
    String? mecefCode,
    String? mecefNim,
    String? mecefCounters,
    String? mecefDate,
    String? mecefQrCode,
    String? issuerName,
  }) {
    return PercepteurReservationRecord(
      ticketId: ticketId ?? this.ticketId,
      reference: reference ?? this.reference,
      departure: departure,
      destination: destination,
      date: date,
      time: time,
      passengerCount: passengerCount,
      passengerName: passengerName,
      phone: phone,
      price: price,
      busMatricule: busMatricule ?? this.busMatricule,
      status: status ?? this.status,
      rawStatus: rawStatus ?? this.rawStatus,
      paymentStatus: paymentStatus,
      ligneId: ligneId,
      voyageId: voyageId,
      busId: busId,
      userId: userId,
      travelDate: travelDate,
      taxGroupId: taxGroupId,
      baseAmount: baseAmount ?? this.baseAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      taxRate: taxRate ?? this.taxRate,
      taxGroupLabel: taxGroupLabel ?? this.taxGroupLabel,
      taxGroupCode: taxGroupCode ?? this.taxGroupCode,
      mecefCode: mecefCode ?? this.mecefCode,
      mecefNim: mecefNim ?? this.mecefNim,
      mecefCounters: mecefCounters ?? this.mecefCounters,
      mecefDate: mecefDate ?? this.mecefDate,
      mecefQrCode: mecefQrCode ?? this.mecefQrCode,
      issuerName: issuerName ?? this.issuerName,
      passengerFirstName: passengerFirstName,
      passengerLastName: passengerLastName,
      enTrajet: enTrajet,
      villeDepartEntreDebut: villeDepartEntreDebut,
      villeDepartEntreFin: villeDepartEntreFin,
      villeArriveeEntreDebut: villeArriveeEntreDebut,
      villeArriveeEntreFin: villeArriveeEntreFin,
    );
  }

  factory PercepteurReservationRecord.fromTicket(Map<String, dynamic> json) {
    final ligne = json['ligne'] is Map
        ? Map<String, dynamic>.from(json['ligne'] as Map)
        : <String, dynamic>{};
    final bus = json['bus'] is Map
        ? Map<String, dynamic>.from(json['bus'] as Map)
        : <String, dynamic>{};
    final voyage = json['voyage'] is Map
        ? Map<String, dynamic>.from(json['voyage'] as Map)
        : <String, dynamic>{};
    final date = (json['date_voyage'] ?? '').toString();
    final amount = double.tryParse(json['tarif_total']?.toString() ?? '') ?? 0;
    final firstName = json['prenom_passager']?.toString() ?? '';
    final lastName = json['nom_passager']?.toString() ?? '';
    final rawStatus = json['statut']?.toString() ?? 'en_attente';
    final rawTaxGroup = json['taxe_groupe'];
    final taxGroup = rawTaxGroup is Map
        ? Map<String, dynamic>.from(rawTaxGroup)
        : <String, dynamic>{};
    final rawMecef = json['mecef_response'];
    final mecef = rawMecef is Map
        ? Map<String, dynamic>.from(rawMecef)
        : <String, dynamic>{};
    final rawIssuer = json['emetteur'];
    final issuer = rawIssuer is Map
        ? Map<String, dynamic>.from(rawIssuer)
        : <String, dynamic>{};
    final mecefConfirmed = mecef['status']?.toString() == 'confirmed';
    return PercepteurReservationRecord(
      ticketId: int.tryParse(json['id']?.toString() ?? ''),
      reference: json['reference']?.toString() ?? '',
      departure:
          json['point_depart']?.toString() ??
          json['ville_depart']?.toString() ??
          ligne['trajet_depart']?.toString() ??
          '',
      destination:
          json['point_arrivee']?.toString() ??
          json['ville_arrivee']?.toString() ??
          ligne['trajet_arrivee']?.toString() ??
          '',
      date: date,
      time: (json['heure_voyage'] ?? voyage['heure_depart'] ?? '').toString(),
      passengerCount: int.tryParse(json['nbre_place']?.toString() ?? '') ?? 1,
      passengerName: '$firstName $lastName'.trim(),
      phone: json['numero_passager']?.toString() ?? '',
      price: '${amount.round()} CFA',
      busMatricule: bus['immatriculation']?.toString() ?? '',
      status: switch (rawStatus) {
        'en_cours' => 'Émis',
        'en_attente' => 'En attente',
        'annule' || 'annulé' => 'Annulé',
        'utilisé' ||
        'utilise' ||
        'valide' ||
        'embarque' ||
        'present' ||
        'présent' => 'Présent',
        'absent' => 'Absent',
        _ => rawStatus,
      },
      rawStatus: rawStatus,
      paymentStatus: json['statut_paiement']?.toString(),
      taxGroupId: int.tryParse(json['taxe_group_id']?.toString() ?? ''),
      baseAmount: double.tryParse(json['montant_base']?.toString() ?? ''),
      taxAmount: double.tryParse(json['montant_taxe']?.toString() ?? ''),
      taxRate: double.tryParse(json['taxe_taux']?.toString() ?? ''),
      taxGroupLabel: taxGroup['label']?.toString(),
      taxGroupCode: taxGroup['code']?.toString(),
      mecefCode: mecefConfirmed ? mecef['code_mecef']?.toString() : null,
      mecefNim: mecef['nim']?.toString(),
      mecefCounters: mecef['counters']?.toString(),
      mecefDate: mecef['date_mecef']?.toString(),
      mecefQrCode: mecef['qr_code']?.toString(),
      issuerName: '${issuer['prenom'] ?? ''} ${issuer['nom'] ?? ''}'.trim(),
      enTrajet:
          json['en_trajet'] == true || json['en_trajet']?.toString() == '1',
    );
  }

  Map<String, dynamic> toPrintMap() => {
    'reference': reference,
    'departure': departure,
    'destination': destination,
    'date': date,
    'time': time,
    'passengerCount': passengerCount,
    'passengerName': passengerName,
    'phone': phone,
    'price': price,
    'paymentStatus': paymentStatus,
    'baseAmount': baseAmount,
    'taxAmount': taxAmount ?? 0,
    'taxRate': taxRate ?? 0,
    'taxGroupLabel': taxGroupLabel,
    'taxGroupCode': taxGroupCode,
    'mecefCode': mecefCode,
    'mecefNim': mecefNim,
    'mecefCounters': mecefCounters,
    'mecefDate': mecefDate,
    'mecefQrCode': mecefQrCode,
    'issuerName': issuerName,
  };
}

class PercepteurReservationStore {
  static final List<PercepteurReservationRecord> reservations = [];
  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static PercepteurReservationRecord? get activeReservation {
    if (reservations.isEmpty) return null;
    return reservations.first;
  }

  static List<PercepteurReservationRecord> get historicalReservations {
    if (reservations.length <= 1) return [];
    return reservations.skip(1).toList();
  }

  static void add(PercepteurReservationRecord reservation) {
    reservations.insert(0, reservation);
    version.value += 1;
  }

  static void removeByTicketId(int ticketId) {
    reservations.removeWhere((reservation) => reservation.ticketId == ticketId);
    version.value += 1;
  }
}

class PercepteurReservationPage extends StatefulWidget {
  const PercepteurReservationPage({super.key});

  @override
  State<PercepteurReservationPage> createState() =>
      PercepteurReservationPageState();
}

class PercepteurReservationPageState extends State<PercepteurReservationPage> {
  static const Color _deepBlue = Color(0xFF0B4F2A);
  static const Color _fofanaGreen = Color(0xFF16A34A);

  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _enTrajet = false;
  bool _loadingAssignedTrip = false;
  int _manualFare = 0;
  String? _villeDepartEntreDebut;
  String? _villeDepartEntreFin;
  String? _villeArriveeEntreDebut;
  String? _villeArriveeEntreFin;
  int _passengerCount = 1;
  DateTime? _travelDate;
  List<Ligne> _lines = [];
  List<String> _destinations = [];
  Ligne? _selectedLigne;
  List<VoyageProgramme> _programmes = [];
  VoyageProgramme? _selectedVoyage;
  String? _selectedHeure;
  List<TaxGroup> _taxGroups = [];
  TaxGroup? _selectedTax;
  bool _loadingTrips = false;
  int? _placesAvailable;
  bool _checkingPlaces = false;
  String? _placesError;
  String? _routeError;
  int _programmesRequest = 0;
  int _placesRequest = 0;
  int? _cancellingTicketId;

  @override
  void initState() {
    super.initState();
    _loadReservationOptions();
  }

  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _cancelReservation(
    PercepteurReservationRecord reservation,
  ) async {
    final ticketId = reservation.ticketId;
    if (ticketId == null || _cancellingTicketId != null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler la réservation ?'),
        content: Text(
          'Voulez-vous annuler le ticket ${reservation.reference} ? '
          'Un avoir sera créé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Retour'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Annuler le ticket'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancellingTicketId = ticketId);
    try {
      final result = await StaffTicketService().annulerTicket(ticketId);
      PercepteurReservationStore.removeByTicketId(ticketId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Ticket annulé et avoir créé.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _cancellingTicketId = null);
    }
  }

  int get _fare {
    if (_enTrajet) return _manualFare * _passengerCount;
    final unit = _configuredSegmentFare;
    return unit == null ? 0 : (unit * _passengerCount).round();
  }

  double? get _configuredSegmentFare {
    final route = _selectedLigne;
    final departure = _departController.text.trim();
    final destination = _destinationController.text.trim();
    if (route == null || departure.isEmpty || destination.isEmpty) return null;

    double fareFor(Ligne line) =>
        _selectedVoyage?.busType.toLowerCase() == 'vip'
        ? (line.montantVip ?? line.montant)
        : line.montant;

    return fareFor(route) > 0 ? fareFor(route) : null;
  }

  String _normalizeRouteCity(String city) =>
      city.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  double get _baseAmount {
    final rate = _selectedTax?.rate ?? 0;
    final total = _currentAmount();
    return rate > 0
        ? (total / (1 + rate / 100)).roundToDouble()
        : total.toDouble();
  }

  bool get _canContinueToPassenger =>
      _selectedLigne != null &&
      _routeError == null &&
      _travelDate != null &&
      _selectedVoyage != null &&
      _selectedHeure != null &&
      !_loadingTrips &&
      !_checkingPlaces &&
      _placesError == null &&
      _placesAvailable != null &&
      _placesAvailable! >= _passengerCount &&
      _currentAmount() > 0;

  void _syncFareAmount() {
    final amount = _enTrajet ? _manualFare : _fare;
    _amountController.text = amount == 0 ? '' : _formatAmount(amount);
  }

  int _currentAmount() => _fare;

  Future<void> _loadReservationOptions() async {
    List<Ligne> lines = [];
    List<TaxGroup> groups = [];
    Object? cityError;
    Object? taxError;
    try {
      lines = await LigneService().getLignesPourReservation();
    } catch (error) {
      cityError = error;
    }
    try {
      groups = await TaxService().getGroupsForModule('ticket');
    } catch (error) {
      taxError = error;
    }
    if (!mounted) return;
    setState(() {
      _lines = lines;
      _taxGroups = groups;
      _selectedTax =
          groups.where((g) => g.appliesAsDefaultTo('ticket')).firstOrNull ??
          groups.firstOrNull;
    });
    final error = cityError ?? taxError;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cityError != null
                ? 'Impossible de charger les lignes : $cityError'
                : 'Impossible de charger les taxes : $taxError',
          ),
        ),
      );
    }
  }

  Future<void> _refreshRouteAndTrips() async {
    _enTrajet = false;
    _villeDepartEntreDebut = null;
    _villeDepartEntreFin = null;
    _villeArriveeEntreDebut = null;
    _villeArriveeEntreFin = null;
    final departure = _departController.text.trim();
    final destination = _destinationController.text.trim();
    _placesRequest++;
    if (departure.isEmpty || destination.isEmpty) {
      setState(() {
        _selectedLigne = null;
        _selectedVoyage = null;
        _selectedHeure = null;
        _programmes = [];
        _destinations = _destinationsFor(departure);
        _routeError = null;
        _placesAvailable = null;
        _placesError = null;
        _checkingPlaces = false;
        _amountController.clear();
      });
      return;
    }
    final departureKey = _normalizeRouteCity(departure);
    final destinationKey = _normalizeRouteCity(destination);
    final candidates = _lines
        .where((line) => _normalizeRouteCity(line.trajetDepart) == departureKey)
        .toList();
    final line =
        candidates
            .where(
              (item) =>
                  _normalizeRouteCity(item.trajetArrivee) == destinationKey,
            )
            .firstOrNull ??
        candidates
            .where((item) => item.servesDestination(destination))
            .firstOrNull;
    setState(() {
      _selectedLigne = line;
      _selectedVoyage = null;
      _selectedHeure = null;
      _programmes = [];
      _destinations = _destinationsFor(departure);
      _routeError = line == null
          ? 'Aucun itinéraire configuré pour ce trajet.'
          : null;
      _placesAvailable = null;
      _placesError = null;
      _checkingPlaces = false;
      _amountController.clear();
      _passengerCount = 1;
    });
    if (line != null && _travelDate != null) await _loadProgrammes();
  }

  List<String> _destinationsFor(String departure) {
    final arrivals = <String>{};
    for (final line in _lines.where(
      (line) =>
          _normalizeRouteCity(line.trajetDepart) ==
          _normalizeRouteCity(departure),
    )) {
      if (line.trajetArrivee.trim().isNotEmpty) {
        arrivals.add(line.trajetArrivee.trim());
      }
      for (final stage in line.villesEtapes) {
        final name = (stage['nom'] ?? stage['ville'] ?? stage['name'])
            ?.toString()
            .trim();
        if (name != null && name.isNotEmpty) arrivals.add(name);
      }
    }
    return arrivals.toList()..sort();
  }

  List<String> _routeStops(Ligne line) {
    final stops = <String>[line.trajetDepart.trim()];
    for (final stage in line.villesEtapes) {
      final name = (stage['nom'] ?? stage['ville'] ?? '').toString().trim();
      if (name.isNotEmpty &&
          _normalizeRouteCity(name) != _normalizeRouteCity(stops.last)) {
        stops.add(name);
      }
    }
    if (_normalizeRouteCity(line.trajetArrivee) !=
        _normalizeRouteCity(stops.last)) {
      stops.add(line.trajetArrivee.trim());
    }
    return stops.where((stop) => stop.isNotEmpty).toList();
  }

  Future<void> _setFallbackStopPosition(
    String city, {
    required bool departure,
    List<String>? segment,
  }) async {
    final line = _selectedLigne;
    if (line == null) throw Exception('La ligne du voyage est indisponible.');
    final stops = _routeStops(line);
    if (!_saveFallbackStopPosition(
      city,
      departure: departure,
      stops: stops,
      segment: segment,
    )) {
      throw Exception(
        'Choisissez les étapes de l’itinéraire qui encadrent « $city ».',
      );
    }
  }

  bool _saveFallbackStopPosition(
    String city, {
    required bool departure,
    required List<String> stops,
    List<String>? segment,
  }) {
    if (stops.any(
      (stop) => _normalizeRouteCity(stop) == _normalizeRouteCity(city),
    )) {
      setState(() {
        if (departure) {
          _villeDepartEntreDebut = null;
          _villeDepartEntreFin = null;
        } else {
          _villeArriveeEntreDebut = null;
          _villeArriveeEntreFin = null;
        }
      });
      return true;
    }

    if (segment == null ||
        segment.length != 2 ||
        !List.generate(stops.isNotEmpty ? stops.length - 1 : 0, (index) {
          return _normalizeRouteCity(stops[index]) ==
                  _normalizeRouteCity(segment[0]) &&
              _normalizeRouteCity(stops[index + 1]) ==
                  _normalizeRouteCity(segment[1]);
        }).contains(true)) {
      return false;
    }

    setState(() {
      if (departure) {
        _villeDepartEntreDebut = segment[0];
        _villeDepartEntreFin = segment[1];
      } else {
        _villeArriveeEntreDebut = segment[0];
        _villeArriveeEntreFin = segment[1];
      }
    });
    return true;
  }

  Future<_AssignedTripDetails> _loadAssignedTripDetails() async {
    final current = await AffectationService().getCurrentAssignedTrip();
    final rawVoyage = current['voyage'];
    if (rawVoyage is! Map) {
      throw Exception('Les informations du voyage affecté sont absentes.');
    }
    final voyageJson = Map<String, dynamic>.from(rawVoyage);
    final rawLine = voyageJson['ligne'];
    if (rawLine is! Map) {
      throw Exception('La ligne de votre affectation est indisponible.');
    }
    final line = Ligne.fromJson(Map<String, dynamic>.from(rawLine));
    final trip = VoyageProgramme.fromJson(voyageJson);
    final time = current['heure_depart']?.toString();
    if (line.id <= 0 || trip.id <= 0 || trip.busId <= 0 || time == null) {
      throw Exception('Le voyage affecté est incomplet.');
    }
    return _AssignedTripDetails(line: line, trip: trip, departureTime: time);
  }

  Future<bool> _startEnRouteFallback(
    String departure, {
    _AssignedTripDetails? assignedTrip,
    List<String>? departureSegment,
  }) async {
    var started = false;
    setState(() {
      _loadingAssignedTrip = true;
      _routeError = null;
    });
    try {
      final assigned = assignedTrip ?? await _loadAssignedTripDetails();
      if (!mounted) return false;
      final line = assigned.line;
      final trip = assigned.trip;
      final time = assigned.departureTime;

      final today = DateUtils.dateOnly(DateTime.now());
      setState(() {
        _enTrajet = true;
        _manualFare = 0;
        _amountController.clear();
        _selectedLigne = line;
        _selectedVoyage = trip;
        _programmes = [trip];
        _selectedHeure = time;
        _travelDate = today;
        _dateController.text =
            '${today.day.toString().padLeft(2, '0')} ${_monthName(today.month)} ${today.year}';
        _departController.text = departure;
        _destinationController.clear();
        _destinations = _routeStops(line);
        _routeError = null;
        _passengerCount = 1;
        _placesAvailable = null;
        _placesError = null;
      });
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return false;
      await _setFallbackStopPosition(
        departure,
        departure: true,
        segment: departureSegment,
      );
      started = true;
    } catch (error) {
      if (mounted) {
        setState(() {
          _enTrajet = false;
          _selectedLigne = null;
          _selectedVoyage = null;
          _selectedHeure = null;
          _travelDate = null;
          _routeError = error.toString().replaceFirst('Exception: ', '');
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_routeError!)));
      }
    } finally {
      if (mounted) setState(() => _loadingAssignedTrip = false);
    }
    return started;
  }

  Future<String> _getCurrentCity() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Activez la localisation du téléphone puis réessayez.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception(
        'Autorisez l’accès à la position dans les réglages du téléphone.',
      );
    }
    final position = await Geolocator.getCurrentPosition();
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final place = placemarks.firstOrNull;
    final city =
        [
              place?.locality,
              place?.subAdministrativeArea,
              place?.administrativeArea,
            ]
            .whereType<String>()
            .map((name) => name.trim())
            .firstWhere((name) => name.isNotEmpty, orElse: () => '');
    if (city.isEmpty) {
      throw Exception('Impossible de déterminer la ville à votre position.');
    }
    return city;
  }

  Future<void> _loadProgrammes() async {
    final date = _travelDate;
    if (date == null) return;
    final selectedLine = _selectedLigne;
    if (selectedLine == null) return;
    setState(() {
      _loadingTrips = true;
      _programmes = [];
      _selectedVoyage = null;
      _selectedLigne = selectedLine;
      _selectedHeure = null;
      _placesAvailable = null;
      _placesError = null;
      _routeError = null;
      _checkingPlaces = false;
      _passengerCount = 1;
      _amountController.clear();
      _syncFareAmount();
    });
    final request = ++_programmesRequest;
    try {
      final trips = await TicketService().getProgrammesParDate(
        ligneId: selectedLine.id,
        date: date,
        villeArrivee: _destinationController.text.trim(),
      );
      if (!mounted || request != _programmesRequest) return;
      setState(() {
        _programmes = trips;
        _loadingTrips = false;
      });
    } catch (error) {
      if (!mounted || request != _programmesRequest) return;
      setState(() => _loadingTrips = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de charger les départs : $error')),
      );
    }
  }

  Future<void> _checkPlaces() async {
    final trip = _selectedVoyage;
    final date = _travelDate;
    final time = _selectedHeure;
    if (trip == null || date == null || time == null) {
      _placesRequest++;
      if (mounted) {
        setState(() {
          _placesAvailable = null;
          _placesError = null;
          _checkingPlaces = false;
        });
      }
      return;
    }
    final request = ++_placesRequest;
    setState(() {
      _checkingPlaces = true;
      _placesError = null;
      _placesAvailable = null;
    });
    try {
      final places = await TicketService().getPlacesDisponibles(
        voyageId: trip.id,
        busId: trip.busId,
        date: date,
        heure: time,
        ligneId: _selectedLigne?.id,
        villeDepart: _enTrajet ? _departController.text.trim() : null,
        villeArrivee: _enTrajet ? _destinationController.text.trim() : null,
        villeDepartEntreDebut: _villeDepartEntreDebut,
        villeDepartEntreFin: _villeDepartEntreFin,
        villeArriveeEntreDebut: _villeArriveeEntreDebut,
        villeArriveeEntreFin: _villeArriveeEntreFin,
      );
      if (!mounted || request != _placesRequest) return;
      if (_selectedVoyage?.id != trip.id ||
          _travelDate != date ||
          _selectedHeure != time) {
        return;
      }
      setState(() {
        _placesAvailable = places;
        _checkingPlaces = false;
      });
    } catch (error) {
      if (!mounted || request != _placesRequest) return;
      if (_selectedVoyage?.id != trip.id ||
          _travelDate != date ||
          _selectedHeure != time) {
        return;
      }
      setState(() {
        _placesAvailable = null;
        _checkingPlaces = false;
        _placesError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _formatAmount(int amount) {
    final value = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final remaining = value.length - i;
      buffer.write(value[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateUtils.dateOnly(now);
    final lastDate = now.add(const Duration(days: 120));
    final date = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _fofanaGreen,
            onPrimary: Colors.white,
            onSurface: _deepBlue,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _fofanaGreen),
          ),
        ),
        child: child!,
      ),
    );

    if (date == null) return;
    setState(() {
      _travelDate = date;
      _dateController.text =
          '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}';
      _passengerCount = 1;
    });
    await _loadProgrammes();
  }

  void _selectVoyage(VoyageProgramme? trip) {
    setState(() {
      _selectedVoyage = trip;
      _selectedHeure = null;
      _placesAvailable = null;
      _placesError = null;
      _passengerCount = 1;
      _amountController.clear();
    });
  }

  Future<void> _showCityPicker({
    required String title,
    required TextEditingController controller,
  }) async {
    final isDeparture = identical(controller, _departController);
    final choices = isDeparture
        ? _lines
              .map((line) => line.trajetDepart.trim())
              .where((city) => city.isNotEmpty)
              .toSet()
              .toList()
        : _destinations;
    choices.sort();
    var freeCityName = '';
    var enteringFreeCity = false;
    var selectingCurrentLocation = false;
    List<String>? selectedSegment;
    _AssignedTripDetails? assignedTrip;
    var loadingAssignedTrip = false;
    String? assignedTripError;
    String? currentLocationCity;
    final line = _selectedLigne;
    var routeStops = line == null ? <String>[] : _routeStops(line);
    final selection = await showModalBottomSheet<_CityPickerSelection>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.8,
            ),
            child: Material(
              color: const Color(0xFFF8FBFF),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            enteringFreeCity ? 'Ville non enregistrée' : title,
                            style: const TextStyle(
                              color: _deepBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  if (enteringFreeCity)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: TextField(
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nom de la ville',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setSheetState(() {
                          freeCityName = value;
                          selectedSegment = null;
                        }),
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                      children: [
                        if (selectingCurrentLocation) ...[
                          if (loadingAssignedTrip)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (assignedTripError != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(assignedTripError!),
                            ),
                          if (currentLocationCity != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Ville détectée : $currentLocationCity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (!routeStops.any(
                              (stop) =>
                                  _normalizeRouteCity(stop) ==
                                  _normalizeRouteCity(currentLocationCity!),
                            )) ...[
                              const Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 4),
                                child: Text(
                                  'Choisissez le tronçon correspondant à votre position :',
                                ),
                              ),
                              ...List.generate(
                                routeStops.isNotEmpty
                                    ? routeStops.length - 1
                                    : 0,
                                (index) {
                                  final pair = [
                                    routeStops[index],
                                    routeStops[index + 1],
                                  ];
                                  final isSelected =
                                      selectedSegment != null &&
                                      _normalizeRouteCity(
                                            selectedSegment![0],
                                          ) ==
                                          _normalizeRouteCity(pair[0]) &&
                                      _normalizeRouteCity(
                                            selectedSegment![1],
                                          ) ==
                                          _normalizeRouteCity(pair[1]);
                                  return ListTile(
                                    selected: isSelected,
                                    leading: Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: _fofanaGreen,
                                    ),
                                    title: Text('${pair[0]} → ${pair[1]}'),
                                    onTap: () => setSheetState(() {
                                      selectedSegment = pair;
                                    }),
                                  );
                                },
                              ),
                            ],
                            FilledButton(
                              onPressed:
                                  (assignedTrip == null &&
                                          !_lines.any(
                                            (line) =>
                                                _normalizeRouteCity(
                                                  line.trajetDepart,
                                                ) ==
                                                _normalizeRouteCity(
                                                  currentLocationCity!,
                                                ),
                                          )) ||
                                      (!_lines.any(
                                            (line) =>
                                                _normalizeRouteCity(
                                                  line.trajetDepart,
                                                ) ==
                                                _normalizeRouteCity(
                                                  currentLocationCity!,
                                                ),
                                          ) &&
                                          !routeStops.any(
                                            (stop) =>
                                                _normalizeRouteCity(stop) ==
                                                _normalizeRouteCity(
                                                  currentLocationCity!,
                                                ),
                                          ) &&
                                          selectedSegment == null)
                                  ? null
                                  : () => Navigator.pop(
                                      sheetContext,
                                      _CityPickerSelection(
                                        city: currentLocationCity,
                                        isCurrentLocation: true,
                                        assignedTrip: assignedTrip,
                                        segmentStart: selectedSegment?[0],
                                        segmentEnd: selectedSegment?[1],
                                      ),
                                    ),
                              child: const Text('Continuer'),
                            ),
                          ],
                        ] else if (!enteringFreeCity) ...[
                          if (isDeparture)
                            _CityPickerAction(
                              icon: Icons.my_location_rounded,
                              title: 'Point actuel',
                              subtitle:
                                  'Utiliser la position GPS et votre affectation',
                              onTap: () async {
                                setSheetState(() {
                                  selectingCurrentLocation = true;
                                  loadingAssignedTrip = true;
                                  assignedTripError = null;
                                });
                                try {
                                  final city = await _getCurrentCity();
                                  if (!sheetContext.mounted) return;
                                  final isConfiguredDeparture = _lines.any(
                                    (line) =>
                                        _normalizeRouteCity(
                                          line.trajetDepart,
                                        ) ==
                                        _normalizeRouteCity(city),
                                  );
                                  final loaded = isConfiguredDeparture
                                      ? null
                                      : await _loadAssignedTripDetails();
                                  if (!sheetContext.mounted) return;
                                  setSheetState(() {
                                    currentLocationCity = city;
                                    assignedTrip = loaded;
                                    routeStops = loaded == null
                                        ? <String>[]
                                        : _routeStops(loaded.line);
                                    loadingAssignedTrip = false;
                                  });
                                } catch (error) {
                                  if (!sheetContext.mounted) return;
                                  setSheetState(() {
                                    loadingAssignedTrip = false;
                                    assignedTripError = error
                                        .toString()
                                        .replaceFirst('Exception: ', '');
                                  });
                                }
                              },
                            )
                          else
                            _CityPickerAction(
                              icon: Icons.edit_location_alt_outlined,
                              title: 'Saisir une ville non enregistrée',
                              subtitle: 'Pour un arrêt absent de la liste',
                              onTap: () async {
                                setSheetState(() {
                                  enteringFreeCity = true;
                                  loadingAssignedTrip = !_enTrajet;
                                  assignedTripError = null;
                                });
                                if (_enTrajet) return;
                                try {
                                  final loaded =
                                      await _loadAssignedTripDetails();
                                  if (!sheetContext.mounted) return;
                                  setSheetState(() {
                                    assignedTrip = loaded;
                                    routeStops = _routeStops(loaded.line);
                                    loadingAssignedTrip = false;
                                  });
                                } catch (error) {
                                  if (!sheetContext.mounted) return;
                                  setSheetState(() {
                                    loadingAssignedTrip = false;
                                    assignedTripError = error
                                        .toString()
                                        .replaceFirst('Exception: ', '');
                                  });
                                }
                              },
                            ),
                          if (choices.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                isDeparture
                                    ? 'Aucune ville de départ disponible.'
                                    : 'Choisissez d’abord une ville de départ.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ...choices.map(
                            (choice) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.location_on_outlined,
                                    color: _fofanaGreen,
                                  ),
                                  title: Text(choice),
                                  onTap: () => Navigator.pop(
                                    sheetContext,
                                    _CityPickerSelection(city: choice),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          if (loadingAssignedTrip)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (assignedTripError != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(assignedTripError!),
                            ),
                          if ((_enTrajet || assignedTrip != null) &&
                              freeCityName.trim().isNotEmpty &&
                              !routeStops.any(
                                (stop) =>
                                    _normalizeRouteCity(stop) ==
                                    _normalizeRouteCity(freeCityName),
                              )) ...[
                            if (routeStops.length < 2)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'L’itinéraire ne contient pas assez d’étapes pour encadrer cette ville.',
                                ),
                              )
                            else ...[
                              const Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 4),
                                child: Text(
                                  'Choisissez les deux étapes consécutives qui encadrent cette ville :',
                                ),
                              ),
                              ...List.generate(routeStops.length - 1, (index) {
                                final pair = [
                                  routeStops[index],
                                  routeStops[index + 1],
                                ];
                                final isSelected =
                                    selectedSegment != null &&
                                    _normalizeRouteCity(selectedSegment![0]) ==
                                        _normalizeRouteCity(pair[0]) &&
                                    _normalizeRouteCity(selectedSegment![1]) ==
                                        _normalizeRouteCity(pair[1]);
                                return ListTile(
                                  selected: isSelected,
                                  leading: Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: _fofanaGreen,
                                  ),
                                  title: Text('${pair[0]} → ${pair[1]}'),
                                  onTap: () => setSheetState(() {
                                    selectedSegment = pair;
                                  }),
                                );
                              }),
                            ],
                          ],
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () {
                              final city = freeCityName.trim();
                              if (city.isEmpty) return;
                              if (!_enTrajet && assignedTrip == null) return;
                              final known = routeStops.any(
                                (stop) =>
                                    _normalizeRouteCity(stop) ==
                                    _normalizeRouteCity(city),
                              );
                              if ((_enTrajet || assignedTrip != null) &&
                                  !known) {
                                if (selectedSegment == null) return;
                                Navigator.pop(
                                  sheetContext,
                                  _CityPickerSelection(
                                    city: city,
                                    isFreeCity: true,
                                    segmentStart: selectedSegment![0],
                                    segmentEnd: selectedSegment![1],
                                    assignedTrip: assignedTrip,
                                  ),
                                );
                              } else {
                                Navigator.pop(
                                  sheetContext,
                                  _CityPickerSelection(
                                    city: city,
                                    isFreeCity: true,
                                    assignedTrip: assignedTrip,
                                  ),
                                );
                              }
                            },
                            child: const Text('Continuer'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (selection == null || !mounted) return;
    if (selection.isCurrentLocation) {
      final city = selection.city;
      if (city == null || city.trim().isEmpty) return;
      final isConfiguredDeparture = _lines.any(
        (line) =>
            _normalizeRouteCity(line.trajetDepart) == _normalizeRouteCity(city),
      );
      if (isConfiguredDeparture) {
        setState(() {
          _departController.text = city;
          _destinationController.clear();
          _destinations = _destinationsFor(city);
        });
        await _refreshRouteAndTrips();
      } else {
        final segment =
            selection.segmentStart != null && selection.segmentEnd != null
            ? [selection.segmentStart!, selection.segmentEnd!]
            : null;
        await _startEnRouteFallback(
          city,
          assignedTrip: selection.assignedTrip,
          departureSegment: segment,
        );
      }
      return;
    }
    final city = selection.city;
    if (city == null || city.trim().isEmpty) return;
    if (selection.isFreeCity) {
      final alreadyEnTrajet = _enTrajet;
      if (identical(controller, _departController) && !alreadyEnTrajet) {
        final segment =
            selection.segmentStart != null && selection.segmentEnd != null
            ? [selection.segmentStart!, selection.segmentEnd!]
            : null;
        final started = await _startEnRouteFallback(
          city,
          assignedTrip: selection.assignedTrip,
          departureSegment: segment,
        );
        if (!started || !mounted) return;
        setState(() {
          controller.text = city;
          _destinationController.clear();
          _destinations = _routeStops(_selectedLigne!);
        });
        return;
      }
      if (!alreadyEnTrajet) {
        final isConfiguredDestination = _destinations.any(
          (destination) =>
              _normalizeRouteCity(destination) == _normalizeRouteCity(city),
        );
        if (isConfiguredDestination) {
          setState(() => controller.text = city);
          await _refreshRouteAndTrips();
          return;
        }
        final departure = _departController.text.trim();
        if (departure.isEmpty ||
            !await _startEnRouteFallback(
              departure,
              assignedTrip: selection.assignedTrip,
            ) ||
            !mounted) {
          return;
        }
      }
      setState(() {
        controller.text = city;
        _amountController.clear();
        _placesAvailable = null;
        _placesError = null;
      });
      try {
        if (selection.segmentStart != null && selection.segmentEnd != null) {
          final line = _selectedLigne;
          if (line == null ||
              !_saveFallbackStopPosition(
                city,
                departure: false,
                stops: _routeStops(line),
                segment: [selection.segmentStart!, selection.segmentEnd!],
              )) {
            throw Exception(
              'Impossible de situer cette ville sur l’itinéraire sélectionné.',
            );
          }
        } else if (alreadyEnTrajet) {
          final line = _selectedLigne;
          if (line != null) {
            _saveFallbackStopPosition(
              city,
              departure: false,
              stops: _routeStops(line),
            );
          }
        } else {
          final segment =
              selection.segmentStart != null && selection.segmentEnd != null
              ? [selection.segmentStart!, selection.segmentEnd!]
              : null;
          await _setFallbackStopPosition(
            city,
            departure: false,
            segment: segment,
          );
        }
        if (_selectedVoyage != null) await _checkPlaces();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceFirst('Exception: ', '')),
            ),
          );
        }
      }
      return;
    }
    setState(() {
      controller.text = city;
      if (identical(controller, _departController)) {
        _destinationController.clear();
        _destinations = _destinationsFor(city);
      }
      _amountController.clear();
    });
    if (_enTrajet) {
      try {
        final line = _selectedLigne;
        if (line != null &&
            _saveFallbackStopPosition(
              city,
              departure: false,
              stops: _routeStops(line),
            )) {
          await _checkPlaces();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceFirst('Exception: ', '')),
            ),
          );
        }
      }
    } else {
      await _refreshRouteAndTrips();
    }
  }

  Future<void> _confirmReservation() async {
    if (_selectedLigne == null ||
        _travelDate == null ||
        _selectedVoyage == null ||
        _selectedHeure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Choisissez un trajet, une date et un départ disponibles.',
          ),
        ),
      );
      return;
    }

    if (_placesAvailable != null && _placesAvailable! < _passengerCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nombre de places disponibles est insuffisant.'),
        ),
      );
      return;
    }
    if (_checkingPlaces || _placesAvailable == null || _placesError != null) {
      if (!_checkingPlaces) await _checkPlaces();
      if (!mounted) return;
      if (_placesAvailable == null || _placesError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _placesError ??
                  'Vérifiez la disponibilité des places avant de continuer.',
            ),
          ),
        );
        return;
      }
      if (_placesAvailable! < _passengerCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le nombre de places disponibles est insuffisant.'),
          ),
        );
        return;
      }
    }
    if (_currentAmount() <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le montant du ticket doit être supérieur à zéro.'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PercepteurPaymentDetailsPage(
          departure: _departController.text.trim(),
          destination: _destinationController.text.trim(),
          date:
              '${_travelDate!.day.toString().padLeft(2, '0')} ${_monthName(_travelDate!.month)} ${_travelDate!.year}',
          priceAmount: _currentAmount(),
          passengers: _passengerCount,
          time: _selectedHeure!,
          ligneId: _selectedLigne!.id,
          voyageId: _selectedVoyage!.id,
          busId: _selectedVoyage!.busId,
          busMatricule: _selectedVoyage!.busMatricule,
          travelDate: _travelDate!,
          taxGroupId: _selectedTax?.id,
          baseAmount: _baseAmount,
          taxAmount: _currentAmount() - _baseAmount,
          taxRate: _selectedTax?.rate ?? 0,
          taxGroupLabel: _selectedTax?.label,
          taxGroupCode: _selectedTax?.code,
          enTrajet: _enTrajet,
          villeDepartEntreDebut: _villeDepartEntreDebut,
          villeDepartEntreFin: _villeDepartEntreFin,
          villeArriveeEntreDebut: _villeArriveeEntreDebut,
          villeArriveeEntreFin: _villeArriveeEntreFin,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  String _monthName(int month) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/coli1.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0x99060E27),
                    BlendMode.darken,
                  ),
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PercepteurHeaderIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo_fofana_no_background.png',
                        height: 44,
                        width: 142,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Réserver un billet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Text(
                      'Réservation percepteur',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReservationForm(),
                    const SizedBox(height: 18),
                    if (PercepteurReservationStore.reservations.isNotEmpty)
                      ...PercepteurReservationStore.reservations.map(
                        (item) => PercepteurReservationCard(
                          item: item,
                          onCancel: item.canCancel
                              ? () => _cancelReservation(item)
                              : null,
                          isCancelling: _cancellingTicketId == item.ticketId,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '1. TRAJET & VOYAGE',
            style: TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _deepBlue.withValues(alpha: 0.07)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      PercepteurCityField(
                        controller: _departController,
                        label: 'De',
                        hint: 'Ville de départ',
                        isFirst: true,
                        onTap: () => _showCityPicker(
                          title: 'Choisir la ville de départ',
                          controller: _departController,
                        ),
                      ),
                      PercepteurCityField(
                        controller: _destinationController,
                        label: 'À',
                        hint: 'Ville de destination',
                        isFirst: false,
                        onTap: _departController.text.isEmpty
                            ? () {}
                            : () => _showCityPicker(
                                title: 'Choisir la ville d’arrivée',
                                controller: _destinationController,
                              ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 12,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton.filled(
                        tooltip: 'Inverser le départ et l’arrivée',
                        onPressed: _enTrajet
                            ? null
                            : () {
                                final departure = _departController.text;
                                final destination = _destinationController.text;
                                setState(() {
                                  _departController.text = destination;
                                  _destinationController.text = departure;
                                });
                                _refreshRouteAndTrips();
                              },
                        icon: const Icon(Icons.swap_vert_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_routeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _routeError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (_loadingAssignedTrip)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
            if (_enTrajet)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Voyage lié à votre affectation en cours. Ce ticket sera marqué « en trajet ».',
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (_enTrajet) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tarif par passager (CFA)',
                  prefixIcon: Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
                  setState(() => _manualFare = int.tryParse(normalized) ?? 0);
                },
              ),
            ],
            const SizedBox(height: 14),
          ],
          if (_selectedLigne != null)
            PercepteurSmallField(
              label: 'Date du voyage',
              value: _dateController.text.isEmpty
                  ? 'Sélectionner une date'
                  : _dateController.text,
              icon: Icons.calendar_month_rounded,
              onTap: _pickDate,
            ),
          if (_travelDate != null && _selectedLigne != null) ...[
            if (!_loadingTrips && _programmes.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Aucun voyage programmé pour cette date.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            DropdownButtonFormField<VoyageProgramme>(
              initialValue: _selectedVoyage,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Bus / Service',
                border: OutlineInputBorder(),
              ),
              hint: Text(_loadingTrips ? 'Chargement...' : 'Choisir un voyage'),
              items: _programmes.map((trip) {
                final route = '${trip.ligneDepart} → ${trip.ligneArrivee}';
                final label =
                    '${trip.busName.isEmpty ? 'Bus' : trip.busName}'
                    '${trip.busMatricule.isEmpty ? '' : ' • ${trip.busMatricule}'}'
                    '${route.trim().isEmpty ? '' : ' — $route'}';
                return DropdownMenuItem(
                  value: trip,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _selectVoyage,
            ),
            if (_selectedVoyage != null && _selectedLigne != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.alt_route_rounded,
                      color: _fofanaGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Itinéraire : ${_selectedLigne!.trajetDepart} → ${_selectedLigne!.trajetArrivee}',
                        style: const TextStyle(
                          color: _deepBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          if (_selectedVoyage != null && _selectedLigne != null) ...[
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _selectedHeure,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Heure de voyage',
                border: OutlineInputBorder(),
              ),
              items: _selectedVoyage!.heuresDepart
                  .map(
                    (time) => DropdownMenuItem(value: time, child: Text(time)),
                  )
                  .toList(),
              onChanged: (time) {
                setState(() {
                  _selectedHeure = time;
                  _placesAvailable = null;
                  _placesError = null;
                });
                if (_routeError == null &&
                    _departController.text.isNotEmpty &&
                    _destinationController.text.isNotEmpty) {
                  _checkPlaces();
                }
              },
            ),
          ],
          if (_selectedVoyage != null && _selectedLigne == null)
            const Text(
              'La ligne de ce voyage n’est pas disponible dans la configuration.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          if (_selectedHeure != null &&
              _departController.text.isNotEmpty &&
              _destinationController.text.isNotEmpty &&
              _routeError == null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ReservationChoiceInfo(
                    label: 'Type du bus',
                    value: _selectedVoyage!.busType.toLowerCase() == 'vip'
                        ? 'Climatisé (VIP)'
                        : 'Standard',
                    icon: Icons.directions_bus_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ReservationChoiceInfo(
                    label: 'Places disponibles',
                    value: _checkingPlaces
                        ? 'Vérification...'
                        : _placesAvailable == null
                        ? 'Non vérifiées'
                        : '$_placesAvailable / ${_selectedVoyage!.busCapacite}',
                    icon: Icons.event_seat_rounded,
                    isWarning:
                        _placesError != null ||
                        (_placesAvailable != null &&
                            _placesAvailable! < _passengerCount),
                  ),
                ),
              ],
            ),
            if (_placesError != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vérification impossible : $_placesError',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Réessayer',
                    onPressed: _checkPlaces,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ],
          ],
          if (_selectedHeure != null &&
              _placesAvailable != null &&
              _placesAvailable! > 0 &&
              _taxGroups.isNotEmpty)
            DropdownButtonFormField<TaxGroup>(
              initialValue: _selectedTax,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Taxe applicable',
                border: OutlineInputBorder(),
              ),
              items: _taxGroups
                  .map(
                    (group) => DropdownMenuItem(
                      value: group,
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          '${group.label} (${group.rate}%)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (group) {
                setState(() {
                  _selectedTax = group;
                  _syncFareAmount();
                });
              },
            ),
          if (_selectedHeure != null &&
              _placesAvailable != null &&
              _placesAvailable! > 0) ...[
            PercepteurPassengerCard(
              count: _passengerCount,
              onMinus: () {
                if (_passengerCount > 1) {
                  setState(() {
                    _passengerCount -= 1;
                    _syncFareAmount();
                  });
                }
              },
              onPlus: () {
                if (_placesAvailable != null &&
                    _passengerCount < _placesAvailable!) {
                  setState(() {
                    _passengerCount += 1;
                    _syncFareAmount();
                  });
                }
              },
            ),
          ],
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _canContinueToPassenger ? _confirmReservation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _fofanaGreen,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Suivant : informations du passager',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityPickerAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CityPickerAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFEAF7EE),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF16A34A)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      onTap: onTap,
    ),
  );
}

class PercepteurCityField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isFirst;
  final VoidCallback onTap;

  const PercepteurCityField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 68, 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: isFirst
                ? BorderSide(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF16A34A),
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF5F6B86),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    controller.text.isEmpty ? hint : controller.text,
                    style: const TextStyle(
                      color: Color(0xFF0B4F2A),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PercepteurSmallField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const PercepteurSmallField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: deepBlue.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(icon, size: 18, color: deepBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: deepBlue,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationChoiceInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;

  const _ReservationChoiceInfo({
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? const Color(0xFFE53935) : const Color(0xFF0B4F2A);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFF3F2) : const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PercepteurPassengerCard extends StatelessWidget {
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const PercepteurPassengerCard({
    super.key,
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: deepBlue.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: deepBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded, color: deepBlue, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Passager(s)',
                  style: TextStyle(
                    color: Color(0xFF5F6B86),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sélectionnez le nombre de voyageurs',
                  style: TextStyle(
                    color: Color(0xFF7F8BAA),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          PercepteurStepperButton(icon: Icons.remove, onTap: onMinus),
          const SizedBox(width: 10),
          Text(
            '$count',
            style: const TextStyle(
              color: deepBlue,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          PercepteurStepperButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class PercepteurStepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const PercepteurStepperButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF0B4F2A).withValues(alpha: 0.18),
          ),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF0B4F2A)),
      ),
    );
  }
}

class PercepteurPaymentDetailsPage extends StatefulWidget {
  final String departure;
  final String destination;
  final String date;
  final int priceAmount;
  final int passengers;
  final String time;
  final int ligneId;
  final int voyageId;
  final int busId;
  final String busMatricule;
  final DateTime travelDate;
  final int? taxGroupId;
  final double baseAmount;
  final double taxAmount;
  final double taxRate;
  final String? taxGroupLabel;
  final String? taxGroupCode;
  final bool enTrajet;
  final String? villeDepartEntreDebut;
  final String? villeDepartEntreFin;
  final String? villeArriveeEntreDebut;
  final String? villeArriveeEntreFin;

  const PercepteurPaymentDetailsPage({
    super.key,
    required this.departure,
    required this.destination,
    required this.date,
    required this.priceAmount,
    required this.passengers,
    required this.ligneId,
    required this.voyageId,
    required this.busId,
    required this.busMatricule,
    required this.travelDate,
    required this.baseAmount,
    required this.taxAmount,
    required this.taxRate,
    this.taxGroupLabel,
    this.taxGroupCode,
    this.taxGroupId,
    this.enTrajet = false,
    this.villeDepartEntreDebut,
    this.villeDepartEntreFin,
    this.villeArriveeEntreDebut,
    this.villeArriveeEntreFin,
    required this.time,
  });

  @override
  State<PercepteurPaymentDetailsPage> createState() =>
      PercepteurPaymentDetailsPageState();
}

class PercepteurPaymentDetailsPageState
    extends State<PercepteurPaymentDetailsPage> {
  final TextEditingController _requesterPhoneController =
      TextEditingController();
  final TextEditingController _passengerNameController =
      TextEditingController();
  final List<Map<String, dynamic>> _suggestions = [];
  Timer? _searchTimer;
  int? _selectedUserId;
  String? _selectedFirstName;
  String? _selectedLastName;
  bool _searching = false;
  int _passengerSearchRequest = 0;
  String? _passengerSearchError;

  @override
  void dispose() {
    _requesterPhoneController.dispose();
    _passengerNameController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _finishReservation() {
    final phone = _requesterPhoneController.text.trim();
    final passenger = _passengerNameController.text.trim();

    if (phone.isEmpty || passenger.split(RegExp(r'\s+')).length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Saisissez le prénom, le nom et le téléphone du passager.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PercepteurPaymentChoicePage(
          reservation: _buildReservation(
            passengerName: passenger,
            phone: phone,
            status: 'En attente paiement',
          ),
          priceAmount: widget.priceAmount,
        ),
      ),
    );
  }

  PercepteurReservationRecord _buildReservation({
    required String passengerName,
    required String phone,
    required String status,
  }) {
    return PercepteurReservationRecord(
      reference: '',
      departure: widget.departure,
      destination: widget.destination,
      date: widget.date,
      time: widget.time,
      passengerCount: widget.passengers,
      passengerName: passengerName,
      phone: phone,
      price: '${_formatAmount(widget.priceAmount)} CFA',
      busMatricule: widget.busMatricule,
      status: status,
      rawStatus: status.startsWith('Confirmée') ? 'en_cours' : 'en_attente',
      ligneId: widget.ligneId,
      voyageId: widget.voyageId,
      busId: widget.busId,
      userId: _selectedUserId,
      travelDate: widget.travelDate,
      taxGroupId: widget.taxGroupId,
      baseAmount: widget.baseAmount,
      taxAmount: widget.taxAmount,
      taxRate: widget.taxRate,
      taxGroupLabel: widget.taxGroupLabel,
      taxGroupCode: widget.taxGroupCode,
      passengerFirstName:
          _selectedFirstName ??
          _passengerNameController.text.trim().split(RegExp(r'\s+')).first,
      passengerLastName:
          _selectedLastName ??
          _passengerNameController.text
              .trim()
              .split(RegExp(r'\s+'))
              .skip(1)
              .join(' '),
      enTrajet: widget.enTrajet,
      villeDepartEntreDebut: widget.villeDepartEntreDebut,
      villeDepartEntreFin: widget.villeDepartEntreFin,
      villeArriveeEntreDebut: widget.villeArriveeEntreDebut,
      villeArriveeEntreFin: widget.villeArriveeEntreFin,
    );
  }

  void _searchPassenger(String value) {
    _selectedUserId = null;
    _selectedFirstName = null;
    _selectedLastName = null;
    _searchTimer?.cancel();
    final query = value.trim();
    final request = ++_passengerSearchRequest;
    setState(() {
      _suggestions.clear();
      _searching = false;
      _passengerSearchError = null;
    });
    if (query.isEmpty) {
      return;
    }
    _searchTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() {
        _searching = true;
        _passengerSearchError = null;
      });
      try {
        final results = await TicketService().searchClients(query);
        if (!mounted ||
            request != _passengerSearchRequest ||
            query != _passengerNameController.text.trim()) {
          return;
        }
        setState(() {
          _suggestions
            ..clear()
            ..addAll(results);
          _searching = false;
        });
      } catch (error) {
        if (!mounted ||
            request != _passengerSearchRequest ||
            query != _passengerNameController.text.trim()) {
          return;
        }
        setState(() {
          _searching = false;
          _passengerSearchError = error.toString().replaceFirst(
            'Exception: ',
            '',
          );
        });
      }
    });
  }

  void _selectPassenger(Map<String, dynamic> user) {
    _passengerSearchRequest++;
    _searchTimer?.cancel();
    final phone = user['numero']?.toString() ?? '';
    setState(() {
      _searching = false;
      _selectedUserId = int.tryParse(user['id']?.toString() ?? '');
      _selectedFirstName = user['prenom']?.toString() ?? '';
      _selectedLastName = user['nom']?.toString() ?? '';
      _passengerNameController.text =
          '${user['prenom'] ?? ''} ${user['nom'] ?? ''}'.trim();
      _requesterPhoneController.text = phone.startsWith('+')
          ? phone
          : phone.startsWith('229')
          ? '+$phone'
          : '+229$phone';
      _suggestions.clear();
      _passengerSearchError = null;
    });
  }

  String _formatAmount(int amount) {
    final value = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final remaining = value.length - i;
      buffer.write(value[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Informations du passager',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '2. PASSAGER',
                style: TextStyle(
                  color: Color(0xFF5F6B86),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              PercepteurTripSummaryCard(
                departure: widget.departure,
                destination: widget.destination,
                date: widget.date,
                time: widget.time,
                passengerCount: widget.passengers,
                price: '${_formatAmount(widget.priceAmount)} CFA',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passengerNameController,
                onChanged: _searchPassenger,
                decoration: InputDecoration(
                  labelText: 'Nom et prénom du passager',
                  prefixIcon: const Icon(Icons.person_rounded),
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: _suggestions.map((user) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          '${user['prenom'] ?? ''} ${user['nom'] ?? ''}'.trim(),
                        ),
                        subtitle: Text(user['numero']?.toString() ?? ''),
                        onTap: () => _selectPassenger(user),
                      );
                    }).toList(),
                  ),
                ),
              if (_passengerSearchError != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _passengerSearchError!,
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              PercepteurTextInput(
                controller: _requesterPhoneController,
                label: 'Téléphone du passager',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _finishReservation,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Suivant : mode de paiement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PercepteurPaymentChoicePage extends StatefulWidget {
  final PercepteurReservationRecord reservation;
  final int priceAmount;

  const PercepteurPaymentChoicePage({
    super.key,
    required this.reservation,
    required this.priceAmount,
  });

  @override
  State<PercepteurPaymentChoicePage> createState() =>
      PercepteurPaymentChoicePageState();
}

class PercepteurPaymentChoicePageState
    extends State<PercepteurPaymentChoicePage> {
  String _mode = 'cash';
  List<PaymentProvider> _providers = [];
  PaymentProvider? _selectedProvider;
  String? _selectedMethod;
  String? _ticketReference;
  bool _loadingProviders = true;
  bool _processing = false;
  bool _checkingPayment = false;
  bool _useMecef = true;
  Timer? _pollTimer;
  String? _paymentMessage;
  Map<String, dynamic>? _issuedTicketData;

  static const Color _deepBlue = Color(0xFF0B4F2A);

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    try {
      final providers = await PaymentService().getProvidersActifs();
      if (!mounted) return;
      final available = providers
          .where((provider) => provider.configured)
          .toList();
      setState(() {
        _providers = available;
        _selectedProvider = available.firstOrNull;
        _selectedMethod = _selectedProvider?.methods.keys.firstOrNull;
        _loadingProviders = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadingProviders = false;
          _paymentMessage =
              'Impossible de charger les moyens de paiement : $error';
        });
      }
    }
  }

  Future<void> _confirmCash() async {
    await _emitTicket('ESPECES');
  }

  Future<void> _startMobilePayment() async {
    final provider = _selectedProvider;
    final method = _selectedMethod;
    if (provider == null || method == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez un moyen de paiement.')),
      );
      return;
    }
    if (_ticketReference == null) {
      await _emitTicket('MOBILEMONEY', continueToPayment: true);
      return;
    }
    await _initiatePayment(provider, method);
  }

  Future<void> _emitTicket(
    String modePaiement, {
    bool continueToPayment = false,
    bool accessRetry = false,
  }) async {
    if (_processing || _ticketReference != null) return;
    final draft = widget.reservation;
    if (draft.ligneId == null ||
        draft.voyageId == null ||
        draft.busId == null ||
        draft.travelDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les informations du voyage sont incomplètes.'),
        ),
      );
      return;
    }
    setState(() {
      _processing = true;
      _paymentMessage = null;
    });
    try {
      final trip = await TicketService().getProgrammationParDate(
        ligneId: draft.ligneId!,
        date: draft.travelDate!,
        voyageId: draft.voyageId!,
        villeArrivee: draft.enTrajet ? null : draft.destination,
      );
      final selectedTime = draft.time.length > 5
          ? draft.time.substring(0, 5)
          : draft.time;
      if (trip == null ||
          trip.busId != draft.busId ||
          !trip.heuresDepart.any(
            (time) => time.length > 5
                ? time.substring(0, 5) == selectedTime
                : time == selectedTime,
          )) {
        throw Exception(
          'Ce départ n’est plus disponible. Choisissez un autre voyage.',
        );
      }
      final availablePlaces = await TicketService().getPlacesDisponibles(
        voyageId: trip.id,
        busId: trip.busId,
        date: draft.travelDate!,
        heure: selectedTime,
        ligneId: draft.ligneId,
        villeDepart: draft.enTrajet ? draft.departure : null,
        villeArrivee: draft.enTrajet ? draft.destination : null,
        villeDepartEntreDebut: draft.villeDepartEntreDebut,
        villeDepartEntreFin: draft.villeDepartEntreFin,
        villeArriveeEntreDebut: draft.villeArriveeEntreDebut,
        villeArriveeEntreFin: draft.villeArriveeEntreFin,
      );
      if (availablePlaces < draft.passengerCount) {
        throw Exception('Le nombre de places disponibles est insuffisant.');
      }
      final response = await TicketService().storeTicket(
        ligneId: draft.ligneId!,
        voyageId: trip.id,
        busId: trip.busId,
        dateVoyage: draft.travelDate!,
        heureVoyage: selectedTime,
        tiers: true,
        nomPassager: draft.passengerLastName,
        prenomPassager: draft.passengerFirstName,
        numeroPassager: draft.phone,
        userId: draft.userId,
        nbrePlace: draft.passengerCount,
        taxGroupId: draft.taxGroupId,
        villeDepart: draft.enTrajet ? draft.departure : null,
        villeArrivee: draft.enTrajet ? draft.destination : null,
        villeDepartEntreDebut: draft.villeDepartEntreDebut,
        villeDepartEntreFin: draft.villeDepartEntreFin,
        villeArriveeEntreDebut: draft.villeArriveeEntreDebut,
        villeArriveeEntreFin: draft.villeArriveeEntreFin,
        enTrajet: draft.enTrajet,
        montantBase: draft.baseAmount,
        montantManuel: widget.priceAmount.toDouble(),
        montantTaxe: draft.taxAmount,
        taxeTaux: draft.taxRate,
        modePaiement: modePaiement,
        useMecef: _useMecef,
      );
      final ticket = response['ticket'] is Map
          ? Map<String, dynamic>.from(response['ticket'] as Map)
          : response;
      _issuedTicketData = ticket;
      final reference = ticket['reference']?.toString();
      if (reference == null || reference.isEmpty) {
        throw Exception('La référence du ticket est absente.');
      }
      if (!mounted) return;
      setState(() {
        _ticketReference = reference;
        _processing = false;
      });
      if (continueToPayment) {
        await _initiatePayment(_selectedProvider!, _selectedMethod!);
      } else {
        _completeReservation(
          'Confirmée - Espèces',
          reference: reference,
          ticketData: ticket,
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _processing = false);
      if (!accessRetry &&
          error.toString().contains('Votre section est fermée.')) {
        final sessionActivated = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) =>
                const PercepteurConnectionPage(closeOnActivation: true),
          ),
        );
        if (!mounted) return;
        if (sessionActivated == true) {
          await _emitTicket(
            modePaiement,
            continueToPayment: continueToPayment,
            accessRetry: true,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'La réservation nécessite une session active. Activez votre code puis réessayez.',
              ),
            ),
          );
        }
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _initiatePayment(PaymentProvider provider, String method) async {
    if (_ticketReference == null || _processing) return;
    setState(() {
      _processing = true;
      _paymentMessage = null;
    });
    try {
      final result = await PaymentService().initierPaiement(
        payableRef: _ticketReference!,
        provider: provider.slug,
        method: method,
        payableType: 'ticket',
        clientEmail: SessionStore.currentUser?.email,
      );
      if (!mounted) return;
      final transaction = result['transaction'] as Map<String, dynamic>?;
      final transactionReference = transaction?['reference']?.toString();
      if (transactionReference == null || transactionReference.isEmpty) {
        throw Exception('La référence de transaction est absente.');
      }
      final activeProvider = result['provider']?.toString() ?? provider.slug;
      if (activeProvider == 'feexpay') {
        await FeexPayService.openPayment(
          context: context,
          amount:
              num.tryParse(result['amount']?.toString() ?? '') ??
              widget.priceAmount,
          token: result['token']?.toString() ?? '',
          shopId:
              result['shop_id']?.toString() ??
              result['public_key']?.toString() ??
              '',
          reference: transactionReference,
          onResult: (paymentResult) async {
            if (paymentResult.isSuccess) {
              _pollPayment(
                transactionReference,
                externalId: paymentResult.reference,
              );
            } else if (mounted) {
              setState(() => _processing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    paymentResult.message ??
                        'Le paiement n’a pas été confirmé.',
                  ),
                ),
              );
            }
          },
        );
        return;
      }
      if (activeProvider == 'kkiapay') {
        final customer = result['customer'] as Map<String, dynamic>?;
        final externalId = await KkiapayService.openPayment(
          context: context,
          amount:
              int.tryParse(result['amount']?.toString() ?? '') ??
              widget.priceAmount,
          publicKey: result['public_key']?.toString() ?? '',
          sandbox: result['environment']?.toString() != 'live',
          reference: transactionReference,
          phone: customer?['phone']?.toString() ?? widget.reservation.phone,
          name: widget.reservation.passengerName,
          email: customer?['email']?.toString(),
        );
        if (externalId == null || externalId.isEmpty) {
          if (mounted) setState(() => _processing = false);
          return;
        }
        _pollPayment(transactionReference, externalId: externalId);
        return;
      }
      final paymentUrl = result['payment_url']?.toString();
      if (paymentUrl == null || paymentUrl.isEmpty) {
        throw Exception('Le prestataire n’a pas fourni de page de paiement.');
      }
      final opened = await launchUrl(
        Uri.parse(paymentUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) throw Exception('Impossible d’ouvrir la page de paiement.');
      _pollPayment(transactionReference);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _paymentMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _pollPayment(String reference, {String? externalId}) {
    _pollTimer?.cancel();
    var attempts = 0;
    var currentExternalId = externalId;
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_checkingPayment) return;
      if (++attempts > 45) {
        timer.cancel();
        setState(() {
          _processing = false;
          _paymentMessage =
              'Délai dépassé. Vérifiez le statut du ticket dans votre historique.';
        });
        return;
      }
      _checkingPayment = true;
      try {
        final result = await PaymentService().verifierPaiement(
          reference: reference,
          payableType: 'ticket',
          externalId: currentExternalId,
        );
        currentExternalId = null;
        if (result['verified'] == true) {
          timer.cancel();
          _completeReservation(
            'Confirmée - Mobile Money',
            reference: _ticketReference,
            ticketData: result['payable'] is Map
                ? Map<String, dynamic>.from(result['payable'] as Map)
                : _issuedTicketData,
          );
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            _paymentMessage =
                'La vérification du paiement a échoué : '
                '${error.toString().replaceFirst('Exception: ', '')}';
          });
        }
      } finally {
        _checkingPayment = false;
      }
    });
  }

  void _completeReservation(
    String status, {
    String? reference,
    Map<String, dynamic>? ticketData,
  }) {
    final reservation = widget.reservation.copyWith(
      ticketId: int.tryParse(ticketData?['id']?.toString() ?? ''),
      reference: reference ?? _ticketReference,
      status: status,
      rawStatus: ticketData?['statut']?.toString() ?? 'en_cours',
      baseAmount: _number(ticketData?['montant_base']),
      taxAmount: _number(ticketData?['montant_taxe']),
      taxRate: _number(ticketData?['taxe_taux']),
      taxGroupLabel: _map(ticketData?['taxe_groupe'])['label']?.toString(),
      taxGroupCode: _map(ticketData?['taxe_groupe'])['code']?.toString(),
      mecefCode: _confirmedMecef(ticketData)?['code_mecef']?.toString(),
      mecefNim: _map(ticketData?['mecef_response'])['nim']?.toString(),
      mecefCounters: _map(
        ticketData?['mecef_response'],
      )['counters']?.toString(),
      mecefDate: _map(ticketData?['mecef_response'])['date_mecef']?.toString(),
      mecefQrCode: _map(ticketData?['mecef_response'])['qr_code']?.toString(),
      issuerName: _issuerName(ticketData?['emetteur']),
    );
    PercepteurReservationStore.add(reservation);
    PercepteurNotificationStore.add(
      title: 'Réservation confirmée',
      message:
          '${reservation.passengerName} - ${reservation.departure} vers ${reservation.destination}.',
    );

    final navigator = Navigator.of(context);
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => PercepteurTicketPrintPage(
          ticket: reservation.toPrintMap(),
          onReturnToHome: () => navigator.pushNamedAndRemoveUntil(
            Routes.PERCEPTEUR_HOME,
            (route) => false,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};

  Map<String, dynamic>? _confirmedMecef(Map<String, dynamic>? ticket) {
    final mecef = _map(ticket?['mecef_response']);
    return mecef['status']?.toString() == 'confirmed' ? mecef : null;
  }

  double? _number(Object? value) => double.tryParse(value?.toString() ?? '');

  String _issuerName(Object? value) {
    final issuer = _map(value);
    return '${issuer['prenom'] ?? ''} ${issuer['nom'] ?? ''}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        backgroundColor: _deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Paiement',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '3. MODE DE PAIEMENT',
                style: TextStyle(
                  color: Color(0xFF5F6B86),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              PercepteurTripSummaryCard(
                departure: widget.reservation.departure,
                destination: widget.reservation.destination,
                date: widget.reservation.date,
                time: widget.reservation.time,
                passengerCount: widget.reservation.passengerCount,
                price: widget.reservation.price,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Mode de règlement',
                      style: TextStyle(
                        color: _deepBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Certification du ticket',
                      style: TextStyle(
                        color: _deepBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _useMecef,
                      title: Text(
                        _useMecef ? 'Avec MECeF' : 'Sans MECeF',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        _useMecef
                            ? 'Le ticket sera envoyé à MECeF.'
                            : 'Le ticket utilisera son QR code de référence.',
                      ),
                      onChanged: _ticketReference == null
                          ? (value) => setState(() => _useMecef = value)
                          : null,
                      activeTrackColor: const Color(0xFF16A34A),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: PercepteurModeButton(
                            label: 'Cash',
                            icon: Icons.payments_rounded,
                            selected: _mode == 'cash',
                            onTap: () {
                              if (_ticketReference == null) {
                                setState(() => _mode = 'cash');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PercepteurModeButton(
                            label: 'Mobile Money',
                            icon: Icons.phone_android_rounded,
                            selected: _mode == 'mobilemoney',
                            onTap: () {
                              if (_ticketReference == null) {
                                setState(() => _mode = 'mobilemoney');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_mode == 'cash')
                      PercepteurCashPaymentPanel(onConfirm: _confirmCash)
                    else ...[
                      if (_loadingProviders)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        if (_providers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Aucun prestataire de paiement mobile n’est configuré.',
                            ),
                          ),
                        DropdownButtonFormField<PaymentProvider>(
                          initialValue: _selectedProvider,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Prestataire',
                            border: OutlineInputBorder(),
                          ),
                          items: _providers
                              .map(
                                (provider) => DropdownMenuItem(
                                  value: provider,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      provider.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (provider) => setState(() {
                            _selectedProvider = provider;
                            _selectedMethod =
                                provider?.methods.keys.firstOrNull;
                          }),
                        ),
                        const SizedBox(height: 12),
                        if ((_selectedProvider?.methods.isNotEmpty ?? false))
                          DropdownButtonFormField<String>(
                            initialValue: _selectedMethod,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Méthode de paiement',
                              border: OutlineInputBorder(),
                            ),
                            items: _selectedProvider!.methods.entries
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        entry.value,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (method) =>
                                setState(() => _selectedMethod = method),
                          ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _processing || _providers.isEmpty
                                ? null
                                : _startMobilePayment,
                            icon: _processing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.lock_rounded),
                            label: Text(
                              _processing
                                  ? 'Vérification du paiement...'
                                  : 'Payer par Mobile Money',
                            ),
                          ),
                        ),
                      ],
                      if (_ticketReference != null)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Réservation créée. Le ticket sera confirmé après vérification du paiement.',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      if (_paymentMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _paymentMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PercepteurModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const PercepteurModeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF16A34A) : const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF16A34A)
                : const Color(0xFF0B4F2A).withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF0B4F2A),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF0B4F2A),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PercepteurCashPaymentPanel extends StatelessWidget {
  final VoidCallback onConfirm;

  const PercepteurCashPaymentPanel({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            "Le percepteur reçoit directement l'argent du client puis confirme la réservation.",
            style: TextStyle(
              color: Color(0xFF5F6B86),
              height: 1.35,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Confirmer le paiement cash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class PercepteurTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const PercepteurTextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.suffixText,
    this.inputFormatters,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onChanged: onChanged,
      style: const TextStyle(
        color: Color(0xFF0B4F2A),
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixText,
        prefixIcon: Icon(icon, color: const Color(0xFF16A34A)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class PercepteurTripSummaryCard extends StatelessWidget {
  final String departure;
  final String destination;
  final String date;
  final String time;
  final int passengerCount;
  final String price;

  const PercepteurTripSummaryCard({
    super.key,
    required this.departure,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengerCount,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résumé du voyage',
            style: TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          PercepteurTicketInfoRow(
            title: 'Trajet',
            value: '$departure -> $destination',
          ),
          PercepteurTicketInfoRow(title: 'Départ', value: '$date à $time'),
          PercepteurTicketInfoRow(title: 'Passagers', value: '$passengerCount'),
          PercepteurTicketInfoRow(title: 'Total', value: price),
        ],
      ),
    );
  }
}

class PercepteurGeneratedTicketPage extends StatelessWidget {
  final PercepteurReservationRecord reservation;

  const PercepteurGeneratedTicketPage({super.key, required this.reservation});

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final bytes = await _buildTicketPdf();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'ticket_fofana_${reservation.reference}.pdf',
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de générer le PDF du ticket.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    }
  }

  Future<Uint8List> _buildTicketPdf() async {
    final pdf = pw.Document();
    final deepBlue = PdfColor.fromHex('#0B4F2A');
    final red = PdfColor.fromHex('#16A34A');
    final light = PdfColor.fromHex('#F8FBFF');
    final muted = PdfColor.fromHex('#687089');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(22),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#E6EAF2')),
              borderRadius: pw.BorderRadius.circular(18),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Fofana',
                      style: pw.TextStyle(
                        color: deepBlue,
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: light,
                        borderRadius: pw.BorderRadius.circular(12),
                      ),
                      child: pw.Text(
                        reservation.status,
                        style: pw.TextStyle(
                          color: red,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 28),
                _pdfRow('Passager', reservation.passengerName, deepBlue, muted),
                _pdfRow('Telephone', reservation.phone, deepBlue, muted),
                _pdfRow(
                  'Trajet',
                  '${reservation.departure} -> ${reservation.destination}',
                  deepBlue,
                  muted,
                ),
                _pdfRow(
                  'Depart',
                  '${reservation.date} a ${reservation.time}',
                  deepBlue,
                  muted,
                ),
                _pdfRow(
                  'Passagers',
                  '${reservation.passengerCount}',
                  deepBlue,
                  muted,
                ),
                _pdfRow('Montant', reservation.price, deepBlue, muted),
                pw.Spacer(),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        reservation.reference,
                        style: pw.TextStyle(
                          color: deepBlue,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: reservation.reference,
                        width: 120,
                        height: 120,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(
    String title,
    String value,
    PdfColor deepBlue,
    PdfColor muted,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: deepBlue,
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4F2A),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => _returnToPercepteurHistory(context),
          icon: const Icon(Icons.history_rounded),
          tooltip: 'Retour à l’historique',
        ),
        title: const Text(
          'Billet généré',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PercepteurReservationCard(item: reservation),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Code QR du billet',
                      style: TextStyle(
                        color: Color(0xFF0B4F2A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    QrImageView(
                      data: reservation.reference,
                      version: QrVersions.auto,
                      size: 150,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      reservation.reference,
                      style: const TextStyle(
                        color: Color(0xFF5F6B86),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadPdf(context),
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Télécharger en PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => _returnToPercepteurHistory(context),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Retour à l’historique'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B4F2A),
                    side: BorderSide(
                      color: const Color(0xFF0B4F2A).withValues(alpha: 0.24),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PercepteurReservationCard extends StatelessWidget {
  final PercepteurReservationRecord item;
  final VoidCallback? onCancel;
  final VoidCallback? onView;
  final VoidCallback? onPrint;
  final bool isCancelling;

  const PercepteurReservationCard({
    super.key,
    required this.item,
    this.onCancel,
    this.onView,
    this.onPrint,
    this.isCancelling = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.reference,
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                item.status,
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PercepteurTicketInfoRow(
            title: 'Trajet',
            value: '${item.departure} -> ${item.destination}',
          ),
          PercepteurTicketInfoRow(
            title: 'Départ',
            value:
                '${formatPercepteurTicketDate(item.date)} à '
                '${formatPercepteurTicketTime(item.time)}',
          ),
          PercepteurTicketInfoRow(title: 'Passager', value: item.passengerName),
          PercepteurTicketInfoRow(title: 'Téléphone', value: item.phone),
          PercepteurTicketInfoRow(title: 'Total', value: item.price),
          if (item.mecefDate?.isNotEmpty == true)
            PercepteurTicketInfoRow(
              title: 'MECeF',
              value:
                  '${formatPercepteurMecefDate(item.mecefDate!)} · '
                  '${formatPercepteurMecefTime(item.mecefDate!)}',
            ),
          if (onView != null || onPrint != null || onCancel != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onView != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onView,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Voir'),
                    ),
                  ),
                if (onView != null && (onPrint != null || onCancel != null))
                  const SizedBox(width: 10),
                if (onPrint != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPrint,
                      icon: const Icon(Icons.print_outlined),
                      label: const Text('Imprimer'),
                    ),
                  ),
                if (onPrint != null && onCancel != null)
                  const SizedBox(width: 10),
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isCancelling ? null : onCancel,
                      icon: isCancelling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cancel_outlined),
                      label: Text(isCancelling ? 'Annulation...' : 'Annuler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class PercepteurAttendanceList extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final List<PercepteurReservationRecord> reservations;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRetry;

  const PercepteurAttendanceList({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.reservations,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error != null)
            Column(
              children: [
                PercepteurEmptyCard(
                  title: 'Historique indisponible',
                  message: error!,
                ),
                TextButton.icon(
                  onPressed: () => onRetry(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                ),
              ],
            )
          else if (reservations.isEmpty)
            PercepteurEmptyCard(title: title, message: emptyMessage)
          else
            ...reservations.map(
              (item) => PercepteurReservationCard(item: item),
            ),
        ],
      ),
    );
  }
}

class PercepteurEmptyCard extends StatelessWidget {
  final String title;
  final String message;

  const PercepteurEmptyCard({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
