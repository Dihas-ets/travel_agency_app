part of '../home_page.dart';

// Navigation secondaire client, notifications colis, menu et panneau de compte.

class _HomeTab {
  final String title;
  final IconData icon;
  final String headline;
  final String description;

  const _HomeTab({
    required this.title,
    required this.icon,
    required this.headline,
    required this.description,
  });
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF0B4F2A)),
      ),
    );
  }
}

class _ParcelNotificationIconButton extends StatelessWidget {
  const _ParcelNotificationIconButton();

  void _showClientNotifications(BuildContext context) {
    final currentPhone = SessionStore.currentClientPhone;
    ParcelStore.clearNotifications(senderPhone: currentPhone);

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const _ClientNotificationsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ParcelStore.notificationCount,
      builder: (context, _, __) {
        final currentPhone = SessionStore.currentClientPhone;
        final count = ParcelStore.unreadNotificationsCount(
          senderPhone: currentPhone,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () => _showClientNotifications(context),
            ),
            if (count > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 19,
                  height: 19,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ClientNotificationsPage extends StatelessWidget {
  const _ClientNotificationsPage();

  @override
  Widget build(BuildContext context) {
    final currentPhone = SessionStore.currentClientPhone;
    final notifications = List<ParcelRecord>.from(
      ParcelStore.notifications.where(
        (parcel) => currentPhone == null || parcel.senderPhone == currentPhone,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4F2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B4F2A), Color(0xFF16A34A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alertes colis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notifications.isEmpty
                              ? 'Aucune alerte pour le moment'
                              : '${notifications.length} notification(s) disponible(s)',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (notifications.isEmpty)
              const _ClientNotificationEmptyState()
            else
              ...notifications.map(
                (parcel) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ClientNotificationTile(
                    parcel: parcel,
                    onTap: () {
                      ParcelStore.markNotificationRead(parcel.code);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              _ClientNotificationDetailPage(parcel: parcel),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClientNotificationTile extends StatelessWidget {
  final ParcelRecord parcel;
  final VoidCallback onTap;

  const _ClientNotificationTile({required this.parcel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              _ClientParcelThumbnail(parcel: parcel, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parcel.status,
                      style: const TextStyle(
                        color: Color(0xFF0B4F2A),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${parcel.parcelNature} vers ${parcel.destinationCity}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5F6B86),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFE53935)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientNotificationDetailPage extends StatelessWidget {
  final ParcelRecord parcel;

  const _ClientNotificationDetailPage({required this.parcel});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Détail notification',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            _ClientParcelImage(parcel: parcel),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: deepBlue.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parcel.status,
                    style: const TextStyle(
                      color: deepBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Votre colis ${parcel.parcelNature} est enregistré pour ${parcel.destinationCity}.',
                    style: const TextStyle(
                      color: Color(0xFF5F6B86),
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ClientNotificationInfo(
                    icon: Icons.qr_code_2_rounded,
                    label: 'Code colis',
                    value: parcel.code,
                  ),
                  _ClientNotificationInfo(
                    icon: Icons.route_rounded,
                    label: 'Trajet',
                    value:
                        '${parcel.departureCity} - ${parcel.destinationCity}',
                  ),
                  _ClientNotificationInfo(
                    icon: Icons.person_rounded,
                    label: 'Bénéficiaire',
                    value: parcel.recipientFullName,
                  ),
                  _ClientNotificationInfo(
                    icon: Icons.phone_rounded,
                    label: 'Téléphone',
                    value: parcel.recipientPhone,
                  ),
                  _ClientNotificationInfo(
                    icon: Icons.inventory_2_rounded,
                    label: 'Quantité',
                    value: '${parcel.parcelCount} colis',
                  ),
                  if (parcel.attachmentName != null)
                    _ClientNotificationInfo(
                      icon: Icons.attach_file_rounded,
                      label: 'Pièce jointe',
                      value: parcel.attachmentName!,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_rounded),
                label: const Text('J’ai compris'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
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
      ),
    );
  }
}

class _ClientNotificationInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ClientNotificationInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF16A34A), size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8B93A6),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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

class _ClientParcelImage extends StatelessWidget {
  final ParcelRecord parcel;

  const _ClientParcelImage({required this.parcel});

  @override
  Widget build(BuildContext context) {
    final path = parcel.attachmentPath;

    if (path == null || path.trim().isEmpty) {
      return _ClientImageFallback(height: 190, iconSize: 48);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.file(
        File(path),
        width: double.infinity,
        height: 210,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _ClientImageFallback(height: 190, iconSize: 48),
      ),
    );
  }
}

class _ClientParcelThumbnail extends StatelessWidget {
  final ParcelRecord parcel;
  final double size;

  const _ClientParcelThumbnail({required this.parcel, required this.size});

  @override
  Widget build(BuildContext context) {
    final path = parcel.attachmentPath;

    if (path == null || path.trim().isEmpty) {
      return _ClientImageFallback(height: size, width: size, iconSize: 22);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _ClientImageFallback(height: size, width: size, iconSize: 22),
      ),
    );
  }
}

class _ClientImageFallback extends StatelessWidget {
  final double height;
  final double? width;
  final double iconSize;

  const _ClientImageFallback({
    required this.height,
    this.width,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE53935).withValues(alpha: 0.22),
        ),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        color: const Color(0xFFE53935),
        size: iconSize,
      ),
    );
  }
}

class _ClientNotificationEmptyState extends StatelessWidget {
  const _ClientNotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.08),
        ),
      ),
      child: const Text(
        'Aucune notification pour le moment',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF5F6B86),
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ===================== MENU (Bottom sheet) =====================

class _MainMenuSheet extends StatefulWidget {
  const _MainMenuSheet();

  @override
  State<_MainMenuSheet> createState() => _MainMenuSheetState();
}

class _MainMenuSheetState extends State<_MainMenuSheet> {
  bool _showAccount = false;

  void _showTerms() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TermsSheet(),
    );
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/welcomepage', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _showAccount
                ? _AccountMenuView(
                    key: const ValueKey('account-view'),
                    scrollController: scrollController,
                    onBack: () => setState(() => _showAccount = false),
                  )
                : _MainMenuView(
                    key: const ValueKey('main-menu-view'),
                    scrollController: scrollController,
                    onClose: () => Navigator.pop(context),
                    onAccountTap: () => setState(() => _showAccount = true),
                    onTermsTap: _showTerms,
                    onLogoutTap: _logout,
                  ),
          ),
        );
      },
    );
  }
}

class _MainMenuView extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onClose;
  final VoidCallback onAccountTap;
  final VoidCallback onTermsTap;
  final VoidCallback onLogoutTap;

  const _MainMenuView({
    required this.scrollController,
    required this.onClose,
    required this.onAccountTap,
    required this.onTermsTap,
    required this.onLogoutTap,
    super.key,
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
            'Client Fofana',
            style: TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 26),
          const _MenuSectionTitle(
            icon: Icons.grid_view_rounded,
            title: 'Menu principal',
          ),
          const SizedBox(height: 10),
          _MenuOptionTile(
            icon: Icons.account_circle_outlined,
            title: 'Mon compte',
            isSelected: true,
            onTap: onAccountTap,
          ),
          _MenuOptionTile(
            icon: Icons.description_outlined,
            title: "Conditions d'utilisation",
            onTap: onTermsTap,
          ),
          _MenuOptionTile(
            icon: Icons.logout_rounded,
            title: 'Déconnexion',
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

class _MenuSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _MenuSectionTitle({required this.icon, required this.title});

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

class _MenuOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _MenuOptionTile({
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
              color: const Color(0xFF7B849B).withValues(alpha: 0.76),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== ACCOUNT VIEW (Fix overflow + editable avatar) =====================

class _AccountMenuView extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback onBack;

  const _AccountMenuView({
    required this.scrollController,
    required this.onBack,
    super.key,
  });

  @override
  State<_AccountMenuView> createState() => _AccountMenuViewState();
}

class _AccountMenuViewState extends State<_AccountMenuView> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedAvatar;

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 900,
    );
    if (file == null || !mounted) return;
    setState(() => _pickedAvatar = file);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: widget.scrollController,
          padding: EdgeInsets.fromLTRB(20, 12, 20, 28 + bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    _RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: widget.onBack,
                    ),
                    const Expanded(
                      child: Text(
                        'Mon compte',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0B4F2A),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 52),
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: const Color(0xFF58648D),
                          backgroundImage: _pickedAvatar == null
                              ? null
                              : FileImage(File(_pickedAvatar!.path)),
                          child: _pickedAvatar == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 70,
                                )
                              : null,
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53935),
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 3),
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Profil client',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                const _AccountPanel(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

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

class _TermsSheet extends StatelessWidget {
  const _TermsSheet();

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
            "L'utilisation de l'application Fofana implique le respect des règles de réservation, de paiement et de transport. Les informations saisies doivent être exactes afin de faciliter les voyages, les colis et l'assistance client.",
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

class _AccountPanel extends StatefulWidget {
  const _AccountPanel();

  @override
  State<_AccountPanel> createState() => _AccountPanelState();
}

class _AccountPanelState extends State<_AccountPanel> {
  bool _isEditing = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Client Fofana');
    _emailController = TextEditingController(text: 'client@example.com');
    _countryController = TextEditingController(text: 'Bénin');
    _phoneController = TextEditingController(text: '+229 01 00 00 00 00');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);

    if (_isEditing) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informations du compte enregistrées'),
        backgroundColor: Color(0xFF0B4F2A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations personnelles',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF0B4F2A),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.18,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Photo, nom, prénom et contacts',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF5F6B86),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            TextButton.icon(
              onPressed: _toggleEdit,
              icon: Icon(
                _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                size: 21,
              ),
              label: Text(_isEditing ? 'Enregistrer' : 'Modifier'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF16A34A),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _EditableInfoField(
          icon: Icons.badge_rounded,
          title: 'Nom et prénom',
          controller: _nameController,
          enabled: _isEditing,
        ),
        _EditableInfoField(
          icon: Icons.email_rounded,
          title: 'Email',
          controller: _emailController,
          enabled: _isEditing,
        ),
        _EditableInfoField(
          icon: Icons.public_rounded,
          title: 'Pays',
          controller: _countryController,
          enabled: _isEditing,
        ),
        _EditableInfoField(
          icon: Icons.phone_rounded,
          title: 'Téléphone',
          controller: _phoneController,
          enabled: _isEditing,
        ),
        const SizedBox(height: 18),
        const _AccountInfoCard(),
      ],
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  const _AccountInfoCard();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations de compte',
          style: TextStyle(
            color: Color(0xFF0B4F2A),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 16),
        _AccountStatsGrid(),
      ],
    );
  }
}

class _AccountStatsGrid extends StatelessWidget {
  const _AccountStatsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _AccountStat(
          icon: Icons.calendar_month_rounded,
          title: 'Création du compte',
          value: '11 mai 2026',
          isWide: true,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: const [
            _AccountStat(
              icon: Icons.confirmation_number_rounded,
              title: 'Billets achetés',
              value: '0',
            ),
            _AccountStat(
              icon: Icons.local_shipping_rounded,
              title: 'Colis envoyés',
              value: '0',
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isWide;

  const _AccountStat({
    required this.icon,
    required this.title,
    required this.value,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0B4F2A).withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF16A34A), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              // Carte Création sur toute la largeur pour afficher la date complète.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '11 mai 2026',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF0B4F2A),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Création du compte',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF5F6B86),
                      fontSize: 13,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: const Color(0xFF16A34A), size: 18),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Libellé sur toute la largeur de la carte pour éviter les coupures à côté de l'icône.
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 12,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableInfoField extends StatelessWidget {
  final IconData icon;
  final String title;
  final TextEditingController controller;
  final bool enabled;

  const _EditableInfoField({
    required this.icon,
    required this.title,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Champs de profil agrandis pour une meilleure lecture et une zone tactile plus confortable.
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFFFF7F7) : const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? const Color(0xFF16A34A).withValues(alpha: 0.18)
              : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF5F6B86),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
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
