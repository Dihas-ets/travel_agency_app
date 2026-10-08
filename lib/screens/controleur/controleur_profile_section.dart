import 'package:flutter/material.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/models/user_model.dart';
import 'package:code_initial/widgets/profile_avatar.dart';

class ControleurProfileTabContent extends StatelessWidget {
  const ControleurProfileTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: SessionStore.currentUserNotifier,
      builder: (context, user, _) {
        return ListView(
          padding: const EdgeInsets.only(bottom: 18),
          children: [
            Center(
              child: ProfileAvatar(
                user: user,
                radius: 52,
                fallbackIcon: Icons.verified_user_rounded,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Profil contrôleur',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0B4F2A),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _ProfileInfoRow(
                    icon: Icons.badge_rounded,
                    label: 'Nom et prénom',
                    value: user?.fullName,
                  ),
                  _ProfileInfoRow(
                    icon: Icons.phone_rounded,
                    label: 'Téléphone',
                    value: user?.numero,
                  ),
                  _ProfileInfoRow(
                    icon: Icons.location_city_rounded,
                    label: 'Agence',
                    value: user?.agence?['nom_agence']?.toString(),
                  ),
                  _ProfileInfoRow(
                    icon: Icons.work_rounded,
                    label: 'Fonction',
                    value: user?.role,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isLast;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value?.trim();
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF16A34A)),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  displayValue == null || displayValue.isEmpty
                      ? 'Non renseigné'
                      : displayValue,
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
