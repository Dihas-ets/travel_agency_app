import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:code_initial/models/controleur_models.dart';
import 'package:code_initial/services/staff_ticket_service.dart';

// Validation de billet et cartes d information associees.
// Donne acces aux vraies donnees ticket via GET /api/tickets/{reference}
// et valide l embarquement via PATCH /api/tickets/{id}/valider.

class TicketValidationPage extends StatefulWidget {
  const TicketValidationPage({super.key});

  @override
  State<TicketValidationPage> createState() => _TicketValidationPageState();
}

class _TicketValidationPageState extends State<TicketValidationPage> {
  String? _scannedCode;
  bool _ticketVisible = false;
  bool _isLoading = false;
  StaffTicketModel? _ticketData;
  String? _errorMessage;
  final TextEditingController _manualCodeController = TextEditingController();
  final _ticketService = StaffTicketService();

  @override
  void dispose() {
    _manualCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadAndShowTicket({String? code}) async {
    final ref = (code ?? _scannedCode ?? '').trim();
    if (ref.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun code a charger.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    setState(() {
      _scannedCode = ref;
      _isLoading = true;
      _ticketVisible = false;
      _ticketData = null;
      _errorMessage = null;
    });

    try {
      final ticket = await _ticketService.getTicketByReference(ref);
      if (!mounted) return;
      if (ticket != null) {
        setState(() {
          _ticketData = ticket;
          _ticketVisible = true;
          _isLoading = false;
        });
        // Ajouter au store local pour l historique du controleur
        ControleurScannedTicketStore.addFromApi(ticket);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ticket introuvable : $ref';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de connexion. Verifiez votre reseau.';
      });
    }
  }

  void _validateCurrentScan() {
    if (_scannedCode == null || _scannedCode!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scannez un QR code avant de valider.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }
    _loadAndShowTicket();
  }

  Future<void> _openManualValidationDialog() async {
    _manualCodeController.text = _scannedCode ?? '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Validation manuelle',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: TextField(
            controller: _manualCodeController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Code du ticket',
              hintText: 'TK-2026-0001',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredCode = _manualCodeController.text.trim();
                if (enteredCode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez renseigner le code du ticket.'),
                      backgroundColor: Color(0xFFE53935),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                _loadAndShowTicket(code: enteredCode);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
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
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: _validateCurrentScan,
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text('Scanner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 58,
                      child: OutlinedButton.icon(
                        onPressed: _openManualValidationDialog,
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('Validation manuelle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B4F2A),
                          side: const BorderSide(color: Color(0xFF0B4F2A)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading) ...[
                const SizedBox(height: 24),
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF16A34A)),
                ),
              ],
              if (_errorMessage != null && !_isLoading) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE53935).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFE53935),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_ticketVisible && _ticketData != null && !_isLoading) ...[
                const SizedBox(height: 16),
                _TicketInfoCard(
                  ticket: _ticketData!,
                  onValider: () async {
                    final result = await _ticketService.validerEmbarquement(
                      _ticketData!.id,
                    );
                    if (!mounted) return;
                    final success = result['success'] as bool? ?? false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']?.toString() ?? ''),
                        backgroundColor: success
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFE53935),
                      ),
                    );
                    if (success && result['ticket'] != null) {
                      final updatedTicket =
                          result['ticket'] as StaffTicketModel;
                      setState(() => _ticketData = updatedTicket);
                      ControleurScannedTicketStore.addFromApi(updatedTicket);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketInfoCard extends StatelessWidget {
  final StaffTicketModel ticket;
  final VoidCallback? onValider;

  const _TicketInfoCard({required this.ticket, this.onValider});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);
    const green = Color(0xFF16A34A);

    final isEmbarque = ticket.statut == 'valide';
    final statusColor = isEmbarque ? green : red;

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
                  color: statusColor.withValues(alpha: 0.1),
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
          PercepteurTicketInfoRow(
            title: 'Code ticket',
            value: ticket.reference,
          ),
          PercepteurTicketInfoRow(
            title: 'Passager',
            value: ticket.fullPassengerName,
          ),
          if (ticket.numeroPassager != null &&
              ticket.numeroPassager!.isNotEmpty)
            PercepteurTicketInfoRow(
              title: 'Contact',
              value: ticket.numeroPassager!,
            ),
          PercepteurTicketInfoRow(title: 'Trajet', value: ticket.route),
          if (ticket.dateVoyage != null && ticket.dateVoyage!.isNotEmpty)
            PercepteurTicketInfoRow(title: 'Date', value: ticket.dateVoyage!),
          if (ticket.heureVoyage != null && ticket.heureVoyage!.isNotEmpty)
            PercepteurTicketInfoRow(title: 'Heure', value: ticket.heureVoyage!),
          if (ticket.numPlace != null && ticket.numPlace!.isNotEmpty)
            PercepteurTicketInfoRow(title: 'Siege', value: ticket.numPlace!),
          PercepteurTicketInfoRow(
            title: 'Statut',
            value: ticket.statutLabel,
            color: isEmbarque ? green : null,
          ),
          if (onValider != null && !isEmbarque) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onValider,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Valider embarquement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PercepteurTicketInfoRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;

  const PercepteurTicketInfoRow({
    super.key,
    required this.title,
    required this.value,
    this.color,
  });

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
              style: TextStyle(
                color: color ?? const Color(0xFF0B4F2A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const List<String> percepteurBeninCities = [
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
