import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:code_initial/models/access_session_model.dart';
import 'package:code_initial/models/controleur_models.dart';
import 'package:code_initial/services/affectation_service.dart';
import 'package:code_initial/services/staff_ticket_service.dart';

// Consultation de billet et cartes d information associees.
// Donne acces aux vraies donnees ticket via GET /api/tickets/{reference}
// ou recherche les donnees MECeF sans modifier le ticket.

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
  String? _lastScannedPayload;
  bool _hasActiveSession = false;
  bool _isCheckingSession = true;
  bool _isValidating = false;
  bool _isCancelling = false;
  String? _sessionError;
  final TextEditingController _manualReferenceController =
      TextEditingController();
  final TextEditingController _manualMecefCodeController =
      TextEditingController();
  final TextEditingController _manualNimController = TextEditingController();
  final _ticketService = StaffTicketService();
  final _accessService = AffectationService();

  @override
  void initState() {
    super.initState();
    _refreshSessionStatus();
  }

  @override
  void dispose() {
    _manualReferenceController.dispose();
    _manualMecefCodeController.dispose();
    _manualNimController.dispose();
    super.dispose();
  }

  Future<void> _loadAndShowTicket({
    String? code,
    String? mecefCode,
    String? nim,
    bool manualReference = false,
  }) async {
    final rawCode = (code ?? _scannedCode ?? '').trim();
    final enteredMecefCode = (mecefCode ?? '').trim();
    final enteredNim = (nim ?? '').trim();
    final hasMecefCode = enteredMecefCode.isNotEmpty;
    final hasNim = enteredNim.isNotEmpty;

    if (hasMecefCode != hasNim) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pour une recherche MECeF, renseignez le code et le NIM.',
          ),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    final mecefQr = mecefTicketDataFromQr(rawCode);
    final reference = ticketReferenceFromQr(rawCode);
    final searchByMecef = hasMecefCode || mecefQr != null;
    final searchCode = hasMecefCode ? enteredMecefCode : mecefQr?.code;
    final searchNim = hasNim ? enteredNim : mecefQr?.nim;

    if (!searchByMecef && (reference == null || reference.isEmpty)) {
      setState(() {
        _scannedCode = null;
        _ticketVisible = false;
        _ticketData = null;
        _errorMessage =
            'QR code non reconnu. Scannez le QR du ticket ou le QR MECeF '
            'au format F;NIM;CODE;IFU;DATE.';
      });
      return;
    }
    if (searchByMecef && (searchCode == null || searchNim == null)) {
      setState(() {
        _ticketVisible = false;
        _ticketData = null;
        _errorMessage =
            'Le QR MECeF ne contient pas le code et le NIM attendus.';
      });
      return;
    }

    setState(() {
      _scannedCode = searchByMecef ? 'F;$searchNim;$searchCode' : reference;
      _isLoading = true;
      _ticketVisible = false;
      _ticketData = null;
      _errorMessage = null;
    });

    try {
      final ticket = searchByMecef
          ? await _ticketService.getTicketByMecef(
              code: searchCode!,
              nim: searchNim!,
            )
          : await _ticketService.getTicketByReference(reference!);
      if (!mounted) return;
      if (ticket != null) {
        if (manualReference && ticket.isMecefCertified) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Ce ticket est certifié MECeF. Renseignez son code MECeF et son NIM pour le vérifier.';
          });
          return;
        }
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
          _errorMessage = searchByMecef
              ? 'Aucun ticket correspondant au code MECeF et au NIM fournis.'
              : 'Ticket introuvable : $reference';
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
          content: Text('Scannez un QR code avant de rechercher le ticket.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }
    _loadAndShowTicket();
  }

  Future<void> _refreshSessionStatus() async {
    try {
      final response = await _accessService.getMySession();
      if (!mounted) return;
      setState(() {
        _hasActiveSession = AccessSession.fromJson(response).isActive;
        _sessionError = null;
        _isCheckingSession = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _hasActiveSession = false;
        _sessionError = error.toString().replaceFirst('Exception: ', '');
        _isCheckingSession = false;
      });
    }
  }

  Future<void> _validateBoarding() async {
    final ticket = _ticketData;
    if (ticket == null || !ticket.canValidateBoarding || _isValidating) return;

    setState(() {
      _isValidating = true;
      _isCheckingSession = true;
      _sessionError = null;
    });
    try {
      final sessionResponse = await _accessService.getMySession();
      final sessionActive = AccessSession.fromJson(sessionResponse).isActive;
      if (!mounted) return;
      setState(() {
        _hasActiveSession = sessionActive;
        _isCheckingSession = false;
      });
      if (!sessionActive) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ouvrez une section avant de valider un ticket.'),
            backgroundColor: Color(0xFFE53935),
          ),
        );
        return;
      }

      final result = await _ticketService.validerEmbarquement(ticket.id);
      if (!mounted) return;
      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ?? 'Validation refusée.',
            ),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
        return;
      }
      setState(() {
        _ticketData =
            result['ticket'] as StaffTicketModel? ??
            ticket.copyWith(statut: 'utilisé');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Embarquement validé avec succès.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sessionError = error.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_sessionError!),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  Future<void> _cancelCurrentTicket() async {
    final ticket = _ticketData;
    if (ticket == null || _isCancelling || ticket.statut != 'en_cours') return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler le ticket ?'),
        content: Text(
          'Voulez-vous annuler le ticket ${ticket.reference} ? Un avoir sera créé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Retour'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmer l’annulation'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    try {
      final result = await _ticketService.annulerTicket(ticket.id);
      if (!mounted) return;
      setState(() {
        _ticketData = StaffTicketModel.fromJson(
          result['ticket'] is Map
              ? Map<String, dynamic>.from(result['ticket'] as Map)
              : {
                  'id': ticket.id,
                  'reference': ticket.reference,
                  'statut': 'annule',
                },
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Ticket annulé et avoir créé.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  Future<void> _openManualValidationDialog() async {
    _manualReferenceController.clear();
    _manualMecefCodeController.clear();
    _manualNimController.clear();

    final ticketType = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Type de ticket',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text('Le ticket est-il certifié par MECeF ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'sans_mecef'),
            child: const Text('Sans MECeF'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, 'mecef'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Avec MECeF'),
          ),
        ],
      ),
    );
    if (ticketType == null || !mounted) return;
    final isMecef = ticketType == 'mecef';

    final values = await showDialog<Map<String, String>?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            isMecef ? 'Ticket certifié MECeF' : 'Ticket sans MECeF',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMecef
                      ? 'Saisissez le code MECeF et le NIM du ticket.'
                      : 'Saisissez la référence du ticket.',
                ),
                const SizedBox(height: 14),
                if (!isMecef)
                  TextField(
                    controller: _manualReferenceController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Référence du ticket',
                      hintText: 'FV-TKT-20260930-ABCD',
                    ),
                  ),
                if (isMecef) ...[
                  TextField(
                    controller: _manualMecefCodeController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Code MECeF'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _manualNimController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(labelText: 'NIM'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final reference = _manualReferenceController.text.trim();
                final code = _manualMecefCodeController.text.trim();
                final nim = _manualNimController.text.trim();
                if (isMecef && (code.isEmpty || nim.isEmpty) ||
                    !isMecef && reference.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Renseignez tous les champs demandés pour ce type de ticket.',
                      ),
                      backgroundColor: Color(0xFFE53935),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, {
                  'reference': reference,
                  'code': code,
                  'nim': nim,
                });
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
    if (values == null || !mounted) return;
    await _loadAndShowTicket(
      code: isMecef ? null : values['reference'],
      mecefCode: isMecef ? values['code'] : null,
      nim: isMecef ? values['nim'] : null,
      manualReference: !isMecef,
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
          'Consultation ticket',
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
                                ? 'Scannez le QR du ticket ou le QR MECeF'
                                : 'Code détecté : ${mecefTicketDataFromQr(_scannedCode!)?.code ?? _scannedCode}',
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
                        label: const Text('Recherche manuelle'),
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
                  hasActiveSession: _hasActiveSession,
                  isCheckingSession: _isCheckingSession,
                  isValidating: _isValidating,
                  isCancelling: _isCancelling,
                  sessionError: _sessionError,
                  onValidateBoarding: _validateBoarding,
                  onCancelTicket: _cancelCurrentTicket,
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
  final bool hasActiveSession;
  final bool isCheckingSession;
  final bool isValidating;
  final bool isCancelling;
  final String? sessionError;
  final VoidCallback onValidateBoarding;
  final VoidCallback onCancelTicket;

  const _TicketInfoCard({
    required this.ticket,
    required this.hasActiveSession,
    required this.isCheckingSession,
    required this.isValidating,
    required this.isCancelling,
    required this.sessionError,
    required this.onValidateBoarding,
    required this.onCancelTicket,
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
            title: 'Certification',
            value: ticket.isMecefCertified
                ? 'MECeF certifié'
                : 'Non certifié MECeF',
            color: ticket.isMecefCertified ? green : null,
          ),
          if (ticket.isMecefCertified) ...[
            PercepteurTicketInfoRow(
              title: 'Code MECeF',
              value: ticket.mecefCode!,
            ),
            PercepteurTicketInfoRow(title: 'NIM', value: ticket.mecefNim!),
          ],
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
                        : ticket.canValidateBoarding
                        ? 'Ticket payé, en attente de validation d’embarquement.'
                        : ticket.statutPaiementLabel != 'Payé'
                        ? 'Le paiement du ticket n’est pas confirmé.'
                        : 'Statut du ticket : ${ticket.statutLabel}.',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (ticket.canValidateBoarding && !isEmbarque) ...[
            const SizedBox(height: 14),
            if (!hasActiveSession && !isCheckingSession)
              Text(
                sessionError ??
                    'Ouvrez une section avant de valider ce ticket.',
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    hasActiveSession && !isCheckingSession && !isValidating
                    ? onValidateBoarding
                    : null,
                icon: isValidating || isCheckingSession
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.how_to_reg_rounded),
                label: Text(
                  isValidating
                      ? 'Validation en cours...'
                      : 'Valider l’embarquement',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
          if (ticket.statut == 'en_cours') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isCancelling ? null : onCancelTicket,
                icon: isCancelling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel_outlined),
                label: Text(
                  isCancelling ? 'Annulation en cours...' : 'Annuler le ticket',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE53935),
                  side: const BorderSide(color: Color(0xFFE53935)),
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
