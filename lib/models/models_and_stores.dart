import 'package:flutter/material.dart';

// Modeles et stores memoire propres a l espace percepteur.

class CollectorNotificationStore {
  static final ValueNotifier<int> count = ValueNotifier<int>(3);
  static final List<CollectorNotificationItem> notifications = [
    CollectorNotificationItem(
      title: 'Bienvenue',
      message: 'Votre espace percepteur Fofana est prêt.',
      time: 'Maintenant',
    ),
    CollectorNotificationItem(
      title: 'Voyage',
      message: 'Consultez les réservations et confirmez les paiements.',
      time: 'Aujourd’hui',
    ),
    CollectorNotificationItem(
      title: 'Colis',
      message: 'Les nouvelles opérations colis apparaîtront ici.',
      time: 'Aujourd’hui',
    ),
  ];

  static void add({
    String title = 'Nouvelle notification',
    String message = 'Une nouvelle opération a été enregistrée.',
  }) {
    notifications.insert(
      0,
      CollectorNotificationItem(
        title: title,
        message: message,
        time: 'Maintenant',
      ),
    );
    count.value += 1;
  }

  static void clear() => count.value = 0;
}

class CollectorNotificationItem {
  final String title;
  final String message;
  final String time;

  const CollectorNotificationItem({
    required this.title,
    required this.message,
    required this.time,
  });
}

class CollectorProfileData {
  final String fullName;
  final String phone;
  final String agency;
  final String role;

  const CollectorProfileData({
    required this.fullName,
    required this.phone,
    required this.agency,
    required this.role,
  });

  CollectorProfileData copyWith({
    String? fullName,
    String? phone,
    String? agency,
    String? role,
  }) {
    return CollectorProfileData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      agency: agency ?? this.agency,
      role: role ?? this.role,
    );
  }
}

class CollectorProfileStore {
  static final ValueNotifier<CollectorProfileData> profile =
      ValueNotifier<CollectorProfileData>(
        const CollectorProfileData(
          fullName: 'Percepteur Fofana',
          phone: '+229 01 00 00 00 00',
          agency: 'Cotonou',
          role: 'Percepteur voyage',
        ),
      );

  static void update(CollectorProfileData data) {
    profile.value = data;
  }
}

class CollectorParcelRecord {
  final String id;
  final String collectorPhone;
  final String receiverName;
  final String receiverPhone;
  final String image;
  final String destination;
  String status;

  CollectorParcelRecord({
    required this.id,
    required this.collectorPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.image,
    required this.destination,
    required this.status,
  });
}
