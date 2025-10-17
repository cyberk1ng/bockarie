import 'package:equatable/equatable.dart';

class CompanyInfo extends Equatable {
  final String id;
  final String companyName;
  final String address;
  final String city;
  final String postalCode;
  final String country;
  final String? vatNumber;
  final String? eoriNumber;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? defaultHsCodes; // JSON string for common HS codes

  const CompanyInfo({
    required this.id,
    required this.companyName,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
    this.vatNumber,
    this.eoriNumber,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.defaultHsCodes,
  });

  @override
  List<Object?> get props => [
    id,
    companyName,
    address,
    city,
    postalCode,
    country,
    vatNumber,
    eoriNumber,
    contactName,
    contactEmail,
    contactPhone,
    defaultHsCodes,
  ];

  CompanyInfo copyWith({
    String? id,
    String? companyName,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? vatNumber,
    String? eoriNumber,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? defaultHsCodes,
  }) {
    return CompanyInfo(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      vatNumber: vatNumber ?? this.vatNumber,
      eoriNumber: eoriNumber ?? this.eoriNumber,
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      defaultHsCodes: defaultHsCodes ?? this.defaultHsCodes,
    );
  }
}
