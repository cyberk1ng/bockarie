import 'package:equatable/equatable.dart';

class Shipment extends Equatable {
  final String id;
  final DateTime createdAt;
  final String originCity;
  final String originPostal;
  final String destCity;
  final String destPostal;
  final int? deadlineDays;
  final String? notes;

  const Shipment({
    required this.id,
    required this.createdAt,
    required this.originCity,
    required this.originPostal,
    required this.destCity,
    required this.destPostal,
    this.deadlineDays,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    createdAt,
    originCity,
    originPostal,
    destCity,
    destPostal,
    deadlineDays,
    notes,
  ];

  Shipment copyWith({
    String? id,
    DateTime? createdAt,
    String? originCity,
    String? originPostal,
    String? destCity,
    String? destPostal,
    int? deadlineDays,
    String? notes,
  }) {
    return Shipment(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      originCity: originCity ?? this.originCity,
      originPostal: originPostal ?? this.originPostal,
      destCity: destCity ?? this.destCity,
      destPostal: destPostal ?? this.destPostal,
      deadlineDays: deadlineDays ?? this.deadlineDays,
      notes: notes ?? this.notes,
    );
  }
}
