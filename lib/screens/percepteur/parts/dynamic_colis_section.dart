import 'package:flutter/material.dart';
import 'package:code_initial/navigation.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/config/app_config.dart';
import 'package:code_initial/models/colis_model.dart';
import 'package:code_initial/models/store/colis_store.dart';
import 'package:code_initial/screens/client/colis/billet_page.dart';
import 'package:code_initial/screens/client/colis/pages_colis.dart';
import 'package:code_initial/services/colis_service.dart';

enum _ParcelTab {
  drafts,
  readyToShip,
  inTransit,
  arrived,
  delivered,
  issue,
  lost,
  cancelled,
  other,
}

class PercepteurDynamicColisSection extends StatefulWidget {
  const PercepteurDynamicColisSection({super.key});

  @override
  State<PercepteurDynamicColisSection> createState() =>
      _PercepteurDynamicColisSectionState();
}

class _PercepteurDynamicColisSectionState
    extends State<PercepteurDynamicColisSection> {
  static const Color _green = Color(0xFF16A34A);
  static const Color _deepGreen = Color(0xFF0B4F2A);
  static const Color _muted = Color(0xFF5F6B86);

  final ColisService _colisService = ColisService();
  final TextEditingController _searchController = TextEditingController();
  List<ColisModel> _parcels = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  _ParcelTab _selectedTab = _ParcelTab.drafts;
  bool _isProcessingParcel = false;

  @override
  void initState() {
    super.initState();
    _loadParcels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParcels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final parcels = await _colisService.getColisStaff();
      if (!mounted) return;
      setState(() {
        _parcels = parcels;
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

  Future<void> _openCreateParcel() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            const SendParcelPage(showModeTabs: false, isPercepteur: true),
      ),
    );
    if (created == true && mounted) await _loadParcels();
  }

  Future<void> _openDraftForFinalization(ColisModel parcel) async {
    try {
      final latestParcel = await _colisService.showColis(parcel.reference);
      if (latestParcel == null) {
        throw Exception('Le brouillon ${parcel.reference} est introuvable.');
      }
      if (!mounted) return;
      final finalized = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => SendParcelPage(
            showModeTabs: false,
            isPercepteur: true,
            initialParcel: latestParcel,
          ),
        ),
      );
      if (finalized == true && mounted) await _loadParcels();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de charger les informations du brouillon : '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<ColisModel> get _visibleParcels {
    final query = _searchQuery.trim().toLowerCase();

    return _parcels.where((parcel) {
      if (!_matchesSelectedTab(parcel)) return false;
      if (query.isEmpty) return true;

      return parcel.reference.toLowerCase().contains(query) ||
          (parcel.expediteurNom ?? '').toLowerCase().contains(query) ||
          (parcel.expediteurTel ?? '').toLowerCase().contains(query) ||
          (parcel.destinataireNom ?? '').toLowerCase().contains(query) ||
          (parcel.destinataireTel ?? '').toLowerCase().contains(query) ||
          (parcel.agenceDepotNom ?? '').toLowerCase().contains(query) ||
          (parcel.agenceRetraitNom ?? '').toLowerCase().contains(query);
    }).toList();
  }

  bool _isClientPreRegistrationForAgency(ColisModel parcel) {
    final agencyId = SessionStore.currentUser?.agenceId;
    return parcel.origine.trim().toLowerCase() == 'en_externe' &&
        _normalizeStatus(parcel.statut) == 'brouillon' &&
        agencyId != null &&
        parcel.agenceDepotId == agencyId;
  }

  bool _matchesSelectedTab(ColisModel parcel) =>
      _matchesTab(parcel, _selectedTab);

  bool _matchesTab(ColisModel parcel, _ParcelTab tab) {
    final status = _normalizeStatus(parcel.statut);
    final isClientParcel = parcel.origine.trim().toLowerCase() == 'en_externe';

    return switch (tab) {
      _ParcelTab.drafts =>
        status == 'brouillon' &&
            (!isClientParcel || _isClientPreRegistrationForAgency(parcel)),
      _ParcelTab.readyToShip => status == 'a_expedier',
      _ParcelTab.inTransit => status == 'en_transit',
      _ParcelTab.arrived => status == 'arrive',
      _ParcelTab.delivered => status == 'livre',
      _ParcelTab.issue => status == 'litige',
      _ParcelTab.lost => status == 'perdu',
      _ParcelTab.cancelled => status == 'annule',
      _ParcelTab.other => !const {
        'brouillon',
        'a_expedier',
        'en_transit',
        'arrive',
        'livre',
        'litige',
        'perdu',
        'annule',
      }.contains(status),
    };
  }

  String _normalizeStatus(String status) => status
      .trim()
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('à', 'a')
      .replaceAll('ù', 'u')
      .replaceAll(' ', '_');

  bool _isPaid(ColisModel parcel) => const {
    'paye',
    'paid',
    'success',
    'successful',
  }.contains(_normalizeStatus(parcel.statutPaiement));

  void _showDetails(ColisModel parcel) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parcel.reference,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _deepGreen,
                ),
              ),
              const SizedBox(height: 8),
              _detailLine('Statut', _statusLabel(parcel.statut)),
              _detailLine('Paiement', _paymentLabel(parcel.statutPaiement)),
              _detailLine(
                'Trajet',
                '${parcel.agenceDepotNom ?? 'Départ'} → ${parcel.agenceRetraitNom ?? 'Retrait'}',
              ),
              _detailLine(
                'Expéditeur',
                '${parcel.expediteurNom ?? '—'} · ${parcel.expediteurTel ?? '—'}',
              ),
              _detailLine(
                'Destinataire',
                '${parcel.destinataireNom ?? '—'} · ${parcel.destinataireTel ?? '—'}',
              ),
              _detailLine('Mode', parcel.modePaiement),
              _detailLine(
                'Montant',
                '${parcel.montant.toStringAsFixed(0)} FCFA',
              ),
              _detailLine(
                'Base / taxe',
                '${parcel.montantBase.toStringAsFixed(0)} / ${parcel.montantTaxe.toStringAsFixed(0)} FCFA',
              ),
              if (parcel.tauxTaxe > 0)
                _detailLine(
                  'Taux de taxe',
                  '${parcel.tauxTaxe.toStringAsFixed(2)} %',
                ),
              _detailLine(
                'Valeur estimée',
                '${parcel.valeurEstime.toStringAsFixed(0)} FCFA',
              ),
              const SizedBox(height: 12),
              const Text(
                'Contenu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              if (parcel.colisDetails.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Aucun détail disponible.'),
                )
              else
                _parcelContents(parcel),
              if (_isClientPreRegistrationForAgency(parcel) &&
                  !_isPaid(parcel)) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isProcessingParcel
                        ? null
                        : () => _processClientPreRegistration(parcel, context),
                    icon: const Icon(Icons.point_of_sale_rounded),
                    label: const Text('Encaisser et traiter le colis'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              if (_isPaid(parcel) &&
                  _normalizeStatus(parcel.statut) != 'annule') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _printParcel(parcel);
                    },
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Imprimer le bordereau'),
                  ),
                ),
              ],
              if (_canCancel(parcel)) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isProcessingParcel
                        ? null
                        : () => _confirmCancel(parcel, context),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Annuler le colis'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailLine(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: _muted)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  Widget _parcelContents(ColisModel parcel) {
    final totalItems = parcel.colisDetails.fold<int>(
      0,
      (total, detail) => total + detail.nombre,
    );
    var itemNumber = 0;
    return Column(
      children: [
        for (final detail in parcel.colisDetails)
          for (var index = 0; index < detail.nombre; index++)
            _parcelItemTile(detail, ++itemNumber, totalItems),
      ],
    );
  }

  Widget _parcelItemTile(
    ColisDetailItem detail,
    int itemNumber,
    int totalItems,
  ) {
    final imageUrl = _parcelImageUrl(detail.imagePath);
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 76,
                height: 76,
                child: imageUrl == null
                    ? const ColoredBox(
                        color: Color(0xFFEAF7EF),
                        child: Icon(Icons.inventory_2_outlined, color: _green),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Color(0xFFEAF7EF),
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: _muted,
                          ),
                        ),
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : const ColoredBox(
                                color: Color(0xFFEAF7EF),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Colis $itemNumber / $totalItems · ${detail.nature}',
                    style: const TextStyle(
                      color: _deepGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Poids : ${detail.poids > 0 ? '${detail.poids.toStringAsFixed(2)} kg' : 'non renseigné'}',
                  ),
                  Text(
                    'Description : ${detail.description.trim().isEmpty ? 'Aucune description' : detail.description.trim()}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _parcelImageUrl(String? imagePath) {
    final path = imagePath?.trim();
    if (path == null || path.isEmpty) return null;
    final parsed = Uri.tryParse(path);
    if (parsed != null && parsed.hasScheme && parsed.hasAuthority) {
      return parsed.toString();
    }

    final apiUri = Uri.parse(AppConfig.apiBaseUrl);
    final segments = apiUri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (segments.isNotEmpty && segments.last.toLowerCase() == 'api') {
      segments.removeLast();
    }
    final storageBase = apiUri.replace(
      pathSegments: [...segments, ''],
      query: null,
      fragment: null,
    );
    final relativePath = path
        .replaceFirst(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'^storage/+'), '');
    return storageBase.resolve('storage/$relativePath').toString();
  }

  String _statusLabel(String status) => switch (_normalizeStatus(status)) {
    'brouillon' => 'Préenregistré',
    'a_expedier' => 'À expédier',
    'en_transit' => 'En transit',
    'arrive' => 'Arrivé',
    'livre' => 'Livré',
    'litige' => 'En litige',
    'perdu' => 'Perdu',
    'annule' => 'Annulé',
    _ => status,
  };

  String _paymentLabel(String status) {
    final normalized = _normalizeStatus(status);
    if (const {'paye', 'paid', 'success', 'successful'}.contains(normalized)) {
      return 'Payé';
    }
    if (const {'en_attente_paiement', 'pending'}.contains(normalized)) {
      return 'Paiement en attente';
    }
    return status.isEmpty ? 'Paiement non renseigné' : status;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 2, 2, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_shipping_rounded, color: _green),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Espace colis',
                      style: TextStyle(
                        color: _deepGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Suivi et traitement des envois de votre agence',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildTabs(),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'Actualiser',
            onPressed: _isLoading ? null : _loadParcels,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _openCreateParcel,
            icon: const Icon(Icons.add_box_rounded),
            label: const Text('Enregistrer un colis'),
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Référence, nom ou téléphone',
            prefixIcon: const Icon(Icons.search_rounded, color: _green),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildTabs() => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _tabButton('Brouillons', Icons.edit_note_rounded, _ParcelTab.drafts),
          _tabButton(
            'À expédier',
            Icons.outbox_rounded,
            _ParcelTab.readyToShip,
          ),
          _tabButton(
            'En transit',
            Icons.local_shipping_rounded,
            _ParcelTab.inTransit,
          ),
          _tabButton('Arrivés', Icons.place_rounded, _ParcelTab.arrived),
          _tabButton('Livrés', Icons.task_alt_rounded, _ParcelTab.delivered),
          _tabButton(
            'En litige',
            Icons.report_problem_outlined,
            _ParcelTab.issue,
          ),
          _tabButton('Perdus', Icons.search_off_rounded, _ParcelTab.lost),
          _tabButton('Annulés', Icons.cancel_outlined, _ParcelTab.cancelled),
          _tabButton('Autres', Icons.more_horiz_rounded, _ParcelTab.other),
        ],
      ),
    ),
  );

  int _countForTab(_ParcelTab tab) =>
      _parcels.where((parcel) => _matchesTab(parcel, tab)).length;

  Widget _tabButton(String label, IconData icon, _ParcelTab tab) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _selectedTab = tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          color: _selectedTab == tab ? _green : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: _selectedTab == tab ? Colors.white : _deepGreen,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: _selectedTab == tab ? Colors.white : _deepGreen,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '${_countForTab(tab)}',
              style: TextStyle(
                color: _selectedTab == tab ? Colors.white : _muted,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadParcels,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final parcels = _visibleParcels;
    if (parcels.isEmpty) {
      return Center(child: _emptyMessage());
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 86),
      itemCount: parcels.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _parcelCard(parcels[index]),
    );
  }

  Widget _emptyMessage() {
    final message = switch (_selectedTab) {
      _ParcelTab.drafts =>
        'Aucun brouillon ni colis préenregistré pour cette agence.',
      _ParcelTab.readyToShip => 'Aucun colis à expédier.',
      _ParcelTab.inTransit => 'Aucun colis en transit.',
      _ParcelTab.arrived => 'Aucun colis arrivé.',
      _ParcelTab.delivered => 'Aucun colis livré.',
      _ParcelTab.issue => 'Aucun colis en litige.',
      _ParcelTab.lost => 'Aucun colis déclaré perdu.',
      _ParcelTab.cancelled => 'Aucun colis annulé.',
      _ParcelTab.other => 'Aucun autre colis.',
    };
    return Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: _muted, fontWeight: FontWeight.w700),
    );
  }

  Widget _parcelCard(ColisModel parcel) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _deepGreen.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  parcel.reference,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _deepGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              _statusBadge(_statusLabel(parcel.statut)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${parcel.agenceDepotNom ?? 'Départ'} → ${parcel.agenceRetraitNom ?? 'Retrait'}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${parcel.expediteurNom ?? 'Expéditeur'} → ${parcel.destinataireNom ?? 'Destinataire'}',
            style: const TextStyle(color: _muted),
          ),
          const SizedBox(height: 4),
          Text(
            '${_paymentLabel(parcel.statutPaiement)} · ${parcel.montant.toStringAsFixed(0)} FCFA · ${parcel.colisDetails.length} détail(s)',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _normalizeStatus(parcel.statut) == 'brouillon'
                      ? () => _openDraftForFinalization(parcel)
                      : () => _showDetails(parcel),
                  icon: Icon(
                    _normalizeStatus(parcel.statut) == 'brouillon'
                        ? Icons.edit_note_rounded
                        : Icons.inventory_2_outlined,
                    size: 18,
                  ),
                  label: Text(
                    _normalizeStatus(parcel.statut) == 'brouillon'
                        ? 'Finaliser le colis'
                        : 'Nature et montant',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canCancel(ColisModel parcel) =>
      !{'livre', 'perdu', 'annule'}.contains(_normalizeStatus(parcel.statut)) &&
      parcel.montant > 0;

  Future<void> _processClientPreRegistration(
    ColisModel parcel,
    BuildContext sheetContext,
  ) async {
    final amountController = TextEditingController(
      text: parcel.montant > 0 ? parcel.montant.toStringAsFixed(0) : '',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, _) => AlertDialog(
          title: const Text('Traiter le colis préenregistré'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Confirmez l’encaissement en espèces avant de faire passer '
                '${parcel.reference} au statut « À expédier ». ',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant encaissé',
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(
                  amountController.text.trim().replaceAll(',', '.'),
                );
                if (amount == null || amount <= 0) return;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirmer l’encaissement'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) {
      amountController.dispose();
      return;
    }
    final amount = double.tryParse(
      amountController.text.trim().replaceAll(',', '.'),
    );
    amountController.dispose();
    if (amount == null || amount <= 0) return;

    setState(() => _isProcessingParcel = true);
    try {
      await _colisService.validerColisStaff(
        id: parcel.id,
        modePaiement: 'ESPECES',
        montant: amount,
      );
      if (!mounted || !sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement confirmé et colis traité.')),
      );
      await _loadParcels();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de traiter le colis : '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessingParcel = false);
    }
  }

  Future<void> _confirmCancel(
    ColisModel parcel,
    BuildContext sheetContext,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler ce colis ?'),
        content: Text(
          'Le colis ${parcel.reference} sera marqué comme annulé. '
          'Le traitement du remboursement suivra les règles du système.',
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

    setState(() => _isProcessingParcel = true);
    try {
      await _colisService.annulerColisStaff(parcel.id);
      if (!mounted || !sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Colis annulé avec succès.')),
      );
      await _loadParcels();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible d’annuler le colis : '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessingParcel = false);
    }
  }

  Future<void> _printParcel(ColisModel parcel) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BilletPage(
          onReturnToHome: () => Navigator.of(
            context,
          rootNavigator: true,
        ).popUntil((route) => route.isFirst),
          code: parcel.reference,
          departureCity: parcel.agenceDepotNom ?? 'Départ',
          destinationCity: parcel.agenceRetraitNom ?? 'Retrait',
          recipientLastName: parcel.destinataireNom ?? '',
          recipientFirstName: '',
          recipientPhone: parcel.destinataireTel ?? '',
          parcelNature: parcel.colisDetails
              .map((detail) => detail.nature)
              .toSet()
              .join(', '),
          parcelCount: parcel.nombreColis,
          parcelItems: parcel.colisDetails
              .map(
                (detail) => ParcelLine(
                  nature: detail.nature,
                  quantity: detail.nombre,
                  weight: detail.poids,
                  description: detail.description,
                  attachmentPath: detail.imagePath,
                ),
              )
              .toList(),
          attachmentPath: parcel.colisDetails
              .where((detail) => detail.imagePath?.isNotEmpty == true)
              .firstOrNull
              ?.imagePath,
          attachmentName: 'Image du colis',
          deliveryFee: parcel.montant.toStringAsFixed(0),
          showValidation: parcel.statutPaiement == 'payé',
          senderName: parcel.expediteurNom ?? '',
          senderPhone: parcel.expediteurTel ?? '',
          montantBase: parcel.montantBase,
          montantTaxe: parcel.montantTaxe,
          taxeTaux: parcel.tauxTaxe,
          mecefResponse: parcel.mecefResponse,
          poidsTotal: parcel.colisDetails.fold<double>(
            0,
            (total, detail) => total + detail.poids * detail.nombre,
          ),
          description: parcel.colisDetails
              .map((detail) => detail.description)
              .where((value) => value.isNotEmpty)
              .join(', '),
          issuerName: parcel.enregistreurNom ?? '',
          taxGroupLabel: parcel.taxGroupLabel ?? '',
        ),
      ),
    );
  }

  Widget _statusBadge(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: _green.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: _deepGreen,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
