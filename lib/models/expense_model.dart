class ExpenseModel {
  final String id;
  final String libelle;
  final String description;
  final double cost;
  final int quantity;
  final String quantityUnit;
  final String costInWords;
  final String note;
  final DateTime createdAt;
  final String status;
  final String? qrCode;
  final String? reservationReference;
  final String? assignmentReference;
  final String? tripRoute;
  final String? busMatricule;

  const ExpenseModel({
    required this.id,
    required this.libelle,
    required this.description,
    required this.cost,
    required this.quantity,
    this.quantityUnit = '',
    this.costInWords = '',
    this.note = '',
    required this.createdAt,
    required this.status,
    this.qrCode,
    this.reservationReference,
    this.assignmentReference,
    this.tripRoute,
    this.busMatricule,
  });

  ExpenseModel copyWith({
    String? id,
    String? libelle,
    String? description,
    double? cost,
    int? quantity,
    String? quantityUnit,
    String? costInWords,
    String? note,
    DateTime? createdAt,
    String? status,
    String? qrCode,
    String? reservationReference,
    String? assignmentReference,
    String? tripRoute,
    String? busMatricule,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      libelle: libelle ?? this.libelle,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      costInWords: costInWords ?? this.costInWords,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      reservationReference: reservationReference ?? this.reservationReference,
      assignmentReference: assignmentReference ?? this.assignmentReference,
      tripRoute: tripRoute ?? this.tripRoute,
      busMatricule: busMatricule ?? this.busMatricule,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String? ?? '',
      libelle: json['libelle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      quantityUnit: json['quantityUnit'] as String? ?? '',
      costInWords: json['costInWords'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      status: json['status'] as String? ?? '',
      qrCode: json['qrCode'] as String?,
      reservationReference: json['reservationReference'] as String?,
      assignmentReference: json['assignmentReference'] as String?,
      tripRoute: json['tripRoute'] as String?,
      busMatricule: json['busMatricule'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'libelle': libelle,
      'description': description,
      'cost': cost,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'costInWords': costInWords,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'qrCode': qrCode,
      'reservationReference': reservationReference,
      'assignmentReference': assignmentReference,
      'tripRoute': tripRoute,
      'busMatricule': busMatricule,
    };
  }
}