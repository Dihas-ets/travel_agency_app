part of 'pages_colis.dart';

class SendParcelPage extends StatefulWidget {
  final bool showModeTabs;
  final bool isPercepteur;
  final ColisModel? initialParcel;

  const SendParcelPage({
    super.key,
    this.showModeTabs = true,
    this.isPercepteur = false,
    this.initialParcel,
  });

  @override
  State<SendParcelPage> createState() => _SendParcelPageState();
}

class _SendParcelPageState extends State<SendParcelPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _secondaryPhoneController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );
  final ImagePicker _imagePicker = ImagePicker();
  final PaymentService _paymentService = PaymentService();
  final ColisService _colisService = ColisService();

  final List<_ParcelDraft> _parcels = [_ParcelDraft()];
  int _currentStep = 1;
  bool _isSubmitting = false;
  bool _isPaymentProcessing = false;
  bool _isCheckingPayment = false;
  bool _isLoadingProviders = false;
  bool _useMecef = true;
  String _paymentMode = 'ESPECES';
  String? _paymentMessage;
  String? _taxError;
  List<PaymentProvider> _paymentProviders = [];
  List<TaxGroup> _taxGroups = [];
  TaxGroup? _selectedTaxGroup;
  PaymentProvider? _selectedProvider;
  String? _selectedMethod;
  ColisModel? _pendingPaymentParcel;
  Timer? _paymentPollTimer;

  List<Agence> _agences = [];
  List<String> _dynamicNatures = [];
  List<Map<String, dynamic>> _parcelConfigurations = [];
  Agence? _selectedDepartureAgence;
  Agence? _selectedDestinationAgence;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    final user = SessionStore.currentUser;
    _senderNameController.text = user?.fullName ?? '';
    _senderPhoneController.text = user?.numero ?? '';
    _prefillDraft();
    _loadAgences();
    _loadNatures();
    if (widget.isPercepteur) _loadTaxGroups();
    if (widget.isPercepteur) _loadPaymentProviders();
  }

  void _prefillDraft() {
    final parcel = widget.initialParcel;
    if (parcel == null) return;

    _departureController.text = parcel.agenceDepotNom ?? '';
    _destinationController.text = parcel.agenceRetraitNom ?? '';
    _senderNameController.text = parcel.expediteurNom ?? '';
    _senderPhoneController.text = parcel.expediteurTel ?? '';
    _lastNameController.text =
        parcel.destinataireNomFamille ?? parcel.destinataireNom ?? '';
    _firstNameController.text = parcel.destinatairePrenom ?? '';
    _phoneController.text = parcel.destinataireTel ?? '';
    _secondaryPhoneController.text = parcel.destinataireTelSecondaire ?? '';
    _amountController.text = parcel.montant.toStringAsFixed(0);
    _paymentMode = 'ESPECES';
    _montantBase = parcel.montantBase;
    _montantTaxe = parcel.montantTaxe;

    final details = parcel.colisDetails;
    if (details.isNotEmpty) {
      final hasItemValues = details.any((detail) => detail.valeur > 0);
      _parcels.first.dispose();
      _parcels
        ..clear()
        ..addAll(
          details.map((detail) {
            final draft = _ParcelDraft()
              ..nature = detail.nature
              ..quantity = detail.nombre > 0 ? detail.nombre : 1
              ..existingImagePath = detail.imagePath
              ..weightController.text = detail.poids.toString()
              ..descriptionController.text = detail.description
              ..valueController.text =
                  (hasItemValues
                          ? detail.valeur
                          : details.first == detail
                          ? parcel.valeurEstime
                          : 0)
                      .toString();
            return draft;
          }),
        );
    }
  }

  Future<void> _loadTaxGroups() async {
    try {
      final groups = await TaxService().getGroupsForModule('colis');
      if (!mounted) return;
      final selected =
          groups
              .where((group) => group.id == widget.initialParcel?.taxeGroupId)
              .firstOrNull ??
          groups
              .where((group) => group.appliesAsDefaultTo('colis'))
              .firstOrNull ??
          groups.firstOrNull;
      setState(() {
        _taxGroups = groups;
        _selectedTaxGroup = selected;
        _taxError = null;
      });
      _recalculateTaxAmounts();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _taxError =
            'Impossible de charger les groupes de taxe : '
            '${error.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  void _recalculateTaxAmounts() {
    final ttc =
        double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ??
        0;
    final rate = _selectedTaxGroup?.rate ?? 0;
    final base = rate > 0 ? (ttc / (1 + rate / 100)).roundToDouble() : ttc;
    _montantBase = base;
    _montantTaxe = ttc - base;
  }

  double _montantBase = 0;
  double _montantTaxe = 0;

  bool get _hasDefaultTaxGroup =>
      _taxGroups.any((group) => group.appliesAsDefaultTo('colis'));

  Future<void> _loadPaymentProviders() async {
    setState(() => _isLoadingProviders = true);
    try {
      final providers = await _paymentService.getProvidersActifs();
      if (!mounted) return;
      final available = providers
          .where((provider) => provider.configured)
          .toList();
      setState(() {
        _paymentProviders = available;
        _selectedProvider = available.firstOrNull;
        _selectedMethod = _selectedProvider?.methods.keys.firstOrNull;
        _isLoadingProviders = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingProviders = false;
        _paymentMessage =
            'Impossible de charger les moyens Mobile Money : '
            '${error.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  Future<void> _loadNatures() async {
    try {
      final configs = await ColisService().getConfigurations();
      final natures = configs
          .map((c) => c['nature']?.toString())
          .whereType<String>()
          .where((n) => n.trim().isNotEmpty)
          .toSet()
          .toList();
      if (natures.isNotEmpty && mounted) {
        setState(() {
          _dynamicNatures = natures;
          _parcelConfigurations = configs;
        });
      } else if (mounted) {
        setState(() => _parcelConfigurations = configs);
      }
    } catch (_) {}
  }

  void _showTariffs() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tarifs par nature',
                    style: TextStyle(
                      color: _deepBlue,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _parcelConfigurations.isEmpty
                    ? const Center(
                        child: Text('Aucun tarif de colis disponible.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: _parcelConfigurations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final config = _parcelConfigurations[index];
                          final line = config['ligne'] is Map
                              ? Map<String, dynamic>.from(
                                  config['ligne'] as Map,
                                )
                              : const <String, dynamic>{};
                          final route =
                              [
                                    line['trajet_depart']?.toString(),
                                    line['trajet_arrivee']?.toString(),
                                  ]
                                  .where((value) => value?.isNotEmpty == true)
                                  .join(' → ');
                          final description =
                              config['description']?.toString().trim() ?? '';
                          return ListTile(
                            tileColor: const Color(0xFFF8F9FE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            title: Text(
                              config['nature']?.toString() ?? 'Colis',
                              style: const TextStyle(
                                color: _deepBlue,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              [
                                if (description.isNotEmpty) description,
                                route.isEmpty ? 'Toutes les lignes' : route,
                              ].join('\n'),
                            ),
                            trailing: Text(
                              '${config['frais'] ?? 0} FCFA',
                              style: const TextStyle(
                                color: _fofanaGreen,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadAgences() async {
    try {
      final agences = await AgenceService().getAllAgences();
      if (!mounted) return;
      setState(() {
        _agences = agences;
        if (_agences.isNotEmpty) {
          final initialParcel = widget.initialParcel;
          _selectedDepartureAgence =
              _agences
                  .where((agence) => agence.id == initialParcel?.agenceDepotId)
                  .firstOrNull ??
              _agences
                  .where(
                    (agence) => agence.id == SessionStore.currentUser?.agenceId,
                  )
                  .firstOrNull ??
              _agences.first;
          _selectedDestinationAgence = _agences
              .where((agence) => agence.id == initialParcel?.agenceRetraitId)
              .firstOrNull;
          if (_departureController.text.isEmpty) {
            _departureController.text = _selectedDepartureAgence!.nomAgence;
          }
          if (_destinationController.text.isEmpty &&
              _selectedDestinationAgence != null) {
            _destinationController.text = _selectedDestinationAgence!.nomAgence;
          }
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _paymentPollTimer?.cancel();
    _tabController.dispose();
    _departureController.dispose();
    _destinationController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _secondaryPhoneController.dispose();
    _amountController.dispose();
    for (final parcel in _parcels) {
      parcel.dispose();
    }
    super.dispose();
  }

  void _showCityPicker({
    required String title,
    required TextEditingController controller,
    required bool isDeparture,
  }) {
    if (_agences.isNotEmpty) {
      _showAgenceChoiceSheet(
        title: title,
        agences: _agences,
        selectedAgence: isDeparture
            ? _selectedDepartureAgence
            : _selectedDestinationAgence,
        icon: Icons.location_city_rounded,
        onSelected: (agence) {
          setState(() {
            if (isDeparture) {
              _selectedDepartureAgence = agence;
              controller.text = agence.nomAgence;
            } else {
              _selectedDestinationAgence = agence;
              controller.text = agence.nomAgence;
            }
          });
        },
      );
    } else {
      _showChoiceSheet(
        title: title,
        items: _beninCities,
        selectedValue: controller.text,
        icon: Icons.location_city_rounded,
        onSelected: (city) => setState(() => controller.text = city),
      );
    }
  }

  void _showAgenceChoiceSheet({
    required String title,
    required List<Agence> agences,
    required Agence? selectedAgence,
    required IconData icon,
    required ValueChanged<Agence> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            decoration: const BoxDecoration(
              color: _pageBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _deepBlue.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _fofanaGreen.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: _fofanaGreen, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: _deepBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: _deepBlue),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                    itemCount: agences.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final agence = agences[index];
                      final isSelected = agence.id == selectedAgence?.id;

                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            onSelected(agence);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? _fofanaGreen.withValues(alpha: 0.36)
                                    : _deepBlue.withValues(alpha: 0.07),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : icon,
                                  color: _fofanaGreen,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        agence.nomAgence,
                                        style: const TextStyle(
                                          color: _deepBlue,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      if (agence.adresse.isNotEmpty)
                                        Text(
                                          agence.adresse,
                                          style: const TextStyle(
                                            color: Color(0xFF6F7481),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int get _parcelCount =>
      _parcels.fold<int>(0, (sum, parcel) => sum + parcel.quantity);

  XFile? get _firstPickedAttachment {
    for (final parcel in _parcels) {
      if (parcel.attachment != null) return parcel.attachment;
    }
    return null;
  }

  String? get _attachmentNameSummary {
    final names = _parcels
        .map((parcel) => parcel.attachment?.name.trim())
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toList();
    if (names.isEmpty) return null;
    return names.join(', ');
  }

  void _showNaturePicker(int index) {
    _showChoiceSheet(
      title: 'Nature du colis',
      items: _dynamicNatures,
      selectedValue: _parcels[index].nature,
      icon: Icons.inventory_2_outlined,
      onSelected: (nature) => setState(() => _parcels[index].nature = nature),
    );
  }

  void _showChoiceSheet({
    required String title,
    required List<String> items,
    required String? selectedValue,
    required IconData icon,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            decoration: const BoxDecoration(
              color: _pageBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _deepBlue.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _fofanaGreen.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: _fofanaGreen, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: _deepBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: _deepBlue),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 48,
                                  color: _deepBlue.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Aucune nature disponible pour le moment',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _deepBlue,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isSelected = item == selectedValue;

                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  onSelected(item);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? _fofanaGreen.withValues(alpha: 0.36)
                                          : _deepBlue.withValues(alpha: 0.07),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : icon,
                                        color: _fofanaGreen,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            color: _deepBlue,
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addParcelInfo() {
    setState(() {
      if (_parcels.length < 99) {
        _parcels.add(_ParcelDraft());
      }
    });
  }

  void _removeParcelInfo(int index) {
    if (_parcels.length == 1) return;

    setState(() {
      final removed = _parcels.removeAt(index);
      removed.dispose();
    });
  }

  void _increaseParcelQuantity(int index) {
    setState(() {
      final parcel = _parcels[index];
      if (parcel.quantity < 99) {
        parcel.quantity++;
      }
    });
  }

  void _decreaseParcelQuantity(int index) {
    setState(() {
      final parcel = _parcels[index];
      if (parcel.quantity > 1) {
        parcel.quantity--;
      }
    });
  }

  void _goToStepTwo() {
    final hasInvalidParcel = _parcels.any(
      (parcel) =>
          widget.isPercepteur ? !parcel.isCompleteForStaff : !parcel.isComplete,
    );
    if ((!widget.isPercepteur && _departureController.text.trim().isEmpty) ||
        hasInvalidParcel) {
      _showRequiredMessage(
        widget.isPercepteur
            ? 'Renseignez pour chaque colis la nature, la description, le poids et la valeur.'
            : 'Renseignez le point de départ, la nature, la valeur et la photo de chaque colis.',
      );
      return;
    }

    setState(() => _currentStep = 2);
  }

  Future<void> _pickAttachment(int index) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: _fofanaGreen,
              ),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.image_rounded, color: _deepBlue),
              title: const Text('Choisir dans la galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final file = await _imagePicker.pickImage(source: source);
    if (file == null) return;

    setState(() => _parcels[index].attachment = file);
  }

  Future<void> _previewTicket() async {
    if (widget.isPercepteur && _pendingPaymentParcel != null) {
      await _startParcelPayment(_pendingPaymentParcel!);
      return;
    }

    if (_destinationController.text.trim().isEmpty ||
        (widget.isPercepteur && _senderNameController.text.trim().isEmpty) ||
        (widget.isPercepteur && _senderPhoneController.text.trim().isEmpty) ||
        _lastNameController.text.trim().isEmpty ||
        (widget.initialParcel == null &&
            _firstNameController.text.trim().isEmpty) ||
        _phoneController.text.trim().isEmpty ||
        (!widget.isPercepteur && _departureController.text.trim().isEmpty) ||
        _parcels.any(
          (parcel) => widget.isPercepteur
              ? !parcel.isCompleteForStaff
              : !parcel.isComplete,
        )) {
      _showRequiredMessage(
        "Remplissez tous les champs de chaque colis avant la validation",
      );
      return;
    }
    if (widget.isPercepteur) {
      final amount =
          double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ??
          0;
      if (amount <= 0) {
        _showRequiredMessage('Le montant TTC doit être supérieur à 0.');
        return;
      }
      if (_taxGroups.isNotEmpty && _selectedTaxGroup == null) {
        _showRequiredMessage('Sélectionnez le groupe de taxe du colis.');
        return;
      }
      if (_taxError != null) {
        _showRequiredMessage(_taxError!);
        return;
      }
    }
    if (widget.isPercepteur &&
        _paymentMode == 'MOBILEMONEY' &&
        (_isLoadingProviders ||
            _selectedProvider == null ||
            _selectedMethod == null)) {
      _showRequiredMessage(
        _isLoadingProviders
            ? 'Chargement des moyens de paiement. Réessayez dans un instant.'
            : 'Choisissez un moyen Mobile Money disponible.',
      );
      return;
    }

    // Resolve departure and destination agency IDs
    int? depotId = widget.isPercepteur
        ? null
        : _selectedDepartureAgence?.id ?? 1;
    int retraitId = _selectedDestinationAgence?.id ?? 2;

    if (!widget.isPercepteur &&
        _selectedDepartureAgence == null &&
        _agences.isNotEmpty) {
      final found = _agences.firstWhere(
        (a) =>
            a.nomAgence.toLowerCase() ==
            _departureController.text.trim().toLowerCase(),
        orElse: () => _agences.first,
      );
      depotId = found.id;
    }

    Future<void> updateAndFinalizeDraft() async {
      final parcel = widget.initialParcel!;
      final amount =
          double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ??
          0;
      if (amount <= 0) {
        _showRequiredMessage('Le montant TTC doit être supérieur à 0.');
        return;
      }
      if (_paymentMode == 'ESPECES') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Confirmer le paiement'),
            content: Text(
              'Confirmez l’encaissement de ${amount.toStringAsFixed(0)} FCFA '
              'pour le colis ${parcel.reference}.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Retour'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Confirmer'),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
      }

      setState(() => _isSubmitting = true);
      try {
        final details = _parcels
            .map(
              (draft) => {
                'nature': draft.nature ?? 'Colis',
                'poids':
                    double.tryParse(
                      draft.weightController.text.trim().replaceAll(',', '.'),
                    ) ??
                    0,
                'nombre': draft.quantity,
                'description': draft.descriptionController.text.trim(),
                if (draft.existingImagePath != null)
                  'image_path': draft.existingImagePath,
              },
            )
            .toList();
        final estimatedValue = _parcels.fold<double>(
          0,
          (total, draft) =>
              total +
              (double.tryParse(
                    draft.valueController.text.trim().replaceAll(',', '.'),
                  ) ??
                  0),
        );
        final updated = await _colisService.updateColisStaff(
          reference: parcel.reference,
          agenceRetraitId:
              _selectedDestinationAgence?.id ?? parcel.agenceRetraitId ?? 0,
          expediteurNom: _senderNameController.text.trim(),
          expediteurTel: _senderPhoneController.text.trim(),
          destinataireNom:
              '${_lastNameController.text.trim()} '
                      '${_firstNameController.text.trim()}'
                  .trim(),
          destinataireTel: _phoneController.text.trim(),
          destinataireTelSecondaire: _secondaryPhoneController.text.trim(),
          modePaiement: _paymentMode,
          valeurEstime: estimatedValue,
          montant: amount,
          montantBase: _montantBase,
          montantTaxe: _montantTaxe,
          useMecef: _useMecef,
          taxeGroupId: _selectedTaxGroup?.id ?? parcel.taxeGroupId,
          taxeTaux: _selectedTaxGroup?.rate ?? parcel.tauxTaxe,
          colisDetails: details,
          images: _parcels.map((draft) => draft.attachment).toList(),
        );

        if (!mounted) return;
        if (_paymentMode == 'MOBILEMONEY') {
          setState(() {
            _isSubmitting = false;
            _pendingPaymentParcel = updated;
          });
          await _startParcelPayment(updated);
          return;
        }

        await _colisService.validerColisStaff(
          id: parcel.id,
          modePaiement: 'ESPECES',
          montant: amount,
        );
        final finalizedParcels = await _colisService.getColisStaff();
        final finalized = finalizedParcels
            .where((item) => item.id == parcel.id)
            .firstOrNull;
        if (finalized == null) {
          throw Exception(
            'Le colis finalisé est introuvable après sa mise à jour.',
          );
        }
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        await _showParcelTicket(finalized);
      } catch (error) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        _showRequiredMessage(
          'Impossible de finaliser le colis : '
          '${error.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }

    if (widget.initialParcel != null) {
      await updateAndFinalizeDraft();
      return;
    }

    if (_selectedDestinationAgence == null && _agences.isNotEmpty) {
      final found = _agences.firstWhere(
        (a) =>
            a.nomAgence.toLowerCase() ==
            _destinationController.text.trim().toLowerCase(),
        orElse: () => _agences.length > 1 ? _agences[1] : _agences.first,
      );
      retraitId = found.id;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = SessionStore.currentUser;
      final senderPhone = widget.isPercepteur
          ? _senderPhoneController.text.trim()
          : (user?.numero != null && user!.numero.isNotEmpty)
          ? user.numero
          : (SessionStore.currentClientPhone ?? '+22900000000');
      final senderName = widget.isPercepteur
          ? _senderNameController.text.trim()
          : (user != null && user.fullName.isNotEmpty)
          ? user.fullName
          : (SessionStore.currentClientFullName ?? 'Client');

      final List<Map<String, dynamic>> details = _parcels
          .map(
            (p) => {
              'nature': p.nature ?? 'Colis',
              'poids': widget.isPercepteur
                  ? double.tryParse(
                          p.weightController.text.trim().replaceAll(',', '.'),
                        ) ??
                        0
                  : 0,
              'nombre': p.quantity,
              'description': widget.isPercepteur
                  ? p.descriptionController.text.trim()
                  : 'Valeur: ${p.valueController.text.trim()} FCFA',
            },
          )
          .toList();

      final List<XFile?> images = _parcels.map((p) => p.attachment).toList();

      final double totalValeur = _parcels.fold<double>(
        0,
        (sum, p) => sum + (double.tryParse(p.valueController.text.trim()) ?? 0),
      );

      final result = await ColisService().createColis(
        agenceDepotId: depotId,
        agenceRetraitId: retraitId,
        expediteurNom: senderName,
        expediteurTel: senderPhone,
        destinataireNom:
            '${_lastNameController.text.trim()} ${_firstNameController.text.trim()}'
                .trim(),
        destinataireTel: _phoneController.text.trim(),
        modePaiement: widget.isPercepteur ? _paymentMode : 'ESPECES',
        useMecef: _useMecef,
        valeurEstime: totalValeur,
        colisDetails: details,
        montantManuel: widget.isPercepteur
            ? double.tryParse(
                _amountController.text.trim().replaceAll(',', '.'),
              )
            : null,
        montantBase: widget.isPercepteur ? _montantBase : null,
        montantTaxe: widget.isPercepteur ? _montantTaxe : null,
        taxeGroupId: widget.isPercepteur ? _selectedTaxGroup?.id : null,
        taxeTaux: widget.isPercepteur ? _selectedTaxGroup?.rate : null,
        destinataireTelSecondaire: _secondaryPhoneController.text,
        images: images,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (result['success'] == true) {
        final ColisModel colis = result['colis'];
        if (widget.isPercepteur && _paymentMode == 'MOBILEMONEY') {
          setState(() => _pendingPaymentParcel = colis);
          await _startParcelPayment(colis);
          return;
        }
        if (widget.isPercepteur && colis.statutPaiement != 'payé') {
          _showRequiredMessage(
            'Le paiement du colis n’a pas été confirmé. '
            'Le colis reste en attente et ne peut pas être finalisé.',
          );
          return;
        }
        final parcelRecord = colis.toParcelRecord();
        ParcelStore.upsertPending(parcelRecord);

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BilletPage(
              showPrintButton: widget.isPercepteur,
              onReturnToHome: widget.isPercepteur
                  ? () => Navigator.of(
                      context,
                      rootNavigator: true,
                    ).popUntil((route) => route.isFirst)
                  : null,
              code: colis.reference,
              departureCity:
                  colis.agenceDepotNom ?? _departureController.text.trim(),
              destinationCity:
                  colis.agenceRetraitNom ?? _destinationController.text.trim(),
              recipientLastName: _lastNameController.text.trim(),
              recipientFirstName: _firstNameController.text.trim(),
              recipientPhone: _phoneController.text.trim(),
              parcelNature: _parcels
                  .map((parcel) => parcel.nature)
                  .whereType<String>()
                  .toSet()
                  .join(', '),
              parcelCount: _parcelCount,
              parcelItems: parcelRecord.parcelItems,
              attachmentPath: _firstPickedAttachment?.path,
              attachmentName: _attachmentNameSummary,
              deliveryFee: colis.montant > 0
                  ? colis.montant.toStringAsFixed(0)
                  : '',
              showValidation: widget.isPercepteur,
              senderName: senderName,
              senderPhone: senderPhone,
              montantBase: colis.montantBase,
              montantTaxe: colis.montantTaxe,
              taxeTaux: colis.tauxTaxe,
              mecefResponse: colis.mecefResponse,
              poidsTotal: colis.colisDetails.fold<double>(
                0,
                (total, detail) => total + detail.poids * detail.nombre,
              ),
              description: colis.colisDetails
                  .map((detail) => detail.description)
                  .where((value) => value.isNotEmpty)
                  .join(', '),
              issuerName: colis.enregistreurNom ?? '',
              taxGroupLabel: colis.taxGroupLabel ?? '',
            ),
          ),
        );
        if (widget.isPercepteur && mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        _showRequiredMessage(
          result['message'] ?? 'Échec de la création du colis.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showRequiredMessage(
        'Erreur : ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  Future<void> _startParcelPayment(ColisModel parcel) async {
    final provider = _selectedProvider;
    final method = _selectedMethod;
    if (provider == null || method == null) {
      _showRequiredMessage('Choisissez un moyen Mobile Money disponible.');
      return;
    }
    if (_isPaymentProcessing) return;

    setState(() {
      _isPaymentProcessing = true;
      _paymentMessage = null;
    });
    try {
      final result = await _paymentService.initierPaiement(
        payableRef: parcel.reference,
        payableType: 'colis',
        provider: provider.slug,
        method: method,
        clientEmail: SessionStore.currentUser?.email,
      );
      if (!mounted) return;
      final transaction = result['transaction'] as Map<String, dynamic>?;
      final reference = transaction?['reference']?.toString();
      if (reference == null || reference.isEmpty) {
        throw Exception('La référence de transaction est absente.');
      }

      final activeProvider = result['provider']?.toString() ?? provider.slug;
      if (activeProvider == 'feexpay') {
        await FeexPayService.openPayment(
          context: context,
          amount:
              num.tryParse(result['amount']?.toString() ?? '') ??
              parcel.montant,
          token: result['token']?.toString() ?? '',
          shopId:
              result['shop_id']?.toString() ??
              result['public_key']?.toString() ??
              '',
          reference: reference,
          onResult: (paymentResult) async {
            if (paymentResult.isSuccess) {
              _pollParcelPayment(
                reference,
                parcel,
                externalId: paymentResult.reference,
              );
            } else if (mounted) {
              setState(() => _isPaymentProcessing = false);
              _showRequiredMessage(
                paymentResult.message ?? 'Le paiement n’a pas été confirmé.',
              );
            }
          },
        );
        return;
      }
      if (activeProvider == 'kkiapay') {
        final customer = result['customer'] as Map<String, dynamic>?;
        final externalId = await KkiapayService.openPayment(
          context: context,
          amount:
              int.tryParse(result['amount']?.toString() ?? '') ??
              parcel.montant.round(),
          publicKey: result['public_key']?.toString() ?? '',
          sandbox: result['environment']?.toString() != 'live',
          reference: reference,
          phone: customer?['phone']?.toString() ?? _phoneController.text.trim(),
          name:
              '${_lastNameController.text.trim()} '
                      '${_firstNameController.text.trim()}'
                  .trim(),
          email: customer?['email']?.toString(),
        );
        if (externalId == null || externalId.isEmpty) {
          if (mounted) setState(() => _isPaymentProcessing = false);
          return;
        }
        _pollParcelPayment(reference, parcel, externalId: externalId);
        return;
      }

      final paymentUrl = result['payment_url']?.toString();
      if (paymentUrl == null || paymentUrl.isEmpty) {
        throw Exception('Le prestataire n’a pas fourni de page de paiement.');
      }
      final opened = await launchUrl(
        Uri.parse(paymentUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) throw Exception('Impossible d’ouvrir la page de paiement.');
      _pollParcelPayment(reference, parcel);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isPaymentProcessing = false;
        _paymentMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _pollParcelPayment(
    String reference,
    ColisModel parcel, {
    String? externalId,
  }) {
    _paymentPollTimer?.cancel();
    var attempts = 0;
    var currentExternalId = externalId;
    _paymentPollTimer = Timer.periodic(const Duration(seconds: 4), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isCheckingPayment) return;
      if (++attempts > 45) {
        timer.cancel();
        setState(() {
          _isPaymentProcessing = false;
          _paymentMessage =
              'Délai dépassé. Le colis reste en attente de paiement. '
              'Réessayez depuis cet écran.';
        });
        return;
      }
      _isCheckingPayment = true;
      try {
        final result = await _paymentService.verifierPaiement(
          reference: reference,
          payableType: 'colis',
          externalId: currentExternalId,
        );
        currentExternalId = null;
        if (result['verified'] == true) {
          timer.cancel();
          final updatedParcels = await ColisService().getColisStaff();
          final updated = updatedParcels
              .where((item) => item.id == parcel.id)
              .firstOrNull;
          if (updated == null || updated.statutPaiement != 'payé') {
            throw Exception(
              'Le paiement est confirmé, mais le colis payé est introuvable '
              'dans la réponse du serveur.',
            );
          }
          if (mounted) {
            setState(() {
              _isPaymentProcessing = false;
              _pendingPaymentParcel = null;
            });
          }
          await _showParcelTicket(updated);
        }
      } catch (error) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isPaymentProcessing = false;
            _paymentMessage =
                'La vérification du paiement a échoué : '
                '${error.toString().replaceFirst('Exception: ', '')}';
          });
        }
      } finally {
        _isCheckingPayment = false;
      }
    });
  }

  Future<void> _showParcelTicket(ColisModel colis) async {
    ParcelStore.upsertPending(colis.toParcelRecord());
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BilletPage(
          showPrintButton: widget.isPercepteur,
          onReturnToHome: widget.isPercepteur
              ? () => Navigator.of(
                  context,
                  rootNavigator: true,
                ).popUntil((route) => route.isFirst)
              : null,
          code: colis.reference,
          departureCity:
              colis.agenceDepotNom ?? _departureController.text.trim(),
          destinationCity:
              colis.agenceRetraitNom ?? _destinationController.text.trim(),
          recipientLastName: _lastNameController.text.trim(),
          recipientFirstName: _firstNameController.text.trim(),
          recipientPhone: _phoneController.text.trim(),
          parcelNature: colis.colisDetails
              .map((detail) => detail.nature)
              .toSet()
              .join(', '),
          parcelCount: _parcelCount,
          parcelItems: colis.toParcelRecord().parcelItems,
          attachmentPath: _firstPickedAttachment?.path,
          attachmentName: _attachmentNameSummary,
          deliveryFee: colis.montant.toStringAsFixed(0),
          showValidation: true,
          senderName: colis.expediteurNom ?? '',
          senderPhone: colis.expediteurTel ?? '',
          montantBase: colis.montantBase,
          montantTaxe: colis.montantTaxe,
          taxeTaux: colis.tauxTaxe,
          mecefResponse: colis.mecefResponse,
          poidsTotal: colis.colisDetails.fold<double>(
            0,
            (total, detail) => total + detail.poids * detail.nombre,
          ),
          description: colis.colisDetails
              .map((detail) => detail.description)
              .where((value) => value.isNotEmpty)
              .join(', '),
          issuerName: colis.enregistreurNom ?? '',
          taxGroupLabel: colis.taxGroupLabel ?? '',
        ),
      ),
    );
    if (widget.isPercepteur && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _showRequiredMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: _logoRed));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: _ParcelHeader(
                showStepBack:
                    _currentStep == 2 &&
                    (!widget.showModeTabs || _tabController.index == 0),
                onMenuTap: () => Navigator.pop(context),
                onStepBack: () => setState(() => _currentStep = 1),
              ),
            ),
            Expanded(
              child: widget.showModeTabs
                  ? TabBarView(
                      controller: _tabController,
                      children: [_buildEmbarquementTab(bottomInset)],
                    )
                  : _buildEmbarquementTab(bottomInset),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmbarquementTab(double bottomInset) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24, 30, 24, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: _currentStep == 1 ? 0 : 4),
          _StepDivider(label: 'Étape $_currentStep/2'),
          const SizedBox(height: 12),
          _StepProgressBadges(
            currentStep: _currentStep,
            parcelCardsCount: _parcels.length,
            totalParcelCount: _parcelCount,
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _currentStep == 1
                ? _StepOneForm(
                    key: const ValueKey('parcel-step-one'),
                    departureController: _departureController,
                    parcels: _parcels,
                    onDepartureTap: () => _showCityPicker(
                      title: 'Agence / Point de départ',
                      controller: _departureController,
                      isDeparture: true,
                    ),
                    onNatureTap: _showNaturePicker,
                    onAddParcel: _addParcelInfo,
                    onRemoveParcel: _removeParcelInfo,
                    onIncreaseQuantity: _increaseParcelQuantity,
                    onDecreaseQuantity: _decreaseParcelQuantity,
                    onPickAttachment: _pickAttachment,
                    onNext: _goToStepTwo,
                    onInitiations: () => _showInitiationsMessage(context),
                    showDepartureField: !widget.isPercepteur,
                    showStaffFields: widget.isPercepteur,
                    onShowTariffs: widget.isPercepteur ? _showTariffs : null,
                  )
                : _StepTwoForm(
                    key: const ValueKey('parcel-step-two'),
                    destinationController: _destinationController,
                    senderNameController: _senderNameController,
                    senderPhoneController: _senderPhoneController,
                    lastNameController: _lastNameController,
                    firstNameController: _firstNameController,
                    phoneController: _phoneController,
                    secondaryPhoneController: _secondaryPhoneController,
                    showStaffFields: widget.isPercepteur,
                    isSubmitting: _isSubmitting || _isPaymentProcessing,
                    paymentOptions: widget.isPercepteur
                        ? _buildPaymentOptions()
                        : null,
                    taxOptions: widget.isPercepteur
                        ? _buildTaxAndAmountOptions()
                        : null,
                    mecefOption: widget.isPercepteur
                        ? _buildMecefOption()
                        : null,
                    previewLabel: widget.initialParcel == null
                        ? 'Créer & Aperçu'
                        : 'Mettre à jour et finaliser',
                    onDestinationTap: () => _showCityPicker(
                      title: 'Agence de destination',
                      controller: _destinationController,
                      isDeparture: false,
                    ),
                    onPreview: _previewTicket,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMecefOption() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _fofanaGreen.withValues(alpha: 0.12)),
      ),
      child: SwitchListTile.adaptive(
        value: _useMecef,
        title: Text(
          _useMecef ? 'Enregistrer avec MECeF' : 'Enregistrer sans MECeF',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          _useMecef
              ? 'Le colis sera certifié après son paiement.'
              : 'Le QR code du colis utilisera sa référence.',
        ),
        onChanged: (value) => setState(() => _useMecef = value),
        activeTrackColor: _fofanaGreen,
      ),
    );
  }

  Widget _buildTaxAndAmountOptions() {
    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ??
        0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Groupe de taxe et montant',
            style: TextStyle(color: _deepBlue, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (_taxError != null)
            Text(_taxError!, style: const TextStyle(color: Colors.red))
          else if (_taxGroups.isNotEmpty && !_hasDefaultTaxGroup)
            DropdownButtonFormField<TaxGroup>(
              initialValue: _selectedTaxGroup,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Groupe de taxe',
                border: OutlineInputBorder(),
              ),
              items: _taxGroups
                  .map(
                    (group) => DropdownMenuItem<TaxGroup>(
                      value: group,
                      child: Text(
                        '${group.label} (${group.rate} %)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _pendingPaymentParcel != null
                  ? null
                  : (group) => setState(() {
                      _selectedTaxGroup = group;
                      _recalculateTaxAmounts();
                    }),
            )
          else if (_selectedTaxGroup != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Groupe de taxe par défaut : '
                '${_selectedTaxGroup!.label} (${_selectedTaxGroup!.rate} %)',
                style: const TextStyle(
                  color: _deepBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const Text('Aucun groupe de taxe configuré pour les colis.'),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            enabled: _pendingPaymentParcel == null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            onChanged: (_) => setState(_recalculateTaxAmounts),
            decoration: const InputDecoration(
              labelText: 'Montant TTC à encaisser',
              suffixText: 'FCFA',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          _financialDetail(
            'Montant HT',
            '${_montantBase.toStringAsFixed(0)} FCFA',
          ),
          _financialDetail(
            'Taxe (${_selectedTaxGroup?.rate.toStringAsFixed(2) ?? '0'} %)',
            '${_montantTaxe.toStringAsFixed(0)} FCFA',
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Total TTC : ${amount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                color: _deepBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _financialDetail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF5F6B86))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );

  Widget _buildPaymentOptions() {
    final selectedProvider = _selectedProvider;
    final selectedMethod = _selectedMethod;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mode de paiement',
            style: TextStyle(color: _deepBlue, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _paymentModeCard(
                  mode: 'ESPECES',
                  label: 'Espèces',
                  icon: Icons.payments_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _paymentModeCard(
                  mode: 'MOBILEMONEY',
                  label: 'Mobile Money',
                  icon: Icons.phone_android_rounded,
                ),
              ),
            ],
          ),
          if (_paymentMode == 'MOBILEMONEY') ...[
            const SizedBox(height: 12),
            if (_isLoadingProviders)
              const Center(child: CircularProgressIndicator())
            else if (_paymentProviders.isEmpty)
              const Text(
                'Aucun prestataire Mobile Money n’est configuré. '
                'Choisissez Espèces ou contactez l’administrateur.',
                style: TextStyle(color: Colors.red),
              )
            else ...[
              DropdownButtonFormField<PaymentProvider>(
                initialValue: selectedProvider,
                decoration: const InputDecoration(labelText: 'Prestataire'),
                items: _paymentProviders
                    .map(
                      (provider) => DropdownMenuItem(
                        value: provider,
                        child: Text(provider.name),
                      ),
                    )
                    .toList(),
                onChanged: _pendingPaymentParcel != null
                    ? null
                    : (provider) => setState(() {
                        _selectedProvider = provider;
                        _selectedMethod = provider?.methods.keys.firstOrNull;
                      }),
              ),
              if (selectedProvider != null &&
                  selectedProvider.methods.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: selectedMethod,
                  decoration: const InputDecoration(labelText: 'Opérateur'),
                  items: selectedProvider.methods.entries
                      .map(
                        (method) => DropdownMenuItem(
                          value: method.key,
                          child: Text(method.value),
                        ),
                      )
                      .toList(),
                  onChanged: _pendingPaymentParcel != null
                      ? null
                      : (method) => setState(() => _selectedMethod = method),
                ),
            ],
            if (_paymentMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _paymentMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _paymentModeCard({
    required String mode,
    required String label,
    required IconData icon,
  }) {
    final selected = _paymentMode == mode;
    final enabled = _pendingPaymentParcel == null && !_isPaymentProcessing;
    return InkWell(
      onTap: !enabled
          ? null
          : () => setState(() {
              _paymentMode = mode;
              _paymentMessage = null;
            }),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _fofanaGreen : const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _fofanaGreen : _deepBlue.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : _deepBlue),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : _deepBlue,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInitiationsMessage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ColisAttentePage(
          initialTabIndex: 1,
          filterClientParcels: true,
        ),
      ),
    );
  }
}
