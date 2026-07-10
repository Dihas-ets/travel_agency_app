part of '../collector_home_page.dart';

// Menu principal percepteur, profil editable et conditions.

class _CollectorMainMenuSheet extends StatefulWidget {
  const _CollectorMainMenuSheet();

  @override
  State<_CollectorMainMenuSheet> createState() =>
      _CollectorMainMenuSheetState();
}

enum _CollectorMainMenuTarget { profile, assignments, parcels, terms, logout }

class _CollectorMainMenuSheetState extends State<_CollectorMainMenuSheet> {
  bool _showProfile = false;
  _CollectorMainMenuTarget? _selectedMenu;

  void _selectMenu(_CollectorMainMenuTarget target) {
    setState(() => _selectedMenu = target);
  }

  void _openProfile() {
    setState(() {
      _selectedMenu = _CollectorMainMenuTarget.profile;
      _showProfile = true;
    });
  }

  void _openAssignments() {
    _selectMenu(_CollectorMainMenuTarget.assignments);
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(builder: (_) => const _CollectorAssignmentsPage()),
    );
  }

  void _openParcels() {
    _selectMenu(_CollectorMainMenuTarget.parcels);
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => const ColisAttentePage(initialTabIndex: 1),
      ),
    );
  }

  void _showTerms() {
    _selectMenu(_CollectorMainMenuTarget.terms);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CollectorTermsSheet(),
    );
  }

  void _logout() {
    _selectMenu(_CollectorMainMenuTarget.logout);
    Navigator.of(context).pushNamedAndRemoveUntil('/welcomepage', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.76,
      minChildSize: 0.48,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _showProfile
                ? _CollectorProfileMenuView(
                    key: const ValueKey('collector-profile'),
                    scrollController: scrollController,
                    onBack: () => setState(() => _showProfile = false),
                  )
                : _CollectorMainMenuView(
                    key: const ValueKey('collector-menu'),
                    scrollController: scrollController,
                    selectedMenu: _selectedMenu,
                    onClose: () => Navigator.pop(context),
                    onProfileTap: _openProfile,
                    onAssignmentsTap: _openAssignments,
                    onParcelsTap: _openParcels,
                    onTermsTap: _showTerms,
                    onLogoutTap: _logout,
                  ),
          ),
        );
      },
    );
  }
}

class _CollectorMainMenuView extends StatelessWidget {
  final ScrollController scrollController;
  final _CollectorMainMenuTarget? selectedMenu;
  final VoidCallback onClose;
  final VoidCallback onProfileTap;
  final VoidCallback onAssignmentsTap;
  final VoidCallback onParcelsTap;
  final VoidCallback onTermsTap;
  final VoidCallback onLogoutTap;

  const _CollectorMainMenuView({
    super.key,
    required this.scrollController,
    required this.selectedMenu,
    required this.onClose,
    required this.onProfileTap,
    required this.onAssignmentsTap,
    required this.onParcelsTap,
    required this.onTermsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'v1.0.2',
              style: TextStyle(
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Image.asset(
            'assets/images/logo_fofana_no_background.png',
            height: 62,
          ),
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFF58648D),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 62),
          ),
          const SizedBox(height: 16),
          const Text(
            'Percepteur Fofana',
            style: TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 26),
          const _CollectorMenuSectionTitle(
            icon: Icons.grid_view_rounded,
            title: 'Menu principal',
          ),
          const SizedBox(height: 10),
          _CollectorMenuOptionTile(
            icon: Icons.account_circle_outlined,
            title: 'Profil',
            isSelected: selectedMenu == _CollectorMainMenuTarget.profile,
            onTap: onProfileTap,
          ),
          _CollectorMenuOptionTile(
            icon: Icons.assignment_turned_in_rounded,
            title: 'Mes affectations',
            isSelected: selectedMenu == _CollectorMainMenuTarget.assignments,
            onTap: onAssignmentsTap,
          ),
          _CollectorMenuOptionTile(
            icon: Icons.inventory_2_rounded,
            title: 'Mes colis enregistrés',
            isSelected: selectedMenu == _CollectorMainMenuTarget.parcels,
            onTap: onParcelsTap,
          ),
          _CollectorMenuOptionTile(
            icon: Icons.description_outlined,
            title: "Conditions d'utilisation",
            isSelected: selectedMenu == _CollectorMainMenuTarget.terms,
            onTap: onTermsTap,
          ),
          _CollectorMenuOptionTile(
            icon: Icons.logout_rounded,
            title: 'Déconnexion',
            isSelected: selectedMenu == _CollectorMainMenuTarget.logout,
            onTap: onLogoutTap,
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            label: const Text('Fermer le menu'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0B4F2A),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectorMenuSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CollectorMenuSectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: const Color(0xFF57AFC2), size: 18),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF7B849B),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}

class _CollectorMenuOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _CollectorMenuOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F6FC) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFFF47B2A) : Colors.transparent,
              width: 5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFF47B2A), size: 27),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0B4F2A),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF0B4F2A).withValues(alpha: 0.42),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectorProfileMenuView extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onBack;

  const _CollectorProfileMenuView({
    super.key,
    required this.scrollController,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 42),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 52,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _CollectorRoundIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBack,
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/logo_fofana_no_background.png',
                  height: 70,
                ),
              ),
              const SizedBox(width: 52),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Profil percepteur',
            style: TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 68,
            backgroundColor: Color(0xFF58648D),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 88),
          ),
          const SizedBox(height: 24),
          const _CollectorProfilePanel(),
        ],
      ),
    );
  }
}

class _CollectorRoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CollectorRoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF0B4F2A), size: 25),
      ),
    );
  }
}

class _CollectorProfilePanel extends StatelessWidget {
  const _CollectorProfilePanel();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_CollectorProfileData>(
      valueListenable: _CollectorProfileStore.profile,
      builder: (context, profile, _) {
        return _CollectorProfileEditor(profile: profile);
      },
    );
  }
}

class _CollectorProfileEditor extends StatefulWidget {
  final _CollectorProfileData profile;

  const _CollectorProfileEditor({required this.profile});

  @override
  State<_CollectorProfileEditor> createState() =>
      _CollectorProfileEditorState();
}

class _CollectorProfileEditorState extends State<_CollectorProfileEditor> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _agencyController;
  late final TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _agencyController = TextEditingController(text: widget.profile.agency);
    _roleController = TextEditingController(text: widget.profile.role);
  }

  @override
  void didUpdateWidget(covariant _CollectorProfileEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _nameController.text = widget.profile.fullName;
      _phoneController.text = widget.profile.phone;
      _agencyController.text = widget.profile.agency;
      _roleController.text = widget.profile.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _agencyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final nextProfile = widget.profile.copyWith(
      fullName: _nameController.text.trim().isEmpty
          ? widget.profile.fullName
          : _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? widget.profile.phone
          : _phoneController.text.trim(),
      agency: _agencyController.text.trim().isEmpty
          ? widget.profile.agency
          : _agencyController.text.trim(),
      role: _roleController.text.trim().isEmpty
          ? widget.profile.role
          : _roleController.text.trim(),
    );

    _CollectorProfileStore.update(nextProfile);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil percepteur mis à jour.'),
        backgroundColor: Color(0xFF0B4F2A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _CollectorProfileEditField(
            icon: Icons.badge_rounded,
            label: 'Nom et prénom',
            controller: _nameController,
          ),
          const SizedBox(height: 14),
          _CollectorProfileEditField(
            icon: Icons.phone_rounded,
            label: 'Téléphone',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _CollectorProfileEditField(
            icon: Icons.location_city_rounded,
            label: 'Agence',
            controller: _agencyController,
          ),
          const SizedBox(height: 14),
          _CollectorProfileEditField(
            icon: Icons.work_rounded,
            label: 'Fonction',
            controller: _roleController,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Enregistrer le profil'),
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
      ),
    );
  }
}

class _CollectorProfileEditField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _CollectorProfileEditField({
    required this.icon,
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0B4F2A), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Color(0xFF0B4F2A),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  color: Color(0xFF5F6B86),
                  fontWeight: FontWeight.w800,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectorProfileTabContent extends StatelessWidget {
  const _CollectorProfileTabContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: const [
        Center(
          child: CircleAvatar(
            radius: 52,
            backgroundColor: Color(0xFF58648D),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 66),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Profil percepteur',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0B4F2A),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 18),
        _CollectorProfilePanel(),
      ],
    );
  }
}

class _CollectorTermsSheet extends StatelessWidget {
  const _CollectorTermsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Conditions d'utilisation",
            style: TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "L'utilisation de l'espace percepteur Fofana implique le respect des règles de validation des tickets, de présence et de traitement des opérations voyage.",
            style: TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 13,
              height: 1.42,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
