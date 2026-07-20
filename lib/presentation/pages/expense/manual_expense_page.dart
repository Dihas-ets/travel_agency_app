import 'package:flutter/material.dart';
import 'package:code_initial/models/expense_model.dart';
import 'package:code_initial/models/expense_store.dart';

class ManualExpensePage extends StatefulWidget {
  final String? initialLibelle;
  final String? initialDescription;
  final double? initialCost;
  final int? initialQuantity;
  final String? initialQuantityUnit;
  final String? initialCostInWords;
  final String? initialNote;
  final String? qrCode;
  final String? reservationReference;
  final String? assignmentReference;
  final String? tripRoute;
  final String? busMatricule;

  const ManualExpensePage({
    super.key,
    this.initialLibelle,
    this.initialDescription,
    this.initialCost,
    this.initialQuantity,
    this.initialQuantityUnit,
    this.initialCostInWords,
    this.initialNote,
    this.qrCode,
    this.reservationReference,
    this.assignmentReference,
    this.tripRoute,
    this.busMatricule,
  });

  @override
  State<ManualExpensePage> createState() => _ManualExpensePageState();
}

class _ManualExpensePageState extends State<ManualExpensePage> {
  late TextEditingController libelleController;
  late TextEditingController descriptionController;
  late TextEditingController costController;
  late TextEditingController quantityController;
  late TextEditingController quantityUnitController;
  late TextEditingController noteController;

  final _formKey = GlobalKey<FormState>();

  static const _darkGreen = Color(0xFF0B4F2A);
  static const _green = Color(0xFF16A34A);
  static const _orange = Color(0xFFFF9500);
  static const _textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    libelleController = TextEditingController(text: widget.initialLibelle);
    descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    costController = TextEditingController(
      text: widget.initialCost == null
          ? ''
          : widget.initialCost!.toStringAsFixed(0),
    );
    quantityController = TextEditingController(
      text: (widget.initialQuantity ?? 1).toString(),
    );
    quantityUnitController = TextEditingController(
      text: widget.initialQuantityUnit,
    );
    noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    libelleController.dispose();
    descriptionController.dispose();
    costController.dispose();
    quantityController.dispose();
    quantityUnitController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _submitExpense() {
    if (!_formKey.currentState!.validate()) return;

    try {
      final expense = ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        libelle: libelleController.text.trim(),
        description: descriptionController.text.trim(),
        cost: double.parse(costController.text.trim()),
        quantity: int.parse(quantityController.text.trim()),
        quantityUnit: quantityUnitController.text.trim(),
        costInWords: widget.initialCostInWords?.trim() ?? '',
        note: noteController.text.trim(),
        createdAt: DateTime.now(),
        status: 'En cours',
        qrCode: widget.qrCode,
        reservationReference: widget.reservationReference,
        assignmentReference: widget.assignmentReference,
        tripRoute: widget.tripRoute,
        busMatricule: widget.busMatricule,
      );

      ExpenseStore().addExpense(expense);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dépense "${expense.libelle}" enregistrée'),
          backgroundColor: _green,
          duration: const Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.of(context).pop();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ajouter une dépense',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            children: [
              _buildHero(),
              if (widget.tripRoute != null || widget.busMatricule != null) ...[
                const SizedBox(height: 14),
                _buildTripContextCard(),
              ],
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'Informations',
                icon: Icons.receipt_long_rounded,
                children: [
                  _buildTextField(
                    controller: libelleController,
                    label: 'Libellé',
                    hintText: 'Ex: Carburant',
                    icon: Icons.label_important_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le libellé est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: descriptionController,
                    label: 'Description',
                    hintText: 'Détails supplémentaires',
                    icon: Icons.description_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Montant',
                icon: Icons.payments_rounded,
                children: [
                  _buildTextField(
                    controller: costController,
                    label: 'Coût (FCFA)',
                    hintText: 'Ex: 150000',
                    icon: Icons.account_balance_wallet_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le coût est requis';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Entrez un nombre valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: quantityController,
                    label: 'Quantité',
                    hintText: 'Ex: 20',
                    icon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La quantité est requise';
                      }
                      final quantity = int.tryParse(value.trim());
                      if (quantity == null || quantity <= 0) {
                        return 'Entrez un nombre entier valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: quantityUnitController,
                    label: 'Unité',
                    hintText: 'Ex: litre, sac, pièce',
                    icon: Icons.straighten_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Note',
                icon: Icons.sticky_note_2_rounded,
                children: [
                  _buildTextField(
                    controller: noteController,
                    label: 'Remarque',
                    hintText: 'Ajoutez une précision utile',
                    icon: Icons.edit_note_rounded,
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _submitExpense,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Enregistrer la dépense'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Annuler'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _darkGreen,
                  side: BorderSide(color: _darkGreen.withValues(alpha: 0.28)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripContextCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE53935).withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          const _FieldIcon(
            icon: Icons.directions_bus_filled_rounded,
            color: Color(0xFFE53935),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tripRoute ?? 'Trajet non renseigné',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bus: ${widget.busMatricule ?? 'Matricule non renseigné'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _darkGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.add_card_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouvelle dépense',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Renseignez les informations puis envoyez la dépense en validation.',
                  style: TextStyle(
                    color: Color(0xFFD8F3E2),
                    fontSize: 13.4,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _FieldIcon(icon: icon, color: _green),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: _darkGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: suffixText,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(9),
          child: _FieldIcon(icon: icon, color: _orange),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _green, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        labelStyle: const TextStyle(
          color: _textMuted,
          fontWeight: FontWeight.w800,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 17,
          horizontal: 14,
        ),
      ),
      validator: validator,
    );
  }
}

class _FieldIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _FieldIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }
}
