import 'package:flutter/material.dart';
import 'package:code_initial/domain/models/expense_model.dart';

/// Singleton en mémoire pour stocker et notifier les changements
/// des dépenses du percepteur.
class ExpenseStore {
  static final ExpenseStore _instance = ExpenseStore._internal();

  factory ExpenseStore() {
    return _instance;
  }

  ExpenseStore._internal();

  final List<ExpenseModel> _expenses = [];
  final ValueNotifier<List<ExpenseModel>> expensesNotifier = ValueNotifier([]);
  final ValueNotifier<int> expenseCountNotifier = ValueNotifier(0);

  /// Retourne l'ensemble des dépenses en mémoire.
  List<ExpenseModel> get allExpenses => _expenses;

  /// Liste des dépenses en cours de traitement.
  List<ExpenseModel> get ongoingExpenses =>
      _expenses.where((e) => e.status == "En cours").toList();

  /// Liste des dépenses déjà traitées (validées ou rejetées).
  List<ExpenseModel> get historicalExpenses =>
      _expenses.where((e) => e.status != "En cours").toList();

  // Add expense
  void addExpense(ExpenseModel expense) {
    _expenses.add(expense);
    _updateNotifiers();
  }

  // Add multiple expenses
  void addExpenses(List<ExpenseModel> expenses) {
    _expenses.addAll(expenses);
    _updateNotifiers();
  }

  // Update expense
  void updateExpense(String id, ExpenseModel updatedExpense) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      _updateNotifiers();
    }
  }

  // Delete expense
  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    _updateNotifiers();
  }

  /// Met à jour le statut d'une dépense existante.
  ///
  /// Exemple de statut : "En cours", "Validé", "Rejeté".
  void updateExpenseStatus(String id, String newStatus) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      _expenses[index] = _expenses[index].copyWith(status: newStatus);
      _updateNotifiers();
    }
  }

  // Clear all expenses
  void clearExpenses() {
    _expenses.clear();
    _updateNotifiers();
  }

  // Clear ongoing expenses
  void clearOngoingExpenses() {
    _expenses.removeWhere((e) => e.status == "En cours");
    _updateNotifiers();
  }

  // Private method to update all notifiers
  void _updateNotifiers() {
    expensesNotifier.value = [..._expenses];
    expenseCountNotifier.value = _expenses.length;
  }

  // Get total amount of ongoing expenses
  double getTotalOngoingAmount() {
    return ongoingExpenses.fold(
      0,
      (sum, expense) => sum + (expense.cost * expense.quantity),
    );
  }

  // Get total amount of all expenses
  double getTotalAmount() {
    return _expenses.fold(
      0,
      (sum, expense) => sum + (expense.cost * expense.quantity),
    );
  }
}
