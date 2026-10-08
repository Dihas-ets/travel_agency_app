import 'package:flutter/material.dart';
import 'package:fofanavoyage/models/user_model.dart';

class ProfileAvatar extends StatelessWidget {
  final UserModel? user;
  final double radius;
  final IconData fallbackIcon;
  final Color backgroundColor;

  const ProfileAvatar({
    super.key,
    required this.user,
    required this.radius,
    this.fallbackIcon = Icons.person_rounded,
    this.backgroundColor = const Color(0xFF58648D),
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl;
    final diameter = radius * 2;
    final fallback = Icon(
      fallbackIcon,
      color: Colors.white,
      size: radius * 1.25,
    );

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: photoUrl == null
          ? fallback
          : ClipOval(
              child: Image.network(
                photoUrl,
                key: ValueKey(photoUrl),
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) {
                  debugPrint(
                    'Échec du chargement de la photo de profil ($photoUrl): $error',
                  );
                  return fallback;
                },
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback,
              ),
            ),
    );
  }
}
