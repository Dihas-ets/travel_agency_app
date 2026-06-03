import 'package:flutter/foundation.dart';

class ParcelRecord {
  final String code;
  final String departureCity;
  final String destinationCity;
  final String recipientLastName;
  final String recipientFirstName;
  final String recipientPhone;
  final String parcelNature;
  final int parcelCount;
  final String? attachmentPath;
  final String? attachmentName;
  final String? deliveryFee;
  final DateTime createdAt;
  final String status;

  const ParcelRecord({
    required this.code,
    required this.departureCity,
    required this.destinationCity,
    required this.recipientLastName,
    required this.recipientFirstName,
    required this.recipientPhone,
    required this.parcelNature,
    required this.parcelCount,
    this.attachmentPath,
    this.attachmentName,
    this.deliveryFee,
    required this.createdAt,
    required this.status,
  });

  String get recipientFullName =>
      '$recipientLastName $recipientFirstName'.trim();

  ParcelRecord copyWith({
    String? status,
    DateTime? createdAt,
    String? deliveryFee,
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
      attachmentPath: attachmentPath,
      attachmentName: attachmentName,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

class ParcelStore {
  static final ValueNotifier<int> notificationCount = ValueNotifier<int>(0);
  static final List<ParcelRecord> pendingParcels = [];
  static final List<ParcelRecord> registeredParcels = [];
  static final List<ParcelRecord> notifications = [];
  static final Set<String> _unreadNotificationCodes = {};

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

    // La cloche affiche les derniers colis finalisés. On garde la liste en
    // mémoire pour que le clic montre un vrai contenu au lieu d'un simple badge.
    notifications.removeWhere((item) => item.code == registered.code);
    notifications.insert(0, registered);
    _unreadNotificationCodes.add(registered.code);
    _refreshNotificationCount();
  }

  static void clearNotifications() {
    _unreadNotificationCodes.clear();
    _refreshNotificationCount();
  }

  static void markNotificationRead(String code) {
    _unreadNotificationCodes.remove(code);
    _refreshNotificationCount();
  }

  static void _refreshNotificationCount() {
    notificationCount.value = _unreadNotificationCodes.length;
  }
}
