import 'package:flutter/material.dart';
import 'package:code_initial/screens/client/colis/pages_colis.dart';

class EnvoisEffectuesPage extends StatefulWidget {
  final String code;
  final String departureCity;
  final String destinationCity;
  final String recipientLastName;
  final String recipientFirstName;
  final String recipientPhone;
  final String parcelNature;
  final int parcelCount;

  const EnvoisEffectuesPage({
    super.key,
    this.code = '--',
    this.departureCity = '--',
    this.destinationCity = '--',
    this.recipientLastName = '--',
    this.recipientFirstName = '--',
    this.recipientPhone = '--',
    this.parcelNature = '--',
    this.parcelCount = 1,
  });

  @override
  State<EnvoisEffectuesPage> createState() => _EnvoisEffectuesPageState();
}

class _EnvoisEffectuesPageState extends State<EnvoisEffectuesPage> {
  bool _isFabMenuOpen = false;

  void _toggleFabMenu() {
    setState(() => _isFabMenuOpen = !_isFabMenuOpen);
  }

  void _openSendParcelPage() {
    setState(() => _isFabMenuOpen = false);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SendParcelPage()));
  }

  void _showTrackingMessage() {
    setState(() => _isFabMenuOpen = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Le suivi de colis sera bientôt disponible'),
        backgroundColor: Color(0xFF0B4F2A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color logoBlue = Color(0xFF0B4F2A);
    const Color cardBg = Color(0xFFF8F9FE);
    const Color borderLine = Color(0xFFE6EAF2);
    const Color mutedText = Color(0xFF95A0B6);
    const Color successGreen = Color(0xFF17A34A);

    final String recipientFullName =
        '${widget.recipientLastName} ${widget.recipientFirstName}'.trim();

    final now = DateTime.now();
    final expeditionDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final String senderName = recipientFullName.isEmpty
        ? 'Expediteur'
        : recipientFullName;

    // Donnees reprises depuis le billet pour afficher le recaptitulatif sans
    // demander une nouvelle saisie a l'utilisateur.
    final String senderCity = widget.departureCity;
    final String senderPhone = widget.recipientPhone.isEmpty
        ? '--'
        : widget.recipientPhone;

    final String recipientCity = widget.destinationCity;

    const String frais = '--';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FB),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 122),
              child: Column(
                children: [
                  _Header(logoBlue: logoBlue),
                  const SizedBox(height: 18),
                  _SectionTitle(title: "Initiations d'envoi", blue: logoBlue),
                  const SizedBox(height: 14),
                  _ParcelCard(
                    cardBg: cardBg,
                    borderLine: borderLine,
                    mutedText: mutedText,
                    successGreen: successGreen,
                    numeroColis: widget.code,
                    expediteurNom: senderName,
                    expediteurTel: senderPhone,
                    expediteurVille: senderCity,
                    destinataireNom: recipientFullName.isEmpty
                        ? 'Destinataire'
                        : recipientFullName,
                    destinataireTel: widget.recipientPhone,
                    destinataireVille: recipientCity,
                    dateEnvoi: expeditionDate,
                    nature: widget.parcelNature,
                    frais: frais,
                    quantity: widget.parcelCount,
                    trajet:
                        '${widget.departureCity} -> ${widget.destinationCity}',
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 28,
              child: _ExpandableFabMenu(
                blue: logoBlue,
                red: const Color(0xFFE53935),
                isOpen: _isFabMenuOpen,
                onToggle: _toggleFabMenu,
                onSendParcel: _openSendParcelPage,
                onTrackParcel: _showTrackingMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Color logoBlue;

  const _Header({required this.logoBlue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.menu_rounded),
                color: logoBlue,
              ),
            ),
            // Logo centre pour garder l'identite Fofana visible sur la page.
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: logoBlue.withValues(alpha: 0.12)),
              ),
              child: Image.asset(
                'assets/images/logo_fofana_no_background.png',
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_none_rounded, color: logoBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color blue;

  const _SectionTitle({required this.title, required this.blue});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: blue, fontWeight: FontWeight.w900, fontSize: 26),
    );
  }
}

class _ExpandableFabMenu extends StatelessWidget {
  final Color blue;
  final Color red;
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onSendParcel;
  final VoidCallback onTrackParcel;

  const _ExpandableFabMenu({
    required this.blue,
    required this.red,
    required this.isOpen,
    required this.onToggle,
    required this.onSendParcel,
    required this.onTrackParcel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isOpen
              ? Column(
                  key: const ValueKey('parcel-fab-actions'),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _FabActionChip(
                      icon: Icons.outbox_rounded,
                      label: 'Envoi de colis',
                      color: red,
                      onTap: onSendParcel,
                    ),
                    const SizedBox(height: 10),
                    _FabActionChip(
                      icon: Icons.manage_search_rounded,
                      label: 'Suivre',
                      color: blue,
                      onTap: onTrackParcel,
                    ),
                    const SizedBox(height: 14),
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('parcel-fab-closed')),
        ),
        Material(
          elevation: 10,
          shape: const CircleBorder(),
          color: isOpen ? red : blue,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onToggle,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Center(
                child: AnimatedRotation(
                  turns: isOpen ? 0.125 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    isOpen ? Icons.close_rounded : Icons.add_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FabActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FabActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 48,
          padding: const EdgeInsets.fromLTRB(14, 6, 16, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.14)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0B4F2A),
                  fontSize: 14.5,
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

class _ParcelCard extends StatelessWidget {
  final Color cardBg;
  final Color borderLine;
  final Color mutedText;
  final Color successGreen;

  final String numeroColis;
  final String expediteurNom;
  final String expediteurTel;
  final String expediteurVille;

  final String destinataireNom;
  final String destinataireTel;
  final String destinataireVille;

  final String dateEnvoi;
  final String nature;
  final String frais;

  final int quantity;
  final String trajet;

  const _ParcelCard({
    required this.cardBg,
    required this.borderLine,
    required this.mutedText,
    required this.successGreen,
    required this.numeroColis,
    required this.expediteurNom,
    required this.expediteurTel,
    required this.expediteurVille,
    required this.destinataireNom,
    required this.destinataireTel,
    required this.destinataireVille,
    required this.dateEnvoi,
    required this.nature,
    required this.frais,
    required this.quantity,
    required this.trajet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderLine),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'N° du colis',
                      style: TextStyle(
                        color: Color(0xFF95A0B6),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      numeroColis,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0B4F2A),
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(text: 'Enregistre', successGreen: successGreen),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: borderLine),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoBlock(
                  title: 'Expediteur',
                  mutedText: mutedText,
                  lines: [expediteurNom, expediteurTel, expediteurVille],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBlock(
                  title: 'Destinataire',
                  mutedText: mutedText,
                  lines: [destinataireNom, destinataireTel, destinataireVille],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: borderLine),
          const SizedBox(height: 14),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Date d\'envoi',
              style: TextStyle(
                color: mutedText,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dateEnvoi,
            style: const TextStyle(
              color: Color(0xFF0B4F2A),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: borderLine),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _BottomRowBlock(
                  title: 'Nature du colis',
                  value: '$nature x$quantity',
                  mutedText: mutedText,
                ),
              ),
              Expanded(
                child: _BottomRowBlock(
                  title: 'Frais',
                  value: frais,
                  mutedText: mutedText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            'Trajet',
            style: TextStyle(
              color: mutedText,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            trajet,
            style: const TextStyle(
              color: Color(0xFF0B4F2A),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 14),
          Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0B4F2A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'Effectuer le reglement',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color successGreen;

  const _StatusPill({required this.text, required this.successGreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: successGreen.withValues(alpha: 0.55)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: successGreen,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.check_rounded, size: 20, color: successGreen),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final Color mutedText;
  final List<String> lines;

  const _InfoBlock({
    required this.title,
    required this.mutedText,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: mutedText,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        for (final line in lines) ...[
          Text(
            line,
            style: const TextStyle(
              color: Color(0xFF0B4F2A),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _BottomRowBlock extends StatelessWidget {
  final String title;
  final String value;
  final Color mutedText;

  const _BottomRowBlock({
    required this.title,
    required this.value,
    required this.mutedText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: mutedText,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0B4F2A),
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
