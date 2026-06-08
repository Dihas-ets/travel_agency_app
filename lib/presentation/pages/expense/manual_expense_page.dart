import 'package:flutter/material.dart';
import 'package:code_initial/models/expense_model.dart';
import 'expense_store.dart';

class ManualExpensePage extends StatefulWidget {
  const ManualExpensePage({super.key});

  @override
  State<ManualExpensePage> createState() => _ManualExpensePageState();
}

class _ManualExpensePageState extends State<ManualExpensePage> {
  late TextEditingController libelleController;
  late TextEditingController descriptionController;
  late TextEditingController costController;
  late TextEditingController quantityController;
  late TextEditingController noteController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    libelleController = TextEditingController();
    descriptionController = TextEditingController();
    costController = TextEditingController();
    quantityController = TextEditingController(text: '1');
    noteController = TextEditingController();
  }

  @override
  void dispose() {
    libelleController.dispose();
    descriptionController.dispose();
    costController.dispose();
    quantityController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      try {
        final expense = ExpenseModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          libelle: libelleController.text.trim(),
          description: descriptionController.text.trim(),
          cost: double.parse(costController.text.trim()),
          quantity: int.parse(quantityController.text.trim()),
          note: noteController.text.trim(),
          createdAt: DateTime.now(),
          status: "En cours",
        );

        ExpenseStore().addExpense(expense);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Dépense "${expense.libelle}" enregistrée',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une Dépense'),
        backgroundColor: const Color(0xFF16A34A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Libellé
                const Text(
                  'Libellé *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B4F2A),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: libelleController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Carburant',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le libellé est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B4F2A),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Détails supplémentaires',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Coût
                const Text(
                  'Coût (FCFA) *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B4F2A),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: costController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le coût est requis';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Entrez un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quantité
                const Text(
                  'Quantité *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B4F2A),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.shopping_cart),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La quantité est requise';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Entrez un nombre entier';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Note
                const Text(
                  'Note',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B4F2A),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: 'Remarques supplémentaires',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _submitExpense,
                    icon: const Icon(Icons.check),
                    label: const Text('Enregistrer la Dépense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Annuler'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF16A34A),
                      side: const BorderSide(color: Color(0xFF16A34A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
