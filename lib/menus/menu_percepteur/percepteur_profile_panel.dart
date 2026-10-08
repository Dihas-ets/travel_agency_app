import 'package:flutter/material.dart';
import 'package:fofanavoyage/models/user_model.dart';
import 'package:fofanavoyage/services/auth_service.dart';
import 'package:fofanavoyage/widgets/profile_avatar.dart';

class PercepteurProfilePanel extends StatefulWidget {
  const PercepteurProfilePanel({super.key});

  @override
  State<PercepteurProfilePanel> createState() => _PercepteurProfilePanelState();
}

class _PercepteurProfilePanelState extends State<PercepteurProfilePanel> {
  static const Color _green = Color(0xFF16A34A);
  static const Color _darkGreen = Color(0xFF0B4F2A);
  static const Color _muted = Color(0xFF5F6B86);

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await AuthService().refreshCurrentProfile();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return _errorCard();
    }

    final user = _user;
    if (user == null) return _errorCard();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _profileHeader(user),
        const SizedBox(height: 14),
        _tabs(),
        const SizedBox(height: 12),
        if (_selectedTab == 0) _personalInfo(user) else _securityInfo(),
      ],
    );
  }

  Widget _errorCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 38),
        const SizedBox(height: 10),
        Text(
          _errorMessage ?? 'Impossible de charger le profil.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _loadProfile,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Réessayer'),
        ),
      ],
    ),
  );

  Widget _profileHeader(UserModel user) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: _darkGreen.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        ProfileAvatar(
          user: user,
          radius: 46,
          backgroundColor: const Color(0xFF16A34A),
        ),
        const SizedBox(height: 12),
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _roleLabel(user.role),
          style: const TextStyle(
            color: _green,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: user.status == 'actif'
                ? _green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            user.status.toUpperCase(),
            style: TextStyle(
              color: user.status == 'actif' ? _darkGreen : Colors.red.shade700,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _tabs() => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        _tabButton('Informations', 0, Icons.person_outline_rounded),
        _tabButton('Sécurité', 1, Icons.shield_outlined),
      ],
    ),
  );

  Widget _tabButton(String label, int index, IconData icon) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        decoration: BoxDecoration(
          color: _selectedTab == index ? _green : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: _selectedTab == index ? Colors.white : _darkGreen,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _selectedTab == index ? Colors.white : _darkGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _personalInfo(UserModel user) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations personnelles',
          style: TextStyle(
            color: _darkGreen,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        _infoTile(Icons.badge_outlined, 'Nom', user.nom ?? '—'),
        _infoTile(Icons.person_outline_rounded, 'Prénom', user.prenom ?? '—'),
        _infoTile(Icons.email_outlined, 'Email', user.email ?? 'Non renseigné'),
        _infoTile(Icons.phone_outlined, 'Téléphone', user.numero),
        _infoTile(
          Icons.location_city_outlined,
          'Agence',
          user.agence?['nom_agence']?.toString() ?? 'Non renseignée',
        ),
        _infoTile(
          Icons.work_outline_rounded,
          'Fonction',
          _roleLabel(user.role),
        ),
        _infoTile(
          Icons.calendar_month_outlined,
          'Membre depuis',
          user.createdAt == null ? '—' : _formatDate(user.createdAt!),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ces informations sont consultables dans l’application. Leur modification est réservée aux administrateurs, comme sur le portail web.',
          style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
        ),
      ],
    ),
  );

  Widget _securityInfo() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sécurité du compte',
          style: TextStyle(
            color: _darkGreen,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline_rounded, color: _green),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'La modification du mot de passe et de la photo de profil est réservée aux administrateurs sur le portail web. Contactez un administrateur pour toute modification.',
                style: TextStyle(color: _muted, height: 1.45),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _infoTile(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _green, size: 20),
        const SizedBox(width: 10),
        SizedBox(
          width: 94,
          child: Text(label, style: const TextStyle(color: _muted)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );

  String _roleLabel(String role) => role
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
