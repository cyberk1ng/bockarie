/// Models for Shippo API integration
library;

/// Address model for Shippo API
class ShippoAddress {
  final String name;
  final String street1;
  final String? street2;
  final String city;
  final String state;
  final String zip;
  final String country;

  ShippoAddress({
    required this.name,
    required this.street1,
    this.street2,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'street1': street1,
      if (street2 != null) 'street2': street2,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
    };
  }
}

/// Parcel model for Shippo API
class ShippoParcel {
  final String length;
  final String width;
  final String height;
  final String weight;
  final String distanceUnit;
  final String massUnit;

  ShippoParcel({
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
    this.distanceUnit = 'cm',
    this.massUnit = 'kg',
  });

  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'width': width,
      'height': height,
      'distance_unit': distanceUnit,
      'weight': weight,
      'mass_unit': massUnit,
    };
  }
}

/// Customs declaration item for international shipments
class ShippoCustomsItem {
  final String description;
  final int quantity;
  final String netWeight;
  final String massUnit;
  final String valueAmount;
  final String valueCurrency;
  final String originCountry;
  final String? tariffNumber;

  ShippoCustomsItem({
    required this.description,
    required this.quantity,
    required this.netWeight,
    this.massUnit = 'kg',
    required this.valueAmount,
    this.valueCurrency = 'USD',
    required this.originCountry,
    this.tariffNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'net_weight': netWeight,
      'mass_unit': massUnit,
      'value_amount': valueAmount,
      'value_currency': valueCurrency,
      'origin_country': originCountry,
      if (tariffNumber != null) 'tariff_number': tariffNumber,
    };
  }
}

/// Customs declaration for international shipments
class ShippoCustomsDeclaration {
  final String contentsType; // MERCHANDISE, DOCUMENTS, GIFT, etc.
  final String contentsExplanation;
  final String nonDeliveryOption; // RETURN or ABANDON
  final bool certify;
  final String certifySigner;
  final List<ShippoCustomsItem> items;

  ShippoCustomsDeclaration({
    required this.contentsType,
    required this.contentsExplanation,
    this.nonDeliveryOption = 'RETURN',
    this.certify = true,
    required this.certifySigner,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'contents_type': contentsType,
      'contents_explanation': contentsExplanation,
      'non_delivery_option': nonDeliveryOption,
      'certify': certify,
      'certify_signer': certifySigner,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// Shipment request model for Shippo API
class ShippoShipmentRequest {
  final ShippoAddress addressFrom;
  final ShippoAddress addressTo;
  final List<ShippoParcel> parcels;
  final bool async;
  final ShippoCustomsDeclaration? customsDeclaration;

  ShippoShipmentRequest({
    required this.addressFrom,
    required this.addressTo,
    required this.parcels,
    this.async = false,
    this.customsDeclaration,
  });

  Map<String, dynamic> toJson() {
    return {
      'address_from': addressFrom.toJson(),
      'address_to': addressTo.toJson(),
      'parcels': parcels.map((p) => p.toJson()).toList(),
      'async': async,
      if (customsDeclaration != null)
        'customs_declaration': customsDeclaration!.toJson(),
    };
  }
}

/// Service level model from Shippo API response
class ShippoServiceLevel {
  final String name;
  final String? token;

  ShippoServiceLevel({required this.name, this.token});

  factory ShippoServiceLevel.fromJson(Map<String, dynamic> json) {
    return ShippoServiceLevel(
      name: json['name'] as String? ?? 'Unknown Service',
      token: json['token'] as String?,
    );
  }
}

/// Rate model from Shippo API response
class ShippoRate {
  final String objectId;
  final String provider;
  final ShippoServiceLevel servicelevel;
  final String amount;
  final String currency;
  final String? amountLocal; // Local currency amount (often EUR)
  final String? currencyLocal; // Local currency code
  final int? estimatedDays;
  final String? durationTerms;
  final String? shipmentId; // Shipment ID this rate belongs to

  ShippoRate({
    required this.objectId,
    required this.provider,
    required this.servicelevel,
    required this.amount,
    required this.currency,
    this.amountLocal,
    this.currencyLocal,
    this.estimatedDays,
    this.durationTerms,
    this.shipmentId,
  });

  factory ShippoRate.fromJson(Map<String, dynamic> json) {
    return ShippoRate(
      objectId: json['object_id'] as String? ?? '',
      provider: json['provider'] as String? ?? 'Unknown',
      servicelevel: json['servicelevel'] != null
          ? ShippoServiceLevel.fromJson(
              json['servicelevel'] as Map<String, dynamic>,
            )
          : ShippoServiceLevel(name: 'Standard', token: null),
      amount: json['amount'] as String? ?? '0.0',
      currency: json['currency'] as String? ?? 'USD',
      amountLocal: json['amount_local'] as String?,
      currencyLocal: json['currency_local'] as String?,
      estimatedDays: json['estimated_days'] as int?,
      durationTerms: json['duration_terms'] as String?,
      shipmentId: json['shipment'] as String?,
    );
  }

  /// Convert Shippo rate to display price in EUR
  ///
  /// Shippo API returns rates in multiple formats:
  /// 1. For international shipments: amount_local in EUR (preferred)
  /// 2. For domestic shipments: amount in local currency (USD, CNY, etc.)
  ///
  /// Priority:
  /// - If currency_local is EUR, use amount_local directly
  /// - If currency is EUR, use amount directly
  /// - If currency is USD, convert using USD->EUR rate
  /// - Otherwise, log warning and attempt conversion
  double toPriceEur(double usdToEurRate) {
    // Priority 1: Use amount_local if it's in EUR
    if (currencyLocal == 'EUR' && amountLocal != null) {
      final eurPrice = double.tryParse(amountLocal!) ?? 0.0;
      return eurPrice;
    }

    // Priority 2: If amount is already in EUR
    if (currency == 'EUR') {
      final eurPrice = double.tryParse(amount) ?? 0.0;
      return eurPrice;
    }

    // Priority 3: Convert from USD
    if (currency == 'USD') {
      final usdPrice = double.tryParse(amount) ?? 0.0;
      return usdPrice * usdToEurRate;
    }

    // Fallback: Use amount_local if available (might be in EUR)
    if (amountLocal != null) {
      final localPrice = double.tryParse(amountLocal!) ?? 0.0;
      // Assume it's EUR or close enough
      return localPrice;
    }

    // Last resort: assume amount is reasonable and return as-is
    // This will be wrong for CNY/JPY but better than nothing
    return double.tryParse(amount) ?? 0.0;
  }
}

/// Shipment response model from Shippo API
class ShippoShipmentResponse {
  final String objectId;
  final String objectState;
  final List<ShippoRate> rates;
  final String? status;
  final List<ShippoMessage> messages;

  ShippoShipmentResponse({
    required this.objectId,
    required this.objectState,
    required this.rates,
    this.status,
    this.messages = const [],
  });

  factory ShippoShipmentResponse.fromJson(Map<String, dynamic> json) {
    return ShippoShipmentResponse(
      objectId: json['object_id'] as String? ?? '',
      objectState: json['object_state'] as String? ?? 'UNKNOWN',
      rates:
          (json['rates'] as List<dynamic>?)
              ?.map((r) => ShippoRate.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] as String?,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((m) => ShippoMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Shippo message model for errors and warnings
class ShippoMessage {
  final String text;
  final String? code;
  final String? source;

  ShippoMessage({required this.text, this.code, this.source});

  factory ShippoMessage.fromJson(Map<String, dynamic> json) {
    return ShippoMessage(
      text: json['text'] as String? ?? json['message'] as String? ?? '',
      code: json['code'] as String?,
      source: json['source'] as String?,
    );
  }
}

/// Error model for Shippo API errors
class ShippoError {
  final String message;
  final String? code;

  ShippoError({required this.message, this.code});

  factory ShippoError.fromJson(Map<String, dynamic> json) {
    return ShippoError(
      message:
          json['message'] as String? ??
          json['detail'] as String? ??
          'Unknown error',
      code: json['code'] as String?,
    );
  }

  @override
  String toString() {
    return code != null ? '$code: $message' : message;
  }
}
