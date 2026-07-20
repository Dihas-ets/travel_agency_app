import 'package:flutter/material.dart';

// Modeles et stores memoire propres a l espace percepteur.

class PercepteurNotificationStore {
  static final ValueNotifier<int> count = ValueNotifier<int>(3);
  static final List<PercepteurNotificationItem> notifications = [
    PercepteurNotificationItem(
      title: 'Bienvenue',
      message: 'Votre espace percepteur Fofana est prêt.',
      time: 'Maintenant',
    ),
    PercepteurNotificationItem(
      title: 'Voyage',
      message: 'Consultez les réservations et confirmez les paiements.',
      time: 'Aujourd’hui',
    ),
    PercepteurNotificationItem(
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
      PercepteurNotificationItem(
        title: title,
        message: message,
        time: 'Maintenant',
      ),
    );
    count.value += 1;
  }

  static void clear() => count.value = 0;
}

class PercepteurNotificationItem {
  final String title;
  final String message;
  final String time;

  const PercepteurNotificationItem({
    required this.title,
    required this.message,
    required this.time,
  });
}

class PercepteurProfileData {
  final String fullName;
  final String phone;
  final String agency;
  final String role;

  const PercepteurProfileData({
    required this.fullName,
    required this.phone,
    required this.agency,
    required this.role,
  });

  PercepteurProfileData copyWith({
    String? fullName,
    String? phone,
    String? agency,
    String? role,
  }) {
    return PercepteurProfileData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      agency: agency ?? this.agency,
      role: role ?? this.role,
    );
  }
}

class PercepteurProfileStore {
  static final ValueNotifier<PercepteurProfileData> profile =
      ValueNotifier<PercepteurProfileData>(
        const PercepteurProfileData(
          fullName: 'Percepteur Fofana',
          phone: '+229 01 00 00 00 00',
          agency: 'Cotonou',
          role: 'Percepteur voyage',
        ),
      );

  static void update(PercepteurProfileData data) {
    profile.value = data;
  }
}

class PercepteurParcelRecord {
  final String id;
  final String percepteurPhone;
  final String receiverName;
  final String receiverPhone;
  final String image;
  final String destination;
  String status;

  PercepteurParcelRecord({
    required this.id,
    required this.percepteurPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.image,
    required this.destination,
    required this.status,
  });
}
