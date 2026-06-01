import 'dart:io';

import 'package:flutter/material.dart';
import 'package:code_initial/presentation/pages/parcel/billet_page.dart';
import 'package:code_initial/presentation/pages/parcel/colis_attente_page.dart';
import 'package:code_initial/widgets/common/african_phone_field.dart';
import 'package:image_picker/image_picker.dart';

const Color _deepBlue = Color(0xFF0B4F2A);
const Color _logoRed = Color(0xFFE53935);
const Color _pageBackground = Color(0xFFF8F9FE);

const List<String> _beninCities = [
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
  'Bopa',
  'Cotonou',
  'Comè',
  'Covè',
  'Dassa-Zoumè',
  'Djougou',
  'Dogbo',
  'Glazoué',
  'Grand-Popo',
  'Kandi',
  'Kétou',
  'Kouandé',
  'Lokossa',
  'Malanville',
  'Natitingou',
  'Nikki',
  "N'Dali",
  'Ouidah',
  'Parakou',
  'Pobè',
  'Porto-Novo',
  'Sakété',
  'Savè',
  'Savalou',
  'Sèmè-Kpodji',
  'Tanguiéta',
  'Tchaourou',
];

const List<String> _parcelNatures = [
  'Alluminum',
  'Appareil électronique',
  'Armoire',
  'Bac',
  'Bache',
  'Bafana',
  'Balle de friperie',
  'Banc',
  'Batterie',
  'Bidon',
  'Boîte',
  'Bouteille',
  'Brouette',
  'Cable',
  'Caisse',
  'Caisse de poisson',
  'Canapé',
  'Cartable',
  'Carton',
  'Carton carreau',
  'Carton lait',
  'Carton moyen',
  'Carton ram',
  'Carton sucre',
  'Carton toner',
  'Casier',
  'Casier de bière',
  'Casier de jus',
  'Casier 2 jus',
  'Casier 3 jus',
  'Casier 4 jus',
  'Casier 5 jus',
  'Casier 6 jus',
  "Casier d'eau",
  'Chaise',
  'Chaussures',
  'Clé',
  'Climatiseur',
  'Colis',
  "Colis d'eau",
  'Colis jus',
  'Colis valise',
  'Complement douane',
  'Cop',
  'Couverture',
  'Cuisiniere',
  'Décoder',
  'Document',
  'Écran',
  'Enveloppe',
  'Fauteuil',
  'Fer',
  'Fil',
  'Four',
  'Frigo',
  'Frigo grand carton',
  'Imprimante',
  'Machine',
  'Machine à laver',
  'Malle',
  'Matelas',
  'Meuble',
  'Micro-onde',
  'Moto',
  'Ordinateur',
  'Pagne',
  'Panneau',
  'Pièce détachée',
  'Pièce moto',
  'Plastique',
  'Pneu',
  'Réchaud',
  'Sac',
  'Sac de ciment',
  'Sac de maïs',
  'Sac de riz',
  'Sac de voyage',
  'Sacoche',
  "Sachet d'eau",
  'Seau',
  'Tablette',
  'Table',
  'Téléphone',
  'Téléviseur',
  'Tonneau',
  'Valise',
  'Ventilateur',
  'Vélo',
];

class ParcelMenuContent extends StatelessWidget {
  const ParcelMenuContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 6, bottom: 24),
      child: _ParcelActionsGrid(
        onSendParcel: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SendParcelPage()));
        },
        onTrackParcel: () => _showComingSoon(context, 'Suivre un colis'),
        onInitiations: () => _openPendingParcels(context),
        onMyParcels: () => _showComingSoon(context, 'Mes colis'),
      ),
    );
  }

  void _openPendingParcels(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ColisAttentePage(initialTabIndex: 1),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title sera bientôt disponible'),
        backgroundColor: _deepBlue,
      ),
    );
  }
}

class SendParcelPage extends StatefulWidget {
  const SendParcelPage({super.key});

  @override
  State<SendParcelPage> createState() => _SendParcelPageState();
}

class _SendParcelPageState extends State<SendParcelPage> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedNature;
  XFile? _pickedAttachment;
  int _parcelCount = 1;
  int _currentStep = 1;

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _valueController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
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

  void _showNaturePicker() {
    _showChoiceSheet(
      title: 'Nature du colis',
      items: _parcelNatures,
      selectedValue: _selectedNature,
      icon: Icons.inventory_2_outlined,
      onSelected: (nature) => setState(() => _selectedNature = nature),
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
                          color: _logoRed.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: _logoRed, size: 22),
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
                                    ? _logoRed.withValues(alpha: 0.36)
                                    : _deepBlue.withValues(alpha: 0.07),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : icon,
                                  color: isSelected ? _logoRed : _deepBlue,
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

  void _changeParcelCount(int delta) {
    setState(() {
      _parcelCount = (_parcelCount + delta).clamp(1, 99);
    });
  }

  void _goToStepTwo() {
    if (_departureController.text.trim().isEmpty ||
        _selectedNature == null ||
        _valueController.text.trim().isEmpty) {
      _showRequiredMessage('Remplissez tous les champs avant de continuer');
      return;
    }

    setState(() => _currentStep = 2);
  }

  Future<void> _pickAttachment() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _pickedAttachment = file);
  }

  void _previewTicket() {
    if (_destinationController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _firstNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _pickedAttachment == null ||
        _selectedNature == null ||
        _departureController.text.trim().isEmpty ||
        _valueController.text.trim().isEmpty) {
      _showRequiredMessage(
        "Remplissez tous les champs et importez l'image du colis avant l'aperçu",
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
          parcelNature: _selectedNature!,
          parcelCount: _parcelCount,
          attachmentPath: _pickedAttachment?.path,
          attachmentName: _pickedAttachment?.name,
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ParcelHeader(
                showStepBack: _currentStep == 2,
                onMenuTap: () => Navigator.pop(context),
                onStepBack: () => setState(() => _currentStep = 1),
              ),
              SizedBox(height: _currentStep == 1 ? 30 : 34),
              _StepDivider(label: 'Étape $_currentStep/2'),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: _currentStep == 1
                    ? _StepOneForm(
                        key: const ValueKey('parcel-step-one'),
                        departureController: _departureController,
                        valueController: _valueController,
                        selectedNature: _selectedNature,
                        parcelCount: _parcelCount,
                        onDepartureTap: () => _showCityPicker(
                          title: 'Point de départ',
                          controller: _departureController,
                        ),
                        onNatureTap: _showNaturePicker,
                        onMinus: () => _changeParcelCount(-1),
                        onPlus: () => _changeParcelCount(1),
                        onNext: _goToStepTwo,
                        onInitiations: () => _showInitiationsMessage(context),
                      )
                    : _StepTwoForm(
                        key: const ValueKey('parcel-step-two'),
                        destinationController: _destinationController,
                        lastNameController: _lastNameController,
                        firstNameController: _firstNameController,
                        phoneController: _phoneController,
                        attachmentPath: _pickedAttachment?.path,
                        attachmentName: _pickedAttachment?.name,
                        onDestinationTap: () => _showCityPicker(
                          title: 'Ville de destination',
                          controller: _destinationController,
                        ),
                        onPickAttachment: _pickAttachment,
                        onPreview: _previewTicket,
                        onInitiations: () => _showInitiationsMessage(context),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInitiationsMessage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ColisAttentePage(initialTabIndex: 1),
      ),
    );
  }
}

class _StepOneForm extends StatelessWidget {
  final TextEditingController departureController;
  final TextEditingController valueController;
  final String? selectedNature;
  final int parcelCount;
  final VoidCallback onDepartureTap;
  final VoidCallback onNatureTap;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onNext;
  final VoidCallback onInitiations;

  const _StepOneForm({
    required this.departureController,
    required this.valueController,
    required this.selectedNature,
    required this.parcelCount,
    required this.onDepartureTap,
    required this.onNatureTap,
    required this.onMinus,
    required this.onPlus,
    required this.onNext,
    required this.onInitiations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Point de départ :'),
        const SizedBox(height: 10),
        _ChoiceField(
          value: departureController.text,
          hintText: 'Point de départ',
          icon: Icons.radio_button_checked_rounded,
          onTap: onDepartureTap,
        ),
        const SizedBox(height: 20),
        const _SectionLabel('Informations du colis :'),
        const SizedBox(height: 10),
        _ChoiceField(
          value: selectedNature,
          hintText: 'Nature',
          icon: Icons.inventory_2_outlined,
          onTap: onNatureTap,
        ),
        const SizedBox(height: 12),
        _ParcelInputField(
          controller: valueController,
          hintText: 'Valeur',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _ParcelCountField(count: parcelCount, onMinus: onMinus, onPlus: onPlus),
        const SizedBox(height: 30),
        _PrimaryParcelButton(label: 'Suivant', onPressed: onNext),
        const SizedBox(height: 14),
        _OutlineParcelButton(
          label: "Liste des initiations d'envoi",
          onPressed: onInitiations,
        ),
      ],
    );
  }
}

class _StepTwoForm extends StatelessWidget {
  final TextEditingController destinationController;
  final TextEditingController lastNameController;
  final TextEditingController firstNameController;
  final TextEditingController phoneController;
  final String? attachmentPath;
  final String? attachmentName;
  final VoidCallback onDestinationTap;
  final VoidCallback onPickAttachment;
  final VoidCallback onPreview;
  final VoidCallback onInitiations;

  const _StepTwoForm({
    required this.destinationController,
    required this.lastNameController,
    required this.firstNameController,
    required this.phoneController,
    required this.attachmentPath,
    required this.attachmentName,
    required this.onDestinationTap,
    required this.onPickAttachment,
    required this.onPreview,
    required this.onInitiations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChoiceField(
          value: destinationController.text,
          hintText: 'Ville de destination',
          icon: Icons.location_on_rounded,
          onTap: onDestinationTap,
        ),
        const SizedBox(height: 12),
        _ParcelInputField(
          controller: lastNameController,
          hintText: 'Nom du destinataire',
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        _ParcelInputField(
          controller: firstNameController,
          hintText: 'Prénom du destinataire',
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 66,
          child: AfricanPhoneField(controller: phoneController),
        ),
        const SizedBox(height: 12),
        // L'image sert de preuve visuelle du colis : on la met donc en avant
        // et le bouton Aperçu la rend obligatoire dans la validation.
        _AttachmentField(
          fileName: attachmentName,
          filePath: attachmentPath,
          onTap: onPickAttachment,
        ),
        const SizedBox(height: 30),
        _PrimaryParcelButton(label: 'Aperçu', onPressed: onPreview),
        const SizedBox(height: 14),
        _OutlineParcelButton(
          label: "Liste des initiations d'envoi",
          onPressed: onInitiations,
        ),
      ],
    );
  }
}

class _ParcelHeader extends StatelessWidget {
  final bool showStepBack;
  final VoidCallback onMenuTap;
  final VoidCallback onStepBack;

  const _ParcelHeader({
    required this.showStepBack,
    required this.onMenuTap,
    required this.onStepBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _HeaderButton(icon: Icons.menu_rounded, onTap: onMenuTap),
            ),
            Image.asset(
              'assets/images/logo_fofana_no_background.png',
              height: 54,
              fit: BoxFit.contain,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showStepBack) ...[
              GestureDetector(
                onTap: onStepBack,
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF9EA5C6),
                  size: 28,
                ),
              ),
              const SizedBox(width: 4),
            ],
            const Text(
              'Envoyer un colis',
              style: TextStyle(
                color: _deepBlue,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ParcelActionsGrid extends StatelessWidget {
  final VoidCallback onSendParcel;
  final VoidCallback onTrackParcel;
  final VoidCallback onInitiations;
  final VoidCallback onMyParcels;

  const _ParcelActionsGrid({
    required this.onSendParcel,
    required this.onTrackParcel,
    required this.onInitiations,
    required this.onMyParcels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vos options colis',
            style: TextStyle(
              color: _deepBlue,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ParcelActionTile(
                icon: Icons.outbox_rounded,
                title: 'Envoyer',
                onTap: onSendParcel,
              ),
              const SizedBox(width: 12),
              _ParcelActionTile(
                icon: Icons.manage_search_rounded,
                title: 'Suivre',
                onTap: onTrackParcel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ParcelActionTile(
                icon: Icons.playlist_add_check_rounded,
                title: 'Initiations',
                onTap: onInitiations,
              ),
              const SizedBox(width: 12),
              _ParcelActionTile(
                icon: Icons.inventory_2_rounded,
                title: 'Mes colis',
                onTap: onMyParcels,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParcelActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ParcelActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 116),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _deepBlue.withValues(alpha: 0.10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _logoRed.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _logoRed.withValues(alpha: 0.35)),
                  ),
                  child: Icon(icon, color: _logoRed, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _deepBlue,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentField extends StatelessWidget {
  final String? fileName;
  final String? filePath;
  final VoidCallback onTap;

  const _AttachmentField({
    required this.fileName,
    required this.filePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null && fileName!.trim().isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: hasFile ? 118 : 82),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: hasFile
                ? _logoRed.withValues(alpha: 0.035)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasFile
                  ? _logoRed.withValues(alpha: 0.52)
                  : _deepBlue.withValues(alpha: 0.12),
              width: hasFile ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: hasFile
                    ? _logoRed.withValues(alpha: 0.10)
                    : _deepBlue.withValues(alpha: 0.04),
                blurRadius: hasFile ? 18 : 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _AttachmentPreview(
                filePath: filePath,
                hasFile: hasFile,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasFile
                          ? 'Image du colis importée'
                          : 'Importer image du colis',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasFile ? _deepBlue : const Color(0xFF6F7481),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasFile
                          ? fileName!
                          : "Champ obligatoire avant l'aperçu du billet",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasFile
                            ? _deepBlue.withValues(alpha: 0.66)
                            : _logoRed.withValues(alpha: 0.82),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                hasFile
                    ? Icons.check_circle_rounded
                    : Icons.add_photo_alternate_rounded,
                color: hasFile ? _logoRed : _deepBlue,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final String? filePath;
  final bool hasFile;

  const _AttachmentPreview({required this.filePath, required this.hasFile});

  @override
  Widget build(BuildContext context) {
    if (!hasFile || filePath == null || filePath!.trim().isEmpty) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: _logoRed.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.upload_file_rounded,
          color: _logoRed,
          size: 24,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.file(
        File(filePath!),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _logoRed.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.insert_photo_rounded,
            color: _logoRed,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: _deepBlue, size: 30),
      ),
    );
  }
}

class _StepDivider extends StatelessWidget {
  final String label;

  const _StepDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF9DA1AC), thickness: 1)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: _pageBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFB7BBC7), width: 1.2),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: _deepBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF9DA1AC), thickness: 1)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _deepBlue,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ChoiceField extends StatelessWidget {
  final String? value;
  final String hintText;
  final IconData icon;
  final VoidCallback onTap;

  const _ChoiceField({
    required this.value,
    required this.hintText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: _deepBlue.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _logoRed.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: _logoRed, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasValue ? value! : hintText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasValue ? _deepBlue : const Color(0xFF6F7481),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _deepBlue,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParcelInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const _ParcelInputField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: const TextStyle(
          color: _deepBlue,
          fontSize: 15.5,
          fontWeight: FontWeight.w800,
        ),
        decoration: const InputDecoration().copyWith(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF6F7481),
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
          contentPadding: const EdgeInsets.fromLTRB(18, 21, 18, 0),
        ),
      ),
    );
  }
}


class _ParcelCountField extends StatelessWidget {
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _ParcelCountField({
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _deepBlue.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _logoRed.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.view_in_ar_outlined,
              color: _logoRed,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Nombre de colis',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _deepBlue,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _CounterButton(icon: Icons.remove_rounded, onTap: onMinus),
          SizedBox(
            width: 56,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _deepBlue,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _CounterButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _logoRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _logoRed.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: _logoRed.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: _logoRed, size: 20),
        ),
      ),
    );
  }
}

class _PrimaryParcelButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryParcelButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _logoRed,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: _logoRed.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        child: Text(label),
      ),
    );
  }
}

class _OutlineParcelButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineParcelButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _deepBlue,
          side: const BorderSide(color: _deepBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      ),
    );
  }
}
