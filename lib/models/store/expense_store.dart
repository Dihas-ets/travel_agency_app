import 'package:flutter/foundation.dart';
import 'package:fofanavoyage/models/expense_model.dart';
import 'package:fofanavoyage/services/expense_service.dart';

class ExpenseStore {
  static final ExpenseStore _instance = ExpenseStore._internal();

  factory ExpenseStore() => _instance;

  ExpenseStore._internal();

  final ExpenseService _service = ExpenseService();
  final ValueNotifier<List<ExpenseModel>> expensesNotifier =
      ValueNotifier<List<ExpenseModel>>(<ExpenseModel>[]);
  final ValueNotifier<int> expenseCountNotifier = ValueNotifier<int>(0);

  List<ExpenseModel> get allExpenses => expensesNotifier.value;
  List<ExpenseModel> get ongoingExpenses =>
      allExpenses.where((expense) => expense.isDraft).toList();
  List<ExpenseModel> get historicalExpenses =>
      allExpenses.where((expense) => !expense.isDraft).toList();

  Future<void> refresh() async {
    final expenses = await _service.listAll();
    expensesNotifier.value = expenses;
    expenseCountNotifier.value = expenses.length;
  }

  void addOrUpdate(ExpenseModel expense) {
    final updated = [...expensesNotifier.value]
      ..removeWhere((item) => item.id == expense.id)
      ..insert(0, expense);
    expensesNotifier.value = updated;
    expenseCountNotifier.value = updated.length;
  }

  double getTotalOngoingAmount() =>
      ongoingExpenses.fold(0, (sum, expense) => sum + expense.totalAmount);

  double getTotalAmount() =>
      allExpenses.fold(0, (sum, expense) => sum + expense.totalAmount);
}
