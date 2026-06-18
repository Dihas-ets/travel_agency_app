part of '../collector_home_page.dart';

// Validation de billet et cartes d information associees.

class _TicketValidationPage extends StatefulWidget {
  const _TicketValidationPage();

  @override
  State<_TicketValidationPage> createState() => _TicketValidationPageState();
}

class _TicketValidationPageState extends State<_TicketValidationPage> {
  String? _scannedCode;
  bool _ticketVisible = false;

  void _showTicket() {
    setState(() {
      _scannedCode ??= 'TK-2026-0487';
      _ticketVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7EF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Validation ticket',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        onDetect: (capture) {
                          if (capture.barcodes.isEmpty) return;
                          final value = capture.barcodes.first.rawValue;
                          if (value == null || value.trim().isEmpty) return;
                          setState(() => _scannedCode = value.trim());
                        },
                      ),
                      Container(color: Colors.black.withValues(alpha: 0.18)),
                      Center(
                        child: Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.48),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _scannedCode == null
                                ? 'Placez le QR code du ticket dans le cadre'
                                : 'Code détecté : $_scannedCode',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _showTicket,
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('Valider'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              if (_ticketVisible) ...[
                const SizedBox(height: 16),
                _TicketInfoCard(code: _scannedCode ?? 'TK-2026-0487'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketInfoCard extends StatelessWidget {
  final String code;

  const _TicketInfoCard({required this.code});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: red,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Infos du ticket',
                  style: TextStyle(
                    color: deepBlue,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TicketInfoRow(title: 'Code ticket', value: code),
          const _TicketInfoRow(title: 'Passager', value: 'Client Fofana'),
          const _TicketInfoRow(title: 'Trajet', value: 'Cotonou -> Parakou'),
          const _TicketInfoRow(title: 'Départ', value: '21/05/2026 à 08:30'),
          const _TicketInfoRow(title: 'Siège', value: '12A'),
          const _TicketInfoRow(title: 'Statut', value: 'Ticket valide'),
        ],
      ),
    );
  }
}

class _TicketInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _TicketInfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF0B4F2A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<String> _collectorBeninCities = [
  'Abomey',
  'Abomey-Calavi',
  'Adjohoun',
  'Allada',
  'Aplahoué',
  'Banikoara',
  'Bassila',
  'Bembèrèkè',
  'Bétérou',
  'Bohicon',
  'Cotonou',
  'Dassa-Zoumè',
  'Djougou',
  'Kandi',
  'Lokossa',
  'Natitingou',
  'Ouidah',
  'Parakou',
  'Porto-Novo',
  'Sakété',
  'Savalou',
  'Sèmè-Kpodji',
  'Tchaourou',
];

