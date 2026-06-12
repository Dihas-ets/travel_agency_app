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
  final String? reservationReference;
  final String? tripRoute;
  final String? busMatricule;

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
    this.reservationReference,
    this.tripRoute,
    this.busMatricule,
  });

  /// Crée une copie en conservant les valeurs non modifiées.
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
    String? reservationReference,
    String? tripRoute,
    String? busMatricule,
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
      reservationReference: reservationReference ?? this.reservationReference,
      tripRoute: tripRoute ?? this.tripRoute,
      busMatricule: busMatricule ?? this.busMatricule,
    );
  }

  /// Convertit la dépense en JSON pour une sauvegarde future.
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
      'reservationReference': reservationReference,
      'tripRoute': tripRoute,
      'busMatricule': busMatricule,
    };
  }

  /// Reconstruit une dépense depuis le JSON, avec compatibilité anciennes données.
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
      reservationReference: json['reservationReference'] as String?,
      tripRoute: json['tripRoute'] as String?,
      busMatricule: json['busMatricule'] as String?,
    );
  }
}
