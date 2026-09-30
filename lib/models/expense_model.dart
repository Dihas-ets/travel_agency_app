class ExpenseItemModel {
  final int id;
  final String designation;
  final double quantity;
  final String unit;
  final double unitPrice;
  final int? taxGroupId;
  final double taxRate;
  final double taxAmount;
  final double amount;
  final double amountTtc;
  final String? note;

  const ExpenseItemModel({
    required this.id,
    required this.designation,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.taxGroupId,
    required this.taxRate,
    required this.taxAmount,
    required this.amount,
    required this.amountTtc,
    required this.note,
  });

  factory ExpenseItemModel.fromJson(Map<String, dynamic> json) {
    double number(Object? value) =>
        double.tryParse(value?.toString() ?? '') ?? 0;

    return ExpenseItemModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      designation: json['designation']?.toString() ?? '',
      quantity: number(json['quantity']),
      unit: json['unit']?.toString() ?? '',
      unitPrice: number(json['unit_price']),
      taxGroupId: int.tryParse(json['tax_group_id']?.toString() ?? ''),
      taxRate: number(json['tax_rate']),
      taxAmount: number(json['tax_amount']),
      amount: number(json['amount']),
      amountTtc: number(json['amount_ttc']),
      note: json['note']?.toString(),
    );
  }
}

class ExpenseModel {
  final String id;
  final String code;
  final int? agencyId;
  final String? agencyName;
  final int? supplierId;
  final String? supplierName;
  final String source;
  final String? paymentMethod;
  final DateTime createdAt;
  final double totalAmount;
  final String status;
  final String note;
  final List<ExpenseItemModel> items;

  const ExpenseModel({
    required this.id,
    required this.code,
    required this.agencyId,
    required this.agencyName,
    required this.supplierId,
    required this.supplierName,
    required this.source,
    required this.paymentMethod,
    required this.createdAt,
    required this.totalAmount,
    required this.status,
    required this.note,
    required this.items,
  });

  bool get isDraft => status == 'brouillon';

  String get statusLabel {
    switch (status) {
      case 'brouillon':
        return 'Brouillon';
      case 'validé':
        return 'Validé';
      case 'rejeté':
        return 'Rejeté';
      default:
        return status;
    }
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    double number(Object? value) =>
        double.tryParse(value?.toString() ?? '') ?? 0;
    Map<String, dynamic> mapValue(Object? value) =>
        value is Map ? Map<String, dynamic>.from(value) : {};

    final agency = mapValue(json['agency']);
    final supplier = mapValue(json['supplier']);
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    ExpenseItemModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <ExpenseItemModel>[];

    return ExpenseModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      agencyId: int.tryParse(json['agency_id']?.toString() ?? ''),
      agencyName: agency['nom']?.toString(),
      supplierId: int.tryParse(json['supplier_id']?.toString() ?? ''),
      supplierName: supplier['nom']?.toString(),
      source: json['source']?.toString() ?? 'manual',
      paymentMethod: json['payment_method']?.toString(),
      createdAt:
          DateTime.tryParse(
            json['expense_date']?.toString() ??
                json['created_at']?.toString() ??
                '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      totalAmount: number(json['total_amount']),
      status: json['status']?.toString() ?? 'brouillon',
      note: json['note']?.toString() ?? '',
      items: items,
    );
  }

  // Legacy display accessors retained for the existing expense cards.
  String get libelle => items.isNotEmpty ? items.first.designation : code;
  String get description => note;
  double get cost => totalAmount;
  int get quantity => 1;
  String get quantityUnit => '';
  String get costInWords => '';
  String? get reservationReference => null;
  String? get assignmentReference => null;
  String? get tripRoute => null;
  String? get busMatricule => null;
  String? get qrCode => source == 'mecef_verified' ? source : null;
}
