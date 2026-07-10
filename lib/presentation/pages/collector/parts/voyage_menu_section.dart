part of '../collector_home_page.dart';

// Menu Voyage percepteur et boutons d action d acces rapide.

class _CollectorVoyageContent extends StatelessWidget {
  const _CollectorVoyageContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: const [
        _CollectorNewsSection(),
        SizedBox(height: 22),
        _CollectorVoyageMenu(),
      ],
    );
  }
}

class _CollectorVoyageMenu extends StatelessWidget {
  const _CollectorVoyageMenu();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Menu',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _CollectorMenuButton(
          icon: Icons.assignment_turned_in_rounded,
          label: 'Affectations',
          isWide: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const _CollectorAssignmentsPage(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CollectorMenuButton(
                icon: Icons.login_rounded,
                label: 'Connexion',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _CollectorConnectionPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CollectorMenuButton(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Validation',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _TicketValidationPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CollectorMenuButton(
                icon: Icons.confirmation_number_rounded,
                label: 'Réservation',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _CollectorReservationPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CollectorMenuButton(
                icon: Icons.history_rounded,
                label: 'Historique',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _CollectorHistoryPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CollectorMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isWide;

  const _CollectorMenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const green = Color(0xFF16A34A);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: isWide ? 84 : 124),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 16 : 14,
            vertical: isWide ? 14 : 15,
          ),
          decoration: BoxDecoration(
            color: isWide ? const Color(0xFFF8FBFF) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: green.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: green.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: isWide
              ? Row(
                  children: [
                    _CollectorMenuButtonIcon(icon: icon),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: deepBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: green,
                      size: 22,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CollectorMenuButtonIcon(icon: icon),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: deepBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CollectorMenuButtonIcon extends StatelessWidget {
  final IconData icon;

  const _CollectorMenuButtonIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: green.withValues(alpha: 0.20)),
      ),
      child: Icon(icon, color: green, size: 26),
    );
  }
}
