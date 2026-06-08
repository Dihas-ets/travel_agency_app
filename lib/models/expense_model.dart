class ExpenseModel {
  final String id;
  final String libelle;
  final String description;
  final double cost;
  final int quantity;
  final String note;
  final DateTime createdAt;
  final String status; // "En cours", "Validé", "Rejeté"
  final String? qrCode;

  ExpenseModel({
    required this.id,
    required this.libelle,
    required this.description,
    required this.cost,
    required this.quantity,
    required this.note,
    required this.createdAt,
    this.status = "En cours",
    this.qrCode,
  });

  // Create copy with modifications
  ExpenseModel copyWith({
    String? id,
    String? libelle,
    String? description,
    double? cost,
    int? quantity,
    String? note,
    DateTime? createdAt,
    String? status,
    String? qrCode,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      libelle: libelle ?? this.libelle,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'description': description,
      'cost': cost,
      'quantity': quantity,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'qrCode': qrCode,
    };
  }

  // Create from JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      libelle: json['libelle'] as String,
      description: json['description'] as String,
      cost: (json['cost'] as num).toDouble(),
      quantity: json['quantity'] as int,
      note: json['note'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? "En cours",
      qrCode: json['qrCode'] as String?,
    );
  }
}
