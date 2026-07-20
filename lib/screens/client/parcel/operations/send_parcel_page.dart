part of 'parcel_pages.dart';

class SendParcelPage extends StatefulWidget {
  final bool showModeTabs;

  const SendParcelPage({super.key, this.showModeTabs = true});

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
  final ImagePicker _imagePicker = ImagePicker();

  final List<_ParcelDraft> _parcels = [_ParcelDraft()];
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _departureController.dispose();
    _destinationController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    for (final parcel in _parcels) {
      parcel.dispose();
    }
    super.dispose();
  }

  void _showCityPicker({
    required String title,
    required TextEditingController controller,
  }) {
    _showChoiceSheet(
      title: title,
      items: _beninCities,
      selectedValue: controller.text,
      icon: Icons.location_city_rounded,
      onSelected: (city) => setState(() => controller.text = city),
    );
  }

  int get _parcelCount =>
      _parcels.fold<int>(0, (sum, parcel) => sum + parcel.quantity);

  String get _parcelNatureSummary => _parcels
      .where((parcel) => parcel.nature != null)
      .map((parcel) => parcel.summary.trim())
      .where((summary) => summary.isNotEmpty)
      .join(', ');

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
      items: _parcelNatures,
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
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
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
    if (_departureController.text.trim().isEmpty ||
        _parcels.any((parcel) => !parcel.isComplete)) {
      _showRequiredMessage(
        "Remplissez la nature, la valeur et l'image de chaque colis avant de continuer",
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

  void _previewTicket() {
    if (_destinationController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _firstNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _departureController.text.trim().isEmpty ||
        _parcels.any((parcel) => !parcel.isComplete)) {
      _showRequiredMessage(
        "Remplissez tous les champs de chaque colis avant l'aperçu",
      );
      return;
    }

    final now = DateTime.now();
    final millis = now.millisecondsSinceEpoch;
    final randomSuffix = (millis % 100000).toString().padLeft(5, '0');

    // Reference colis lisible pour l'utilisateur et unique pour le test local.
    // Le prefixe Fofana garde la marque coherente sur le billet, le QR code
    // et la liste des envois.
    final datePrefix =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final code = 'Fofana-$datePrefix-$randomSuffix';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BilletPage(
          code: code,
          departureCity: _departureController.text.trim(),
          destinationCity: _destinationController.text.trim(),
          recipientLastName: _lastNameController.text.trim(),
          recipientFirstName: _firstNameController.text.trim(),
          recipientPhone: _phoneController.text.trim(),
          parcelNature: _parcelNatureSummary,
          parcelCount: _parcelCount,
          attachmentPath: _firstPickedAttachment?.path,
          attachmentName: _attachmentNameSummary,
          deliveryFee: '',
          showValidation: false,
        ),
      ),
    );
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
                      title: 'Point de départ',
                      controller: _departureController,
                    ),
                    onNatureTap: _showNaturePicker,
                    onAddParcel: _addParcelInfo,
                    onRemoveParcel: _removeParcelInfo,
                    onIncreaseQuantity: _increaseParcelQuantity,
                    onDecreaseQuantity: _decreaseParcelQuantity,
                    onPickAttachment: _pickAttachment,
                    onNext: _goToStepTwo,
                    onInitiations: () => _showInitiationsMessage(context),
                  )
                : _StepTwoForm(
                    key: const ValueKey('parcel-step-two'),
                    destinationController: _destinationController,
                    lastNameController: _lastNameController,
                    firstNameController: _firstNameController,
                    phoneController: _phoneController,
                    onDestinationTap: () => _showCityPicker(
                      title: 'Ville de destination',
                      controller: _destinationController,
                    ),
                    onPreview: _previewTicket,
                  ),
          ),
        ],
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
