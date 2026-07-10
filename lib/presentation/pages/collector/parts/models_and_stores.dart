part of '../collector_home_page.dart';

// Modeles et stores memoire propres a l espace percepteur.

class _CollectorNotificationStore {
  static final ValueNotifier<int> count = ValueNotifier<int>(3);
  static final List<_CollectorNotificationItem> notifications = [
    _CollectorNotificationItem(
      title: 'Bienvenue',
      message: 'Votre espace percepteur Fofana est prêt.',
      time: 'Maintenant',
    ),
    _CollectorNotificationItem(
      title: 'Voyage',
      message: 'Consultez les réservations et confirmez les paiements.',
      time: 'Aujourd’hui',
    ),
    _CollectorNotificationItem(
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
      _CollectorNotificationItem(
        title: title,
        message: message,
        time: 'Maintenant',
      ),
    );
    count.value += 1;
  }

  static void clear() => count.value = 0;
}

class _CollectorNotificationItem {
  final String title;
  final String message;
  final String time;

  const _CollectorNotificationItem({
    required this.title,
    required this.message,
    required this.time,
  });
}

class _CollectorProfileData {
  final String fullName;
  final String phone;
  final String agency;
  final String role;

  const _CollectorProfileData({
    required this.fullName,
    required this.phone,
    required this.agency,
    required this.role,
  });

  _CollectorProfileData copyWith({
    String? fullName,
    String? phone,
    String? agency,
    String? role,
  }) {
    return _CollectorProfileData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      agency: agency ?? this.agency,
      role: role ?? this.role,
    );
  }
}

class _CollectorProfileStore {
  static final ValueNotifier<_CollectorProfileData> profile =
      ValueNotifier<_CollectorProfileData>(
        const _CollectorProfileData(
          fullName: 'Percepteur Fofana',
          phone: '+229 01 00 00 00 00',
          agency: 'Cotonou',
          role: 'Percepteur voyage',
        ),
      );

  static void update(_CollectorProfileData data) {
    profile.value = data;
  }
}

class _CollectorParcelRecord {
  final String id;
  final String collectorPhone;
  final String receiverName;
  final String receiverPhone;
  final String image;
  final String destination;
  String status;

  _CollectorParcelRecord({
    required this.id,
    required this.collectorPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.image,
    required this.destination,
    required this.status,
  });
}
