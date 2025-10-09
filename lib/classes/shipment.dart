import 'package:equatable/equatable.dart';

class Shipment extends Equatable {
  final String id;
  final DateTime createdAt;
  final String originCity;
  final String originPostal;
  final String destCity;
  final String destPostal;
  final String? notes;

  const Shipment({
    required this.id,
    required this.createdAt,
    required this.originCity,
    required this.originPostal,
    required this.destCity,
    required this.destPostal,
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
    notes,
  ];

  Shipment copyWith({
    String? id,
    DateTime? createdAt,
    String? originCity,
    String? originPostal,
    String? destCity,
    String? destPostal,
    String? notes,
  }) {
    return Shipment(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      originCity: originCity ?? this.originCity,
      originPostal: originPostal ?? this.originPostal,
      destCity: destCity ?? this.destCity,
      destPostal: destPostal ?? this.destPostal,
      notes: notes ?? this.notes,
    );
  }
}
