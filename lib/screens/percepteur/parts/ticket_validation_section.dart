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
  bool _isValidating = false;
  StaffTicketModel? _ticketData;
  String? _errorMessage;
  String? _lastScannedPayload;
  final TextEditingController _manualCodeController = TextEditingController();
  final _ticketService = StaffTicketService();

  @override
  void dispose() {
    _manualCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadAndShowTicket({String? code}) async {
    final rawCode = (code ?? _scannedCode ?? '').trim();
    if (rawCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun code a charger.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    final ref = ticketReferenceFromQr(rawCode);
    if (ref == null || ref.isEmpty) {
      setState(() {
        _scannedCode = null;
        _ticketVisible = false;
        _ticketData = null;
        _errorMessage =
            'Ce QR code ne contient pas la référence du ticket. '
            'Saisissez manuellement la référence imprimée sur le billet.';
      });
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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('Bad state: ', '');
      });
    }
  }

  void _onQrDetected(String payload) {
    final value = payload.trim();
    if (value.isEmpty || _isLoading || value == _lastScannedPayload) return;
    _lastScannedPayload = value;
    _loadAndShowTicket(code: value);
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

  Future<void> _validateBoarding() async {
    final ticket = _ticketData;
    if (ticket == null || !ticket.canValidateBoarding || _isValidating) return;

    setState(() => _isValidating = true);
    final result = await _ticketService.validerEmbarquement(ticket.id);
    if (!mounted) return;

    final success = result['success'] as bool? ?? false;
    if (success) {
      final returnedTicket = result['ticket'] as StaffTicketModel?;
      final updatedTicket = ticket.copyWith(
        statut: returnedTicket?.statut ?? 'utilisé',
        statutPaiement: returnedTicket?.statutPaiement,
      );
      setState(() {
        _ticketData = updatedTicket;
        _isValidating = false;
      });
      ControleurScannedTicketStore.addFromApi(updatedTicket);
    } else {
      setState(() => _isValidating = false);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? ''),
        backgroundColor: success
            ? const Color(0xFF16A34A)
            : const Color(0xFFE53935),
      ),
    );
  }

  Future<void> _openManualValidationDialog() async {
    _manualCodeController.text = '';

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
              labelText: 'Référence du ticket',
              hintText: 'FV-TKT-20260930-ABCD',
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
              child: const Text('Rechercher'),
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
                          _onQrDetected(value);
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
                            _isLoading
                                ? 'Recherche du ticket...'
                                : _scannedCode == null
                                ? 'Placez le QR code du ticket dans le cadre'
                                : 'Référence détectée : $_scannedCode',
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
                        onPressed: _scannedCode == null || _isLoading
                            ? null
                            : _validateCurrentScan,
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Rechercher'),
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
                  isValidating: _isValidating,
                  onValider: _isValidating ? null : _validateBoarding,
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
  final bool isValidating;

  const _TicketInfoCard({
    required this.ticket,
    this.onValider,
    this.isValidating = false,
  });

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    final dateOnly = value.split(RegExp(r'[T ]')).first;
    final parts = dateOnly.split('-');
    if (parts.length == 3 && parts[0].length == 4) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return value;
  }

  String _formatMoney(double? value) {
    if (value == null) return '';
    final formatted = value.round().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)} ',
    );
    return '$formatted FCFA';
  }

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    const red = Color(0xFFE53935);
    const green = Color(0xFF16A34A);

    final isEmbarque = ticket.isBoarded;
    final statusColor = ticket.canValidateBoarding
        ? const Color(0xFF2563EB)
        : isEmbarque
        ? green
        : red;

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
                child: Icon(
                  isEmbarque
                      ? Icons.verified_rounded
                      : Icons.confirmation_number_rounded,
                  color: statusColor,
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
            PercepteurTicketInfoRow(
              title: 'Date du voyage',
              value: _formatDate(ticket.dateVoyage),
            ),
          if (ticket.heureVoyage != null && ticket.heureVoyage!.isNotEmpty)
            PercepteurTicketInfoRow(title: 'Heure', value: ticket.heureVoyage!),
          if (ticket.busMatricule?.isNotEmpty ?? false)
            PercepteurTicketInfoRow(
              title: 'Bus',
              value: [ticket.busMatricule, ticket.busMarque]
                  .whereType<String>()
                  .where((value) => value.isNotEmpty)
                  .join(' · '),
            ),
          if (ticket.classe?.isNotEmpty ?? false)
            PercepteurTicketInfoRow(title: 'Classe', value: ticket.classe!),
          if (ticket.nombrePlaces != null)
            PercepteurTicketInfoRow(
              title: 'Nombre de places',
              value: ticket.nombrePlaces.toString(),
            ),
          if (ticket.numPlace != null && ticket.numPlace!.isNotEmpty)
            PercepteurTicketInfoRow(title: 'Siège', value: ticket.numPlace!),
          if (ticket.tarifUnitaire != null)
            PercepteurTicketInfoRow(
              title: 'Tarif unitaire',
              value: _formatMoney(ticket.tarifUnitaire),
            ),
          if (ticket.montantBase != null)
            PercepteurTicketInfoRow(
              title: 'Montant HT',
              value: _formatMoney(ticket.montantBase),
            ),
          if (ticket.tauxTaxe != null || ticket.montantTaxe != null)
            PercepteurTicketInfoRow(
              title: 'Taxe',
              value:
                  '${ticket.tauxTaxe == null ? '' : '${ticket.tauxTaxe}%'}'
                  '${ticket.tauxTaxe != null && ticket.montantTaxe != null ? ' · ' : ''}'
                  '${ticket.montantTaxe == null ? '' : _formatMoney(ticket.montantTaxe)}',
            ),
          if (ticket.montantTotal != null)
            PercepteurTicketInfoRow(
              title: 'Montant total',
              value: _formatMoney(ticket.montantTotal),
            ),
          if (ticket.modePaiement?.isNotEmpty ?? false)
            PercepteurTicketInfoRow(
              title: 'Mode de paiement',
              value: ticket.modePaiement!,
            ),
          PercepteurTicketInfoRow(
            title: 'Paiement',
            value: ticket.statutPaiementLabel,
            color: ticket.canValidateBoarding ? green : null,
          ),
          if (ticket.emetteurNom?.isNotEmpty ?? false)
            PercepteurTicketInfoRow(
              title: 'Émis par',
              value: ticket.emetteurNom!,
            ),
          PercepteurTicketInfoRow(
            title: 'Statut',
            value: ticket.statutLabel,
            color: statusColor,
          ),
          if (ticket.canValidateBoarding && onValider != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isValidating ? null : onValider,
                icon: isValidating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  isValidating
                      ? 'Validation en cours...'
                      : 'Valider embarquement',
                ),
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
          ] else ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    isEmbarque
                        ? Icons.check_circle_outline_rounded
                        : Icons.info_outline_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEmbarque
                          ? 'Embarquement déjà validé.'
                          : ticket.statutPaiementLabel != 'Payé'
                          ? 'Validation impossible : le paiement du ticket n’est pas confirmé.'
                          : 'Ticket non valide pour embarquement (statut : ${ticket.statutLabel}).',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
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
