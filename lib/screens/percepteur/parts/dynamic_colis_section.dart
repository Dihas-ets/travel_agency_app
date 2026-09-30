import 'package:flutter/material.dart';
import 'package:code_initial/models/colis_model.dart';
import 'package:code_initial/screens/client/colis/pages_colis.dart';
import 'package:code_initial/services/colis_service.dart';

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
  int _selectedTab = 0;
  int? _processingParcelId;

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

  List<ColisModel> get _visibleParcels {
    const activeStatuses = {'brouillon', 'a_expedier', 'en_transit'};
    final query = _searchQuery.trim().toLowerCase();

    return _parcels.where((parcel) {
      final isActive = activeStatuses.contains(parcel.statut);
      if ((_selectedTab == 0) != isActive) return false;
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

  Future<void> _validateParcel(ColisModel parcel) async {
    final amountController = TextEditingController(
      text: parcel.montant.toStringAsFixed(0),
    );
    final formKey = GlobalKey<FormState>();
    var mode = parcel.modePaiement == 'MOBILEMONEY' ? 'MOBILEMONEY' : 'ESPECES';

    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Confirmer le colis'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Colis ${parcel.reference}'),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: mode,
                  decoration: const InputDecoration(
                    labelText: 'Mode de paiement',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ESPECES', child: Text('Espèces')),
                    DropdownMenuItem(
                      value: 'MOBILEMONEY',
                      child: Text('Mobile Money'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => mode = value);
                  },
                ),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Montant encaissé',
                    suffixText: 'FCFA',
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    if (amount == null || amount < 0) {
                      return 'Saisissez un montant valide.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'La validation confirme le paiement et lance la certification MECeF selon le backend.',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(dialogContext, {
                  'mode_paiement': mode,
                  'montant': double.parse(amountController.text.trim()),
                });
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
    amountController.dispose();
    if (values == null || !mounted) return;

    await _runParcelAction(
      parcel,
      () => _colisService.validerColisStaff(
        id: parcel.id,
        modePaiement: values['mode_paiement'] as String,
        montant: values['montant'] as double,
      ),
      'Paiement confirmé et colis enregistré.',
    );
  }

  Future<void> _loadParcel(ColisModel parcel) async {
    await _runParcelAction(
      parcel,
      () => _colisService.chargerColisStaff(parcel.id),
      'Colis chargé et passé en transit.',
    );
  }

  Future<void> _runParcelAction(
    ColisModel parcel,
    Future<void> Function() action,
    String successMessage,
  ) async {
    setState(() => _processingParcelId = parcel.id);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: _green),
      );
      await _loadParcels();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de l’action : $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _processingParcelId = null);
    }
  }

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
                ...parcel.colisDetails.map(
                  (detail) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text('${detail.nature} · ${detail.nombre}'),
                    subtitle: Text(
                      detail.description.isEmpty
                          ? 'Aucune description'
                          : detail.description,
                    ),
                  ),
                ),
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

  String _statusLabel(String status) => switch (status) {
    'brouillon' => 'En attente de paiement',
    'a_expedier' => 'À expédier',
    'en_transit' => 'En transit',
    'arrive' => 'Arrivé',
    'livre' => 'Livré',
    'litige' => 'En litige',
    'annule' => 'Annulé',
    _ => status,
  };

  String _paymentLabel(String status) => switch (status) {
    'payé' => 'Payé',
    'en_attente_paiement' => 'En attente',
    _ => status,
  };

  Future<void> _openCreateForm() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SendParcelPage(showModeTabs: false),
    );
    if (mounted) await _loadParcels();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _parcels
        .where(
          (parcel) => const {
            'brouillon',
            'a_expedier',
            'en_transit',
          }.contains(parcel.statut),
        )
        .length;
    final transitCount = _parcels
        .where((parcel) => parcel.statut == 'en_transit')
        .length;

    return Column(
      children: [
        _buildTabs(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'À traiter',
                activeCount.toString(),
                Icons.pending_actions_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                'En transit',
                transitCount.toString(),
                Icons.local_shipping_rounded,
              ),
            ),
            IconButton(
              tooltip: 'Actualiser',
              onPressed: _isLoading ? null : _loadParcels,
              icon: const Icon(Icons.refresh_rounded),
            ),
            IconButton(
              tooltip: 'Enregistrer un colis',
              onPressed: _openCreateForm,
              icon: const Icon(Icons.add_circle_rounded, color: _green),
            ),
          ],
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
    child: Row(
      children: [_tabButton('À traiter', 0), _tabButton('Historique', 1)],
    ),
  );

  Widget _tabButton(String label, int index) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: _selectedTab == index ? _green : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _selectedTab == index ? Colors.white : _deepGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );

  Widget _summaryCard(String label, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _deepGreen.withValues(alpha: 0.08)),
    ),
    child: Row(
      children: [
        Icon(icon, color: _green, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
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
      return Center(
        child: Text(
          _selectedTab == 0
              ? 'Aucun colis à traiter.'
              : 'Aucun colis dans l’historique.',
          style: const TextStyle(color: _muted, fontWeight: FontWeight.w700),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 86),
      itemCount: parcels.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _parcelCard(parcels[index]),
    );
  }

  Widget _parcelCard(ColisModel parcel) {
    final isProcessing = _processingParcelId == parcel.id;
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
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _showDetails(parcel),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Détails'),
              ),
              const Spacer(),
              if (parcel.statut == 'brouillon')
                FilledButton.icon(
                  onPressed: isProcessing
                      ? null
                      : () => _validateParcel(parcel),
                  icon: isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('Confirmer paiement'),
                )
              else if (parcel.statut == 'a_expedier')
                FilledButton.icon(
                  onPressed: isProcessing ? null : () => _loadParcel(parcel),
                  icon: isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.local_shipping_outlined, size: 18),
                  label: const Text('Charger'),
                ),
            ],
          ),
        ],
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
