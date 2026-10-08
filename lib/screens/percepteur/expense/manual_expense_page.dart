import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fofanavoyage/auth/stockage_auth_local.dart';
import 'package:fofanavoyage/models/tax_group_model.dart';
import 'package:fofanavoyage/models/user_model.dart';
import 'package:fofanavoyage/models/store/expense_store.dart';
import 'package:fofanavoyage/services/auth_service.dart';
import 'package:fofanavoyage/services/expense_service.dart';
import 'package:fofanavoyage/services/tax_service.dart';

class ManualExpensePage extends StatefulWidget {
  final String? initialMecefCode;
  final String? initialMecefNim;

  const ManualExpensePage({
    super.key,
    this.initialMecefCode,
    this.initialMecefNim,
  });

  @override
  State<ManualExpensePage> createState() => _ManualExpensePageState();
}

class _ManualExpensePageState extends State<ManualExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ExpenseService();
  final _noteController = TextEditingController();
  final _mecefCodeController = TextEditingController();
  final _nimController = TextEditingController();
  final List<_ExpenseLineDraft> _lines = [_ExpenseLineDraft()];
  final List<TaxGroup> _taxGroups = [];
  final List<Map<String, dynamic>> _suppliers = [];
  String _selectedSupplierId = '';
  Map<String, dynamic>? _verifiedSupplier;
  UserModel? _user;
  DateTime _expenseDate = DateTime.now();
  Map<String, dynamic>? _verifiedInvoice;
  bool _invoiceConfirmed = false;
  bool _isMecefSource = false;
  bool _isLoading = true;
  bool _isVerifying = false;
  bool _isSaving = false;
  bool _isCreatingSupplier = false;
  String? _loadError;
  String? _requestError;

  static const _darkGreen = Color(0xFF0B4F2A);
  static const _green = Color(0xFF16A34A);

  bool get _isReadOnlyScan =>
      widget.initialMecefCode?.trim().isNotEmpty == true &&
      widget.initialMecefNim?.trim().isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    _mecefCodeController.text = widget.initialMecefCode ?? '';
    _nimController.text = widget.initialMecefNim ?? '';
    _isMecefSource =
        (widget.initialMecefCode?.isNotEmpty ?? false) ||
        (widget.initialMecefNim?.isNotEmpty ?? false);
    _loadFormData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _mecefCodeController.dispose();
    _nimController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Future<void> _loadFormData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      var user = await AuthLocalStore.getCurrentUser();
      if (user?.agenceId == null) {
        user = await AuthService().getProfile() ?? user;
      }
      if (user == null) {
        throw Exception(
          'Impossible de récupérer votre profil connecté. Reconnectez-vous.',
        );
      }
      final groups = await TaxService().getGroupsForModule('depense');
      final suppliers = await _service.listSuppliers();
      if (!mounted) return;
      setState(() {
        _user = user;
        _taxGroups
          ..clear()
          ..addAll(groups);
        _suppliers
          ..clear()
          ..addAll(suppliers);
        _isLoading = false;
      });
      if (user.agenceId == null) {
        setState(() {
          _loadError =
              "Votre compte n'est associé à aucune agence. Contactez l'administrateur.";
        });
      }
      if (_isMecefSource &&
          _mecefCodeController.text.trim().isNotEmpty &&
          _nimController.text.trim().isNotEmpty) {
        await _verifyMecefInvoice();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = _errorText(error);
      });
    }
  }

  String _errorText(Object error) => error
      .toString()
      .replaceFirst('Exception: ', '')
      .replaceFirst('FormatException: ', '');

  String _dateValue(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) setState(() => _expenseDate = selected);
  }

  Future<void> _createSupplier() async {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final emailController = TextEditingController();
    final ifuController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final details = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nouveau fournisseur'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom *'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Le nom est obligatoire'
                      : null,
                ),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact'),
                ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: ifuController,
                  decoration: const InputDecoration(labelText: 'IFU'),
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext, {
                'nom': nameController.text.trim(),
                'contact': contactController.text.trim(),
                'email': emailController.text.trim(),
                'ifu': ifuController.text.trim(),
                'adresse': addressController.text.trim(),
              });
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    if (details == null) {
      nameController.dispose();
      contactController.dispose();
      emailController.dispose();
      ifuController.dispose();
      addressController.dispose();
      return;
    }

    setState(() {
      _isCreatingSupplier = true;
      _requestError = null;
    });
    try {
      final supplier = await _service.createSupplier({
        'nom': details['nom'],
        'contact': details['contact']!.isEmpty ? null : details['contact'],
        'email': details['email']!.isEmpty ? null : details['email'],
        'ifu': details['ifu']!.isEmpty ? null : details['ifu'],
        'adresse': details['adresse']!.isEmpty ? null : details['adresse'],
      });
      if (!mounted) return;
      setState(() {
        _suppliers.add(supplier);
        _selectedSupplierId = supplier['id']?.toString() ?? '';
        _isCreatingSupplier = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isCreatingSupplier = false;
        _requestError = _errorText(error);
      });
    } finally {
      nameController.dispose();
      contactController.dispose();
      emailController.dispose();
      ifuController.dispose();
      addressController.dispose();
    }
  }

  double _lineUnitPriceTtc(_ExpenseLineDraft line) =>
      double.tryParse(line.unitPriceTtcController.text.replaceAll(',', '.')) ??
      0;

  double _lineUnitPriceHt(_ExpenseLineDraft line) {
    final rate = _taxRate(line);
    return ((_lineUnitPriceTtc(line) / (1 + rate / 100)) * 100).round() / 100;
  }

  double _lineBase(_ExpenseLineDraft line) =>
      _lineUnitPriceHt(line) *
      (double.tryParse(line.quantityController.text.replaceAll(',', '.')) ?? 0);

  double get _totalHt =>
      _lines.fold<double>(0, (sum, line) => sum + _lineBase(line));

  double _taxRate(_ExpenseLineDraft line) {
    final id = int.tryParse(line.taxGroupId);
    for (final group in _taxGroups) {
      if (group.id == id) return group.rate;
    }
    return 0;
  }

  double get _totalTtc => _lines.fold<double>(
    0,
    (sum, line) =>
        sum +
        _lineUnitPriceTtc(line) *
            (double.tryParse(
                  line.quantityController.text.replaceAll(',', '.'),
                ) ??
                0),
  );

  Future<void> _verifyMecefInvoice() async {
    final code = _mecefCodeController.text.trim();
    final nim = _nimController.text.trim();
    if (code.isEmpty || nim.isEmpty) {
      setState(() => _requestError = 'Saisissez le code MECeF et le NIM.');
      return;
    }
    setState(() {
      _isVerifying = true;
      _requestError = null;
      _verifiedInvoice = null;
      _invoiceConfirmed = false;
    });
    try {
      final response = await _service.verifyMecefInvoice(code: code, nim: nim);
      final invoice = response['data'];
      if (response['found'] != true || invoice is! Map) {
        throw Exception('Facture non trouvée ou invalide.');
      }
      if (!mounted) return;
      final verifiedInvoice = Map<String, dynamic>.from(invoice);
      if (_isReadOnlyScan) {
        _fillExpenseFormFromInvoice(verifiedInvoice);
      }
      setState(() {
        _verifiedInvoice = verifiedInvoice;
        _isVerifying = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _requestError = _errorText(error);
      });
    }
  }

  void _fillExpenseFormFromInvoice(Map<String, dynamic> invoice) {
    final rawDate = invoice['date_heure']?.toString() ?? '';
    final dateMatch = RegExp(r'(\d{2})/(\d{2})/(\d{4})').firstMatch(rawDate);
    if (dateMatch != null) {
      final day = int.parse(dateMatch.group(1)!);
      final month = int.parse(dateMatch.group(2)!);
      final year = int.parse(dateMatch.group(3)!);
      _expenseDate = DateTime(year, month, day);
    }

    final vendorIfu = invoice['vendeur_ifu']?.toString().trim().toUpperCase();
    final vendorName = invoice['vendeur_nom']?.toString().trim() ?? '';
    _verifiedSupplier = vendorName.isEmpty
        ? null
        : {
            'nom': vendorName,
            'ifu': invoice['vendeur_ifu'],
            'contact': invoice['vendeur_contact'],
            'adresse': invoice['vendeur_adresse'],
          };
    if (vendorIfu != null && vendorIfu.isNotEmpty) {
      final supplier = _suppliers.cast<Map<String, dynamic>?>().firstWhere(
        (item) => item?['ifu']?.toString().trim().toUpperCase() == vendorIfu,
        orElse: () => null,
      );
      _selectedSupplierId =
          supplier?['id']?.toString() ??
          (_verifiedSupplier == null ? '' : '__verified_supplier__');
    } else {
      _selectedSupplierId = _verifiedSupplier == null
          ? ''
          : '__verified_supplier__';
    }

    final taxCodes = <String>{};
    final rawTaxes = invoice['taxes'];
    if (rawTaxes is Map) {
      for (final label in rawTaxes.keys) {
        final match = RegExp(r'\[([A-F])\]').firstMatch(label.toString());
        if (match != null) taxCodes.add(match.group(1)!);
      }
    }

    final rawItems = invoice['items'];
    final invoiceItems = rawItems is List
        ? rawItems.whereType<Map>().toList()
        : <Map>[];
    if (invoiceItems.isEmpty) {
      invoiceItems.add({
        'designation': 'Facture MECeF ${invoice['code_mecef'] ?? ''}'.trim(),
        'quantite': 1,
        'total_ligne': invoice['total'],
        if (taxCodes.length == 1) 'groupe_taxe': taxCodes.first,
      });
    }
    final filledLines = <_ExpenseLineDraft>[];
    for (final rawItem in invoiceItems) {
      final item = Map<String, dynamic>.from(rawItem);
      final quantity = _invoiceNumber(item['quantite']);
      final total = _invoiceNumber(item['total_ligne'] ?? item['montant']);
      final unitPrice = _invoiceNumber(item['pu']);
      final resolvedQuantity = quantity > 0 ? quantity : 1.0;
      final totalTtc = total > 0 ? total : unitPrice * resolvedQuantity;
      final line = _ExpenseLineDraft();
      line.designationController.text =
          item['designation']?.toString().trim().isNotEmpty == true
          ? item['designation'].toString().trim()
          : 'Article MECeF';
      line.quantityController.text = _formatNumber(resolvedQuantity);
      line.unitController.text = 'unité';
      line.unitPriceTtcController.text = _formatNumber(
        totalTtc / resolvedQuantity,
      );

      final code =
          item['groupe_taxe']?.toString().trim().toUpperCase() ??
          (taxCodes.length == 1 ? taxCodes.first : '');
      final matchingGroup = _taxGroups.where(
        (group) => group.code?.toUpperCase() == code,
      );
      if (matchingGroup.isNotEmpty) {
        line.taxGroupId = matchingGroup.first.id.toString();
      }
      filledLines.add(line);
    }

    if (filledLines.isNotEmpty) {
      for (final line in _lines) {
        line.dispose();
      }
      _lines
        ..clear()
        ..addAll(filledLines);
    }
  }

  double _invoiceNumber(Object? value) {
    if (value is num) return value.toDouble();
    final normalized = value
        ?.toString()
        .replaceAll(RegExp(r'[^0-9,.-]'), '')
        .trim();
    if (normalized == null || normalized.isEmpty) return 0;
    if (normalized.contains(',') && normalized.contains('.')) {
      return double.tryParse(
            normalized.replaceAll('.', '').replaceAll(',', '.'),
          ) ??
          0;
    }
    if (normalized.contains('.')) {
      return double.tryParse(normalized) ?? 0;
    }
    return double.tryParse(normalized.replaceAll(',', '.')) ?? 0;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }

  Future<void> _submitExpense() async {
    if (_isSaving || _user?.agenceId == null) return;
    if (_isMecefSource) {
      if (_verifiedInvoice == null || !_invoiceConfirmed) {
        setState(() {
          _requestError =
              'Vérifiez puis confirmez la facture avant de créer la dépense.';
        });
        return;
      }
    } else if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _requestError = null;
    });
    try {
      final createdExpense = _isMecefSource
          ? await _service.createFromVerifiedInvoice(
              agencyId: _user!.agenceId!,
              code: _mecefCodeController.text.trim(),
              nim: _nimController.text.trim(),
              expenseDate: _dateValue(_expenseDate),
              note: _noteController.text.trim(),
              items: _lines
                  .map(
                    (line) => {
                      'designation': line.designationController.text.trim(),
                      'quantity': double.parse(
                        line.quantityController.text.trim().replaceAll(
                          ',',
                          '.',
                        ),
                      ),
                      'unit': line.unitController.text.trim().isEmpty
                          ? 'unité'
                          : line.unitController.text.trim(),
                      'unit_price': _lineUnitPriceHt(line),
                      'tax_group_id': line.taxGroupId.isEmpty
                          ? null
                          : int.parse(line.taxGroupId),
                      'note': line.noteController.text.trim().isEmpty
                          ? null
                          : line.noteController.text.trim(),
                    },
                  )
                  .toList(),
            )
          : await _service.createManual({
              'agency_id': _user!.agenceId,
              'source': 'manual',
              'payment_method': 'ESPECES',
              'expense_date': _dateValue(_expenseDate),
              'status': 'brouillon',
              'note': _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
              'items': _lines
                  .map(
                    (line) => {
                      'designation': line.designationController.text.trim(),
                      'quantity': double.parse(
                        line.quantityController.text.trim().replaceAll(
                          ',',
                          '.',
                        ),
                      ),
                      'unit': line.unitController.text.trim().isEmpty
                          ? 'unité'
                          : line.unitController.text.trim(),
                      'unit_price': _lineUnitPriceHt(line),
                      'tax_group_id': line.taxGroupId.isEmpty
                          ? null
                          : int.parse(line.taxGroupId),
                      'note': line.noteController.text.trim().isEmpty
                          ? null
                          : line.noteController.text.trim(),
                    },
                  )
                  .toList(),
              if (_selectedSupplierId.isNotEmpty)
                'supplier_id': int.parse(_selectedSupplierId),
            });
      ExpenseStore().addOrUpdate(createdExpense);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _requestError = _errorText(error);
      });
    }
  }

  void _addLine() => setState(() => _lines.add(_ExpenseLineDraft()));

  void _removeLine(int index) {
    if (_lines.length <= 1) return;
    final line = _lines.removeAt(index);
    line.dispose();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isReadOnlyScan ? 'Facture MECeF' : 'Nouvelle dépense',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  children: [
                    if (_isReadOnlyScan)
                      _buildReadOnlyBanner()
                    else
                      _buildSourceSelector(),
                    const SizedBox(height: 16),
                    if (_loadError != null) _buildMessage(_loadError!, true),
                    if (_requestError != null) ...[
                      _buildMessage(_requestError!, true),
                      const SizedBox(height: 12),
                    ],
                    if (_isReadOnlyScan && _isVerifying) ...[
                      const LinearProgressIndicator(color: _green),
                      const SizedBox(height: 12),
                      const Text(
                        'Vérification de la facture scannée...',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_isMecefSource) ...[
                      _buildMecefForm(readOnly: _isReadOnlyScan),
                      const SizedBox(height: 16),
                    ],
                    if (!_isReadOnlyScan || _verifiedInvoice != null)
                      _buildManualForm(readOnly: _isReadOnlyScan),
                    if (!_isReadOnlyScan) ...[
                      const SizedBox(height: 18),
                      _buildNoteField(),
                      const SizedBox(height: 18),
                      _buildSubmitButton(),
                    ] else ...[
                      const SizedBox(height: 18),
                      _buildSubmitButton(readOnlyScan: true),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSubmitButton({bool readOnlyScan = false}) {
    return ElevatedButton.icon(
      onPressed:
          _isSaving ||
              _loadError != null ||
              (readOnlyScan &&
                  (_isVerifying ||
                      _verifiedInvoice == null ||
                      !_invoiceConfirmed))
          ? null
          : _submitExpense,
      icon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.send_rounded),
      label: Text(_isSaving ? 'Enregistrement...' : 'Soumettre en brouillon'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildReadOnlyBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _green.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.visibility_rounded, color: _darkGreen),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Consultation uniquement : les informations scannées ne peuvent pas être modifiées.',
              style: TextStyle(color: _darkGreen, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSelector() {
    return Row(
      children: [
        Expanded(
          child: _sourceButton(
            title: 'Saisie manuelle',
            icon: Icons.edit_note_rounded,
            selected: !_isMecefSource,
            onTap: () => setState(() {
              _isMecefSource = false;
              _requestError = null;
            }),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _sourceButton(
            title: 'Facture MECEF',
            icon: Icons.qr_code_2_rounded,
            selected: _isMecefSource,
            onTap: () => setState(() {
              _isMecefSource = true;
              _requestError = null;
            }),
          ),
        ),
      ],
    );
  }

  Widget _sourceButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 19),
      label: Text(title, textAlign: TextAlign.center),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? _darkGreen : const Color(0xFF64748B),
        backgroundColor: selected ? const Color(0xFFEAF7EF) : Colors.white,
        side: BorderSide(
          color: selected ? _green : const Color(0xFFE2E8F0),
          width: selected ? 1.5 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildManualForm({bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dateSelector(readOnly: readOnly),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSupplierId,
                decoration: _decoration('Fournisseur (optionnel)'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Aucun fournisseur'),
                  ),
                  if (_verifiedSupplier != null &&
                      _selectedSupplierId == '__verified_supplier__')
                    DropdownMenuItem(
                      value: '__verified_supplier__',
                      child: Text(
                        '${_verifiedSupplier!['nom']} (facture MECeF)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ..._suppliers.map(
                    (supplier) => DropdownMenuItem(
                      value: supplier['id']?.toString() ?? '',
                      child: Text(
                        supplier['nom']?.toString() ?? 'Fournisseur',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: readOnly
                    ? null
                    : (value) =>
                          setState(() => _selectedSupplierId = value ?? ''),
              ),
            ),
            if (!readOnly) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Créer un fournisseur',
                onPressed: _isCreatingSupplier ? null : _createSupplier,
                icon: _isCreatingSupplier
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1_rounded),
                style: IconButton.styleFrom(
                  foregroundColor: _green,
                  backgroundColor: const Color(0xFFEAF7EF),
                  padding: const EdgeInsets.all(13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Lignes de dépense',
                style: TextStyle(
                  color: _darkGreen,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (!readOnly)
              TextButton.icon(
                onPressed: _addLine,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ajouter'),
              ),
          ],
        ),
        for (var index = 0; index < _lines.length; index++) ...[
          _lineCard(index, readOnly: readOnly),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7EF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Total HT / TTC estimé',
                  style: TextStyle(
                    color: _darkGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_totalHt.toStringAsFixed(2)} HT'),
                  Text(
                    '${_totalTtc.toStringAsFixed(2)} TTC',
                    style: const TextStyle(
                      color: _darkGreen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateSelector({bool readOnly = false}) {
    final date =
        '${_expenseDate.day.toString().padLeft(2, '0')}/'
        '${_expenseDate.month.toString().padLeft(2, '0')}/'
        '${_expenseDate.year}';
    return InkWell(
      onTap: readOnly ? null : _chooseDate,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _decoration('Date de la dépense'),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: _green),
            const SizedBox(width: 10),
            Text(date, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _lineCard(int index, {bool readOnly = false}) {
    final line = _lines[index];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ligne ${index + 1}',
                  style: const TextStyle(
                    color: _darkGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (!readOnly && _lines.length > 1)
                IconButton(
                  tooltip: 'Supprimer la ligne',
                  onPressed: () => _removeLine(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
            ],
          ),
          TextFormField(
            controller: line.designationController,
            decoration: _decoration('Désignation'),
            textCapitalization: TextCapitalization.sentences,
            readOnly: readOnly,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'La désignation est requise'
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: line.quantityController,
                  decoration: _decoration('Quantité'),
                  readOnly: readOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    final number =
                        double.tryParse((value ?? '').replaceAll(',', '.')) ??
                        0;
                    return number <= 0 ? 'Quantité invalide' : null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: line.unitController,
                  decoration: _decoration('Unité'),
                  textCapitalization: TextCapitalization.sentences,
                  readOnly: readOnly,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: line.unitPriceTtcController,
            decoration: _decoration('Prix unitaire TTC (FCFA)'),
            readOnly: readOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            onChanged: (_) => setState(() {}),
            validator: (value) {
              final number =
                  double.tryParse((value ?? '').replaceAll(',', '.')) ?? -1;
              return number < 0 ? 'Prix invalide' : null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: line.taxGroupId.isEmpty ? '' : line.taxGroupId,
            decoration: _decoration('Groupe de taxe'),
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: '', child: Text('Sans taxe')),
              ..._taxGroups.map(
                (group) => DropdownMenuItem(
                  value: group.id.toString(),
                  child: Text(
                    '${group.label} (${group.rate}%)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: readOnly
                ? null
                : (value) => setState(() => line.taxGroupId = value ?? ''),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: line.noteController,
            decoration: _decoration('Note de la ligne (optionnelle)'),
            readOnly: readOnly,
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'PU HT calculé : ${_lineUnitPriceHt(line).toStringAsFixed(2)} FCFA · '
              'Total TTC : ${(_lineUnitPriceTtc(line) * (double.tryParse(line.quantityController.text.replaceAll(',', '.')) ?? 0)).toStringAsFixed(2)} FCFA',
              style: const TextStyle(
                color: _darkGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMecefForm({bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _mecefCodeController,
          readOnly: readOnly,
          onChanged: readOnly ? null : (_) => _clearInvoiceVerification(),
          decoration: _decoration('Code MECeF / DGI'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nimController,
          readOnly: readOnly,
          onChanged: readOnly ? null : (_) => _clearInvoiceVerification(),
          decoration: _decoration('NIM'),
        ),
        const SizedBox(height: 12),
        if (!readOnly)
          OutlinedButton.icon(
            onPressed: _isVerifying ? null : _verifyMecefInvoice,
            icon: _isVerifying
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.verified_outlined),
            label: Text(
              _isVerifying ? 'Vérification...' : 'Vérifier la facture',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _darkGreen,
              side: const BorderSide(color: _green),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        if (_verifiedInvoice != null) ...[
          const SizedBox(height: 14),
          _verifiedInvoiceCard(),
        ],
      ],
    );
  }

  void _clearInvoiceVerification() {
    if (_verifiedInvoice == null && !_invoiceConfirmed) return;
    setState(() {
      _verifiedInvoice = null;
      _invoiceConfirmed = false;
    });
  }

  Widget _verifiedInvoiceCard() {
    final invoice = _verifiedInvoice!;
    final total =
        invoice['total']?.toString() ??
        invoice['montant_ttc']?.toString() ??
        'Non renseigné';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_rounded, color: _green),
              SizedBox(width: 8),
              Text(
                'Facture vérifiée',
                style: TextStyle(
                  color: _darkGreen,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _invoiceDetail('Fournisseur', invoice['vendeur_nom']),
          _invoiceDetail('IFU', invoice['vendeur_ifu']),
          _invoiceDetail('Date', invoice['date_heure']),
          _invoiceDetail('Total TTC', total),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _invoiceConfirmed,
            onChanged: (value) =>
                setState(() => _invoiceConfirmed = value ?? false),
            title: const Text(
              'Je confirme les informations de cette facture.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _invoiceDetail(String label, Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        '$label : $text',
        style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
      ),
    );
  }

  Widget _buildNoteField({bool readOnly = false}) => TextField(
    controller: _noteController,
    readOnly: readOnly,
    maxLines: 3,
    decoration: _decoration('Note générale (optionnelle)'),
  );

  Widget _buildMessage(String message, bool isError) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFEBEE) : const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? const Color(0xFFB42318) : _darkGreen,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _green, width: 1.4),
    ),
  );
}

class _ExpenseLineDraft {
  final designationController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final unitController = TextEditingController(text: 'unité');
  final unitPriceTtcController = TextEditingController();
  final noteController = TextEditingController();
  String taxGroupId = '';

  void dispose() {
    designationController.dispose();
    quantityController.dispose();
    unitController.dispose();
    unitPriceTtcController.dispose();
    noteController.dispose();
  }
}
