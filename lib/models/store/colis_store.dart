import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParcelLine {
  final String nature;
  final int quantity;
  final double weight;
  final String description;
  final String? attachmentPath;

  const ParcelLine({
    required this.nature,
    required this.quantity,
    this.weight = 0,
    this.description = '',
    this.attachmentPath,
  });
}

class ParcelMecefInfo {
  final String? status;
  final String? code;
  final String? nim;
  final String? counters;
  final String? date;
  final String? qrCode;

  const ParcelMecefInfo({
    this.status,
    this.code,
    this.nim,
    this.counters,
    this.date,
    this.qrCode,
  });

  factory ParcelMecefInfo.fromJson(Map<String, dynamic> json) {
    return ParcelMecefInfo(
      status: json['status']?.toString(),
      code: json['code_mecef']?.toString(),
      nim: json['nim']?.toString(),
      counters: json['counters']?.toString(),
      date: json['date_mecef']?.toString(),
      qrCode: json['qr_code']?.toString(),
    );
  }

  bool get isConfirmed => status == 'confirmed';
}

class ParcelRecord {
  final String code;
  final String departureCity;
  final String destinationCity;
  final String recipientLastName;
  final String recipientFirstName;
  final String recipientPhone;
  final String parcelNature;
  final int parcelCount;
  final String senderPhone;
  final String? senderName;
  final String? attachmentPath;
  final String? attachmentName;
  final String? deliveryFee;
  final DateTime createdAt;
  final String status;
  final String? qrCode;
  final double? estimatedValue;
  final double? amountBase;
  final double? taxAmount;
  final String? rawStatus;
  final String? paymentStatus;
  final String? modePaiement;
  final List<ParcelLine> parcelItems;
  final int? taxGroupId;
  final String? taxGroupLabel;
  final String? taxGroupCode;
  final double? taxRate;
  final ParcelMecefInfo? mecefInfo;

  const ParcelRecord({
    required this.code,
    required this.departureCity,
    required this.destinationCity,
    required this.recipientLastName,
    required this.recipientFirstName,
    required this.recipientPhone,
    required this.parcelNature,
    required this.parcelCount,
    required this.senderPhone,
    this.senderName,
    this.attachmentPath,
    this.attachmentName,
    this.deliveryFee,
    required this.createdAt,
    required this.status,
    this.qrCode,
    this.estimatedValue,
    this.amountBase,
    this.taxAmount,
    this.rawStatus,
    this.paymentStatus,
    this.modePaiement,
    this.parcelItems = const [],
    this.taxGroupId,
    this.taxGroupLabel,
    this.taxGroupCode,
    this.taxRate,
    this.mecefInfo,
  });

  String get recipientFullName =>
      '$recipientLastName $recipientFirstName'.trim();

  bool get isDraftOrPending =>
      rawStatus == 'brouillon' ||
      status == 'En attente' ||
      status == 'Pré-enregistré' ||
      paymentStatus == 'en_attente_paiement';

  bool get isPaid => paymentStatus?.toLowerCase() == 'payé';

  String get readableStatus {
    switch (rawStatus) {
      case 'brouillon':
        return 'En attente en agence';
      case 'a_expedier':
        return 'À expédier';
      case 'en_transit':
        return 'En transit';
      case 'arrive':
        return 'Arrivé en agence';
      case 'livre':
        return 'Livré';
      case 'perdu':
        return 'Perdu';
      default:
        return status;
    }
  }

  ParcelRecord copyWith({
    String? status,
    DateTime? createdAt,
    String? deliveryFee,
    String? senderPhone,
    String? senderName,
    String? qrCode,
    double? estimatedValue,
    double? amountBase,
    double? taxAmount,
    String? rawStatus,
    String? paymentStatus,
    String? modePaiement,
    List<ParcelLine>? parcelItems,
    int? taxGroupId,
    String? taxGroupLabel,
    String? taxGroupCode,
    double? taxRate,
    ParcelMecefInfo? mecefInfo,
  }) {
    return ParcelRecord(
      code: code,
      departureCity: departureCity,
      destinationCity: destinationCity,
      recipientLastName: recipientLastName,
      recipientFirstName: recipientFirstName,
      recipientPhone: recipientPhone,
      parcelNature: parcelNature,
      parcelCount: parcelCount,
      senderPhone: senderPhone ?? this.senderPhone,
      senderName: senderName ?? this.senderName,
      attachmentPath: attachmentPath,
      attachmentName: attachmentName,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      amountBase: amountBase ?? this.amountBase,
      taxAmount: taxAmount ?? this.taxAmount,
      rawStatus: rawStatus ?? this.rawStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      modePaiement: modePaiement ?? this.modePaiement,
      parcelItems: parcelItems ?? this.parcelItems,
      taxGroupId: taxGroupId ?? this.taxGroupId,
      taxGroupLabel: taxGroupLabel ?? this.taxGroupLabel,
      taxGroupCode: taxGroupCode ?? this.taxGroupCode,
      taxRate: taxRate ?? this.taxRate,
      mecefInfo: mecefInfo ?? this.mecefInfo,
    );
  }
}

class ParcelStore {
  static final ValueNotifier<int> notificationCount = ValueNotifier<int>(0);
  static final List<ParcelRecord> pendingParcels = [];
  static final List<ParcelRecord> registeredParcels = [];
  static final List<ParcelRecord> notifications = [];
  static final Set<String> _unreadNotificationCodes = {};

  static Future<void> rememberStatus(ParcelRecord parcel) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      'colis_status_${parcel.code}',
      parcel.isDraftOrPending,
    );
  }

  static Future<List<ParcelRecord>> syncStatusChanges(
    List<ParcelRecord> parcels,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final changedParcels = <ParcelRecord>[];
    for (final parcel in parcels) {
      final key = 'colis_status_${parcel.code}';
      final previousPendingStatus = preferences.getBool(key);
      final isPending = parcel.isDraftOrPending;

      if (previousPendingStatus == true && !isPending) {
        registerParcel(parcel, status: parcel.readableStatus);
        changedParcels.add(parcel);
      }

      await preferences.setBool(key, isPending);
    }
    return changedParcels;
  }

  static void upsertPending(ParcelRecord parcel) {
    if (registeredParcels.any((item) => item.code == parcel.code)) return;

    final index = pendingParcels.indexWhere((item) => item.code == parcel.code);
    if (index == -1) {
      pendingParcels.insert(0, parcel);
    } else {
      pendingParcels[index] = parcel;
    }
  }

  static void registerParcel(ParcelRecord parcel, {required String status}) {
    pendingParcels.removeWhere((item) => item.code == parcel.code);
    final registered = parcel.copyWith(status: status);
    final index = registeredParcels.indexWhere(
      (item) => item.code == parcel.code,
    );

    if (index == -1) {
      registeredParcels.insert(0, registered);
    } else {
      registeredParcels[index] = registered;
    }

    notifications.removeWhere((item) => item.code == registered.code);
    notifications.insert(0, registered);
    _unreadNotificationCodes.add(registered.code);
    _refreshNotificationCount();
  }

  static void clearNotifications({String? senderPhone}) {
    if (senderPhone == null) {
      _unreadNotificationCodes.clear();
    } else {
      _unreadNotificationCodes.removeWhere(
        (code) => notifications.any(
          (item) => item.code == code && item.senderPhone == senderPhone,
        ),
      );
    }
    _refreshNotificationCount();
  }

  static int unreadNotificationsCount({String? senderPhone}) {
    if (senderPhone == null) {
      return _unreadNotificationCodes.length;
    }

    return notifications
        .where(
          (item) =>
              item.senderPhone == senderPhone &&
              _unreadNotificationCodes.contains(item.code),
        )
        .length;
  }

  static bool isNotificationUnread(String code) =>
      _unreadNotificationCodes.contains(code);

  static void markNotificationRead(String code) {
    _unreadNotificationCodes.remove(code);
    _refreshNotificationCount();
  }

  static void _refreshNotificationCount() {
    notificationCount.value = _unreadNotificationCodes.length;
  }
}
