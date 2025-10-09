// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ShipmentsTable extends Shipments
    with TableInfo<$ShipmentsTable, Shipment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShipmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originCityMeta = const VerificationMeta(
    'originCity',
  );
  @override
  late final GeneratedColumn<String> originCity = GeneratedColumn<String>(
    'origin_city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originPostalMeta = const VerificationMeta(
    'originPostal',
  );
  @override
  late final GeneratedColumn<String> originPostal = GeneratedColumn<String>(
    'origin_postal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destCityMeta = const VerificationMeta(
    'destCity',
  );
  @override
  late final GeneratedColumn<String> destCity = GeneratedColumn<String>(
    'dest_city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destPostalMeta = const VerificationMeta(
    'destPostal',
  );
  @override
  late final GeneratedColumn<String> destPostal = GeneratedColumn<String>(
    'dest_postal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    originCity,
    originPostal,
    destCity,
    destPostal,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shipments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shipment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('origin_city')) {
      context.handle(
        _originCityMeta,
        originCity.isAcceptableOrUnknown(data['origin_city']!, _originCityMeta),
      );
    } else if (isInserting) {
      context.missing(_originCityMeta);
    }
    if (data.containsKey('origin_postal')) {
      context.handle(
        _originPostalMeta,
        originPostal.isAcceptableOrUnknown(
          data['origin_postal']!,
          _originPostalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originPostalMeta);
    }
    if (data.containsKey('dest_city')) {
      context.handle(
        _destCityMeta,
        destCity.isAcceptableOrUnknown(data['dest_city']!, _destCityMeta),
      );
    } else if (isInserting) {
      context.missing(_destCityMeta);
    }
    if (data.containsKey('dest_postal')) {
      context.handle(
        _destPostalMeta,
        destPostal.isAcceptableOrUnknown(data['dest_postal']!, _destPostalMeta),
      );
    } else if (isInserting) {
      context.missing(_destPostalMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shipment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shipment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      originCity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_city'],
      )!,
      originPostal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_postal'],
      )!,
      destCity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dest_city'],
      )!,
      destPostal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dest_postal'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ShipmentsTable createAlias(String alias) {
    return $ShipmentsTable(attachedDatabase, alias);
  }
}

class Shipment extends DataClass implements Insertable<Shipment> {
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
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['origin_city'] = Variable<String>(originCity);
    map['origin_postal'] = Variable<String>(originPostal);
    map['dest_city'] = Variable<String>(destCity);
    map['dest_postal'] = Variable<String>(destPostal);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ShipmentsCompanion toCompanion(bool nullToAbsent) {
    return ShipmentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      originCity: Value(originCity),
      originPostal: Value(originPostal),
      destCity: Value(destCity),
      destPostal: Value(destPostal),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Shipment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shipment(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      originCity: serializer.fromJson<String>(json['originCity']),
      originPostal: serializer.fromJson<String>(json['originPostal']),
      destCity: serializer.fromJson<String>(json['destCity']),
      destPostal: serializer.fromJson<String>(json['destPostal']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'originCity': serializer.toJson<String>(originCity),
      'originPostal': serializer.toJson<String>(originPostal),
      'destCity': serializer.toJson<String>(destCity),
      'destPostal': serializer.toJson<String>(destPostal),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Shipment copyWith({
    String? id,
    DateTime? createdAt,
    String? originCity,
    String? originPostal,
    String? destCity,
    String? destPostal,
    Value<String?> notes = const Value.absent(),
  }) => Shipment(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    originCity: originCity ?? this.originCity,
    originPostal: originPostal ?? this.originPostal,
    destCity: destCity ?? this.destCity,
    destPostal: destPostal ?? this.destPostal,
    notes: notes.present ? notes.value : this.notes,
  );
  Shipment copyWithCompanion(ShipmentsCompanion data) {
    return Shipment(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      originCity: data.originCity.present
          ? data.originCity.value
          : this.originCity,
      originPostal: data.originPostal.present
          ? data.originPostal.value
          : this.originPostal,
      destCity: data.destCity.present ? data.destCity.value : this.destCity,
      destPostal: data.destPostal.present
          ? data.destPostal.value
          : this.destPostal,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shipment(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('originCity: $originCity, ')
          ..write('originPostal: $originPostal, ')
          ..write('destCity: $destCity, ')
          ..write('destPostal: $destPostal, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    originCity,
    originPostal,
    destCity,
    destPostal,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shipment &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.originCity == this.originCity &&
          other.originPostal == this.originPostal &&
          other.destCity == this.destCity &&
          other.destPostal == this.destPostal &&
          other.notes == this.notes);
}

class ShipmentsCompanion extends UpdateCompanion<Shipment> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> originCity;
  final Value<String> originPostal;
  final Value<String> destCity;
  final Value<String> destPostal;
  final Value<String?> notes;
  final Value<int> rowid;
  const ShipmentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.originCity = const Value.absent(),
    this.originPostal = const Value.absent(),
    this.destCity = const Value.absent(),
    this.destPostal = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShipmentsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required String originCity,
    required String originPostal,
    required String destCity,
    required String destPostal,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       originCity = Value(originCity),
       originPostal = Value(originPostal),
       destCity = Value(destCity),
       destPostal = Value(destPostal);
  static Insertable<Shipment> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? originCity,
    Expression<String>? originPostal,
    Expression<String>? destCity,
    Expression<String>? destPostal,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (originCity != null) 'origin_city': originCity,
      if (originPostal != null) 'origin_postal': originPostal,
      if (destCity != null) 'dest_city': destCity,
      if (destPostal != null) 'dest_postal': destPostal,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShipmentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? originCity,
    Value<String>? originPostal,
    Value<String>? destCity,
    Value<String>? destPostal,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return ShipmentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      originCity: originCity ?? this.originCity,
      originPostal: originPostal ?? this.originPostal,
      destCity: destCity ?? this.destCity,
      destPostal: destPostal ?? this.destPostal,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (originCity.present) {
      map['origin_city'] = Variable<String>(originCity.value);
    }
    if (originPostal.present) {
      map['origin_postal'] = Variable<String>(originPostal.value);
    }
    if (destCity.present) {
      map['dest_city'] = Variable<String>(destCity.value);
    }
    if (destPostal.present) {
      map['dest_postal'] = Variable<String>(destPostal.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShipmentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('originCity: $originCity, ')
          ..write('originPostal: $originPostal, ')
          ..write('destCity: $destCity, ')
          ..write('destPostal: $destPostal, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CartonsTable extends Cartons with TableInfo<$CartonsTable, Carton> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shipmentIdMeta = const VerificationMeta(
    'shipmentId',
  );
  @override
  late final GeneratedColumn<String> shipmentId = GeneratedColumn<String>(
    'shipment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shipments (id)',
    ),
  );
  static const VerificationMeta _lengthCmMeta = const VerificationMeta(
    'lengthCm',
  );
  @override
  late final GeneratedColumn<double> lengthCm = GeneratedColumn<double>(
    'length_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthCmMeta = const VerificationMeta(
    'widthCm',
  );
  @override
  late final GeneratedColumn<double> widthCm = GeneratedColumn<double>(
    'width_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shipmentId,
    lengthCm,
    widthCm,
    heightCm,
    weightKg,
    qty,
    itemType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cartons';
  @override
  VerificationContext validateIntegrity(
    Insertable<Carton> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shipment_id')) {
      context.handle(
        _shipmentIdMeta,
        shipmentId.isAcceptableOrUnknown(data['shipment_id']!, _shipmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shipmentIdMeta);
    }
    if (data.containsKey('length_cm')) {
      context.handle(
        _lengthCmMeta,
        lengthCm.isAcceptableOrUnknown(data['length_cm']!, _lengthCmMeta),
      );
    } else if (isInserting) {
      context.missing(_lengthCmMeta);
    }
    if (data.containsKey('width_cm')) {
      context.handle(
        _widthCmMeta,
        widthCm.isAcceptableOrUnknown(data['width_cm']!, _widthCmMeta),
      );
    } else if (isInserting) {
      context.missing(_widthCmMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Carton map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Carton(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shipmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shipment_id'],
      )!,
      lengthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_cm'],
      )!,
      widthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width_cm'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
    );
  }

  @override
  $CartonsTable createAlias(String alias) {
    return $CartonsTable(attachedDatabase, alias);
  }
}

class Carton extends DataClass implements Insertable<Carton> {
  final String id;
  final String shipmentId;
  final double lengthCm;
  final double widthCm;
  final double heightCm;
  final double weightKg;
  final int qty;
  final String itemType;
  const Carton({
    required this.id,
    required this.shipmentId,
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    required this.weightKg,
    required this.qty,
    required this.itemType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shipment_id'] = Variable<String>(shipmentId);
    map['length_cm'] = Variable<double>(lengthCm);
    map['width_cm'] = Variable<double>(widthCm);
    map['height_cm'] = Variable<double>(heightCm);
    map['weight_kg'] = Variable<double>(weightKg);
    map['qty'] = Variable<int>(qty);
    map['item_type'] = Variable<String>(itemType);
    return map;
  }

  CartonsCompanion toCompanion(bool nullToAbsent) {
    return CartonsCompanion(
      id: Value(id),
      shipmentId: Value(shipmentId),
      lengthCm: Value(lengthCm),
      widthCm: Value(widthCm),
      heightCm: Value(heightCm),
      weightKg: Value(weightKg),
      qty: Value(qty),
      itemType: Value(itemType),
    );
  }

  factory Carton.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Carton(
      id: serializer.fromJson<String>(json['id']),
      shipmentId: serializer.fromJson<String>(json['shipmentId']),
      lengthCm: serializer.fromJson<double>(json['lengthCm']),
      widthCm: serializer.fromJson<double>(json['widthCm']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      qty: serializer.fromJson<int>(json['qty']),
      itemType: serializer.fromJson<String>(json['itemType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shipmentId': serializer.toJson<String>(shipmentId),
      'lengthCm': serializer.toJson<double>(lengthCm),
      'widthCm': serializer.toJson<double>(widthCm),
      'heightCm': serializer.toJson<double>(heightCm),
      'weightKg': serializer.toJson<double>(weightKg),
      'qty': serializer.toJson<int>(qty),
      'itemType': serializer.toJson<String>(itemType),
    };
  }

  Carton copyWith({
    String? id,
    String? shipmentId,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    double? weightKg,
    int? qty,
    String? itemType,
  }) => Carton(
    id: id ?? this.id,
    shipmentId: shipmentId ?? this.shipmentId,
    lengthCm: lengthCm ?? this.lengthCm,
    widthCm: widthCm ?? this.widthCm,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    qty: qty ?? this.qty,
    itemType: itemType ?? this.itemType,
  );
  Carton copyWithCompanion(CartonsCompanion data) {
    return Carton(
      id: data.id.present ? data.id.value : this.id,
      shipmentId: data.shipmentId.present
          ? data.shipmentId.value
          : this.shipmentId,
      lengthCm: data.lengthCm.present ? data.lengthCm.value : this.lengthCm,
      widthCm: data.widthCm.present ? data.widthCm.value : this.widthCm,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      qty: data.qty.present ? data.qty.value : this.qty,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Carton(')
          ..write('id: $id, ')
          ..write('shipmentId: $shipmentId, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('widthCm: $widthCm, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('qty: $qty, ')
          ..write('itemType: $itemType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shipmentId,
    lengthCm,
    widthCm,
    heightCm,
    weightKg,
    qty,
    itemType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Carton &&
          other.id == this.id &&
          other.shipmentId == this.shipmentId &&
          other.lengthCm == this.lengthCm &&
          other.widthCm == this.widthCm &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.qty == this.qty &&
          other.itemType == this.itemType);
}

class CartonsCompanion extends UpdateCompanion<Carton> {
  final Value<String> id;
  final Value<String> shipmentId;
  final Value<double> lengthCm;
  final Value<double> widthCm;
  final Value<double> heightCm;
  final Value<double> weightKg;
  final Value<int> qty;
  final Value<String> itemType;
  final Value<int> rowid;
  const CartonsCompanion({
    this.id = const Value.absent(),
    this.shipmentId = const Value.absent(),
    this.lengthCm = const Value.absent(),
    this.widthCm = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.qty = const Value.absent(),
    this.itemType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CartonsCompanion.insert({
    required String id,
    required String shipmentId,
    required double lengthCm,
    required double widthCm,
    required double heightCm,
    required double weightKg,
    required int qty,
    required String itemType,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shipmentId = Value(shipmentId),
       lengthCm = Value(lengthCm),
       widthCm = Value(widthCm),
       heightCm = Value(heightCm),
       weightKg = Value(weightKg),
       qty = Value(qty),
       itemType = Value(itemType);
  static Insertable<Carton> custom({
    Expression<String>? id,
    Expression<String>? shipmentId,
    Expression<double>? lengthCm,
    Expression<double>? widthCm,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<int>? qty,
    Expression<String>? itemType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shipmentId != null) 'shipment_id': shipmentId,
      if (lengthCm != null) 'length_cm': lengthCm,
      if (widthCm != null) 'width_cm': widthCm,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (qty != null) 'qty': qty,
      if (itemType != null) 'item_type': itemType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CartonsCompanion copyWith({
    Value<String>? id,
    Value<String>? shipmentId,
    Value<double>? lengthCm,
    Value<double>? widthCm,
    Value<double>? heightCm,
    Value<double>? weightKg,
    Value<int>? qty,
    Value<String>? itemType,
    Value<int>? rowid,
  }) {
    return CartonsCompanion(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      qty: qty ?? this.qty,
      itemType: itemType ?? this.itemType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shipmentId.present) {
      map['shipment_id'] = Variable<String>(shipmentId.value);
    }
    if (lengthCm.present) {
      map['length_cm'] = Variable<double>(lengthCm.value);
    }
    if (widthCm.present) {
      map['width_cm'] = Variable<double>(widthCm.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartonsCompanion(')
          ..write('id: $id, ')
          ..write('shipmentId: $shipmentId, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('widthCm: $widthCm, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('qty: $qty, ')
          ..write('itemType: $itemType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RateTablesTable extends RateTables
    with TableInfo<$RateTablesTable, RateTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RateTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carrierMeta = const VerificationMeta(
    'carrier',
  );
  @override
  late final GeneratedColumn<String> carrier = GeneratedColumn<String>(
    'carrier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceMeta = const VerificationMeta(
    'service',
  );
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
    'service',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseFeeMeta = const VerificationMeta(
    'baseFee',
  );
  @override
  late final GeneratedColumn<double> baseFee = GeneratedColumn<double>(
    'base_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _perKgLowMeta = const VerificationMeta(
    'perKgLow',
  );
  @override
  late final GeneratedColumn<double> perKgLow = GeneratedColumn<double>(
    'per_kg_low',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _perKgHighMeta = const VerificationMeta(
    'perKgHigh',
  );
  @override
  late final GeneratedColumn<double> perKgHigh = GeneratedColumn<double>(
    'per_kg_high',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breakpointKgMeta = const VerificationMeta(
    'breakpointKg',
  );
  @override
  late final GeneratedColumn<double> breakpointKg = GeneratedColumn<double>(
    'breakpoint_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fuelPctMeta = const VerificationMeta(
    'fuelPct',
  );
  @override
  late final GeneratedColumn<double> fuelPct = GeneratedColumn<double>(
    'fuel_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oversizeFeeMeta = const VerificationMeta(
    'oversizeFee',
  );
  @override
  late final GeneratedColumn<double> oversizeFee = GeneratedColumn<double>(
    'oversize_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    carrier,
    service,
    baseFee,
    perKgLow,
    perKgHigh,
    breakpointKg,
    fuelPct,
    oversizeFee,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rate_tables';
  @override
  VerificationContext validateIntegrity(
    Insertable<RateTable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('carrier')) {
      context.handle(
        _carrierMeta,
        carrier.isAcceptableOrUnknown(data['carrier']!, _carrierMeta),
      );
    } else if (isInserting) {
      context.missing(_carrierMeta);
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    } else if (isInserting) {
      context.missing(_serviceMeta);
    }
    if (data.containsKey('base_fee')) {
      context.handle(
        _baseFeeMeta,
        baseFee.isAcceptableOrUnknown(data['base_fee']!, _baseFeeMeta),
      );
    } else if (isInserting) {
      context.missing(_baseFeeMeta);
    }
    if (data.containsKey('per_kg_low')) {
      context.handle(
        _perKgLowMeta,
        perKgLow.isAcceptableOrUnknown(data['per_kg_low']!, _perKgLowMeta),
      );
    } else if (isInserting) {
      context.missing(_perKgLowMeta);
    }
    if (data.containsKey('per_kg_high')) {
      context.handle(
        _perKgHighMeta,
        perKgHigh.isAcceptableOrUnknown(data['per_kg_high']!, _perKgHighMeta),
      );
    } else if (isInserting) {
      context.missing(_perKgHighMeta);
    }
    if (data.containsKey('breakpoint_kg')) {
      context.handle(
        _breakpointKgMeta,
        breakpointKg.isAcceptableOrUnknown(
          data['breakpoint_kg']!,
          _breakpointKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_breakpointKgMeta);
    }
    if (data.containsKey('fuel_pct')) {
      context.handle(
        _fuelPctMeta,
        fuelPct.isAcceptableOrUnknown(data['fuel_pct']!, _fuelPctMeta),
      );
    } else if (isInserting) {
      context.missing(_fuelPctMeta);
    }
    if (data.containsKey('oversize_fee')) {
      context.handle(
        _oversizeFeeMeta,
        oversizeFee.isAcceptableOrUnknown(
          data['oversize_fee']!,
          _oversizeFeeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oversizeFeeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RateTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RateTable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      carrier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}carrier'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      baseFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_fee'],
      )!,
      perKgLow: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}per_kg_low'],
      )!,
      perKgHigh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}per_kg_high'],
      )!,
      breakpointKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}breakpoint_kg'],
      )!,
      fuelPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fuel_pct'],
      )!,
      oversizeFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}oversize_fee'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $RateTablesTable createAlias(String alias) {
    return $RateTablesTable(attachedDatabase, alias);
  }
}

class RateTable extends DataClass implements Insertable<RateTable> {
  final String id;
  final String carrier;
  final String service;
  final double baseFee;
  final double perKgLow;
  final double perKgHigh;
  final double breakpointKg;
  final double fuelPct;
  final double oversizeFee;
  final String? notes;
  const RateTable({
    required this.id,
    required this.carrier,
    required this.service,
    required this.baseFee,
    required this.perKgLow,
    required this.perKgHigh,
    required this.breakpointKg,
    required this.fuelPct,
    required this.oversizeFee,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['carrier'] = Variable<String>(carrier);
    map['service'] = Variable<String>(service);
    map['base_fee'] = Variable<double>(baseFee);
    map['per_kg_low'] = Variable<double>(perKgLow);
    map['per_kg_high'] = Variable<double>(perKgHigh);
    map['breakpoint_kg'] = Variable<double>(breakpointKg);
    map['fuel_pct'] = Variable<double>(fuelPct);
    map['oversize_fee'] = Variable<double>(oversizeFee);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  RateTablesCompanion toCompanion(bool nullToAbsent) {
    return RateTablesCompanion(
      id: Value(id),
      carrier: Value(carrier),
      service: Value(service),
      baseFee: Value(baseFee),
      perKgLow: Value(perKgLow),
      perKgHigh: Value(perKgHigh),
      breakpointKg: Value(breakpointKg),
      fuelPct: Value(fuelPct),
      oversizeFee: Value(oversizeFee),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory RateTable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RateTable(
      id: serializer.fromJson<String>(json['id']),
      carrier: serializer.fromJson<String>(json['carrier']),
      service: serializer.fromJson<String>(json['service']),
      baseFee: serializer.fromJson<double>(json['baseFee']),
      perKgLow: serializer.fromJson<double>(json['perKgLow']),
      perKgHigh: serializer.fromJson<double>(json['perKgHigh']),
      breakpointKg: serializer.fromJson<double>(json['breakpointKg']),
      fuelPct: serializer.fromJson<double>(json['fuelPct']),
      oversizeFee: serializer.fromJson<double>(json['oversizeFee']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'carrier': serializer.toJson<String>(carrier),
      'service': serializer.toJson<String>(service),
      'baseFee': serializer.toJson<double>(baseFee),
      'perKgLow': serializer.toJson<double>(perKgLow),
      'perKgHigh': serializer.toJson<double>(perKgHigh),
      'breakpointKg': serializer.toJson<double>(breakpointKg),
      'fuelPct': serializer.toJson<double>(fuelPct),
      'oversizeFee': serializer.toJson<double>(oversizeFee),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  RateTable copyWith({
    String? id,
    String? carrier,
    String? service,
    double? baseFee,
    double? perKgLow,
    double? perKgHigh,
    double? breakpointKg,
    double? fuelPct,
    double? oversizeFee,
    Value<String?> notes = const Value.absent(),
  }) => RateTable(
    id: id ?? this.id,
    carrier: carrier ?? this.carrier,
    service: service ?? this.service,
    baseFee: baseFee ?? this.baseFee,
    perKgLow: perKgLow ?? this.perKgLow,
    perKgHigh: perKgHigh ?? this.perKgHigh,
    breakpointKg: breakpointKg ?? this.breakpointKg,
    fuelPct: fuelPct ?? this.fuelPct,
    oversizeFee: oversizeFee ?? this.oversizeFee,
    notes: notes.present ? notes.value : this.notes,
  );
  RateTable copyWithCompanion(RateTablesCompanion data) {
    return RateTable(
      id: data.id.present ? data.id.value : this.id,
      carrier: data.carrier.present ? data.carrier.value : this.carrier,
      service: data.service.present ? data.service.value : this.service,
      baseFee: data.baseFee.present ? data.baseFee.value : this.baseFee,
      perKgLow: data.perKgLow.present ? data.perKgLow.value : this.perKgLow,
      perKgHigh: data.perKgHigh.present ? data.perKgHigh.value : this.perKgHigh,
      breakpointKg: data.breakpointKg.present
          ? data.breakpointKg.value
          : this.breakpointKg,
      fuelPct: data.fuelPct.present ? data.fuelPct.value : this.fuelPct,
      oversizeFee: data.oversizeFee.present
          ? data.oversizeFee.value
          : this.oversizeFee,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RateTable(')
          ..write('id: $id, ')
          ..write('carrier: $carrier, ')
          ..write('service: $service, ')
          ..write('baseFee: $baseFee, ')
          ..write('perKgLow: $perKgLow, ')
          ..write('perKgHigh: $perKgHigh, ')
          ..write('breakpointKg: $breakpointKg, ')
          ..write('fuelPct: $fuelPct, ')
          ..write('oversizeFee: $oversizeFee, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    carrier,
    service,
    baseFee,
    perKgLow,
    perKgHigh,
    breakpointKg,
    fuelPct,
    oversizeFee,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RateTable &&
          other.id == this.id &&
          other.carrier == this.carrier &&
          other.service == this.service &&
          other.baseFee == this.baseFee &&
          other.perKgLow == this.perKgLow &&
          other.perKgHigh == this.perKgHigh &&
          other.breakpointKg == this.breakpointKg &&
          other.fuelPct == this.fuelPct &&
          other.oversizeFee == this.oversizeFee &&
          other.notes == this.notes);
}

class RateTablesCompanion extends UpdateCompanion<RateTable> {
  final Value<String> id;
  final Value<String> carrier;
  final Value<String> service;
  final Value<double> baseFee;
  final Value<double> perKgLow;
  final Value<double> perKgHigh;
  final Value<double> breakpointKg;
  final Value<double> fuelPct;
  final Value<double> oversizeFee;
  final Value<String?> notes;
  final Value<int> rowid;
  const RateTablesCompanion({
    this.id = const Value.absent(),
    this.carrier = const Value.absent(),
    this.service = const Value.absent(),
    this.baseFee = const Value.absent(),
    this.perKgLow = const Value.absent(),
    this.perKgHigh = const Value.absent(),
    this.breakpointKg = const Value.absent(),
    this.fuelPct = const Value.absent(),
    this.oversizeFee = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RateTablesCompanion.insert({
    required String id,
    required String carrier,
    required String service,
    required double baseFee,
    required double perKgLow,
    required double perKgHigh,
    required double breakpointKg,
    required double fuelPct,
    required double oversizeFee,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       carrier = Value(carrier),
       service = Value(service),
       baseFee = Value(baseFee),
       perKgLow = Value(perKgLow),
       perKgHigh = Value(perKgHigh),
       breakpointKg = Value(breakpointKg),
       fuelPct = Value(fuelPct),
       oversizeFee = Value(oversizeFee);
  static Insertable<RateTable> custom({
    Expression<String>? id,
    Expression<String>? carrier,
    Expression<String>? service,
    Expression<double>? baseFee,
    Expression<double>? perKgLow,
    Expression<double>? perKgHigh,
    Expression<double>? breakpointKg,
    Expression<double>? fuelPct,
    Expression<double>? oversizeFee,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (carrier != null) 'carrier': carrier,
      if (service != null) 'service': service,
      if (baseFee != null) 'base_fee': baseFee,
      if (perKgLow != null) 'per_kg_low': perKgLow,
      if (perKgHigh != null) 'per_kg_high': perKgHigh,
      if (breakpointKg != null) 'breakpoint_kg': breakpointKg,
      if (fuelPct != null) 'fuel_pct': fuelPct,
      if (oversizeFee != null) 'oversize_fee': oversizeFee,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RateTablesCompanion copyWith({
    Value<String>? id,
    Value<String>? carrier,
    Value<String>? service,
    Value<double>? baseFee,
    Value<double>? perKgLow,
    Value<double>? perKgHigh,
    Value<double>? breakpointKg,
    Value<double>? fuelPct,
    Value<double>? oversizeFee,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return RateTablesCompanion(
      id: id ?? this.id,
      carrier: carrier ?? this.carrier,
      service: service ?? this.service,
      baseFee: baseFee ?? this.baseFee,
      perKgLow: perKgLow ?? this.perKgLow,
      perKgHigh: perKgHigh ?? this.perKgHigh,
      breakpointKg: breakpointKg ?? this.breakpointKg,
      fuelPct: fuelPct ?? this.fuelPct,
      oversizeFee: oversizeFee ?? this.oversizeFee,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (carrier.present) {
      map['carrier'] = Variable<String>(carrier.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (baseFee.present) {
      map['base_fee'] = Variable<double>(baseFee.value);
    }
    if (perKgLow.present) {
      map['per_kg_low'] = Variable<double>(perKgLow.value);
    }
    if (perKgHigh.present) {
      map['per_kg_high'] = Variable<double>(perKgHigh.value);
    }
    if (breakpointKg.present) {
      map['breakpoint_kg'] = Variable<double>(breakpointKg.value);
    }
    if (fuelPct.present) {
      map['fuel_pct'] = Variable<double>(fuelPct.value);
    }
    if (oversizeFee.present) {
      map['oversize_fee'] = Variable<double>(oversizeFee.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RateTablesCompanion(')
          ..write('id: $id, ')
          ..write('carrier: $carrier, ')
          ..write('service: $service, ')
          ..write('baseFee: $baseFee, ')
          ..write('perKgLow: $perKgLow, ')
          ..write('perKgHigh: $perKgHigh, ')
          ..write('breakpointKg: $breakpointKg, ')
          ..write('fuelPct: $fuelPct, ')
          ..write('oversizeFee: $oversizeFee, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuotesTable extends Quotes with TableInfo<$QuotesTable, Quote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shipmentIdMeta = const VerificationMeta(
    'shipmentId',
  );
  @override
  late final GeneratedColumn<String> shipmentId = GeneratedColumn<String>(
    'shipment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shipments (id)',
    ),
  );
  static const VerificationMeta _carrierMeta = const VerificationMeta(
    'carrier',
  );
  @override
  late final GeneratedColumn<String> carrier = GeneratedColumn<String>(
    'carrier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceMeta = const VerificationMeta(
    'service',
  );
  @override
  late final GeneratedColumn<String> service = GeneratedColumn<String>(
    'service',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etaMinMeta = const VerificationMeta('etaMin');
  @override
  late final GeneratedColumn<int> etaMin = GeneratedColumn<int>(
    'eta_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etaMaxMeta = const VerificationMeta('etaMax');
  @override
  late final GeneratedColumn<int> etaMax = GeneratedColumn<int>(
    'eta_max',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceEurMeta = const VerificationMeta(
    'priceEur',
  );
  @override
  late final GeneratedColumn<double> priceEur = GeneratedColumn<double>(
    'price_eur',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargeableKgMeta = const VerificationMeta(
    'chargeableKg',
  );
  @override
  late final GeneratedColumn<double> chargeableKg = GeneratedColumn<double>(
    'chargeable_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shipmentId,
    carrier,
    service,
    etaMin,
    etaMax,
    priceEur,
    chargeableKg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Quote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shipment_id')) {
      context.handle(
        _shipmentIdMeta,
        shipmentId.isAcceptableOrUnknown(data['shipment_id']!, _shipmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shipmentIdMeta);
    }
    if (data.containsKey('carrier')) {
      context.handle(
        _carrierMeta,
        carrier.isAcceptableOrUnknown(data['carrier']!, _carrierMeta),
      );
    } else if (isInserting) {
      context.missing(_carrierMeta);
    }
    if (data.containsKey('service')) {
      context.handle(
        _serviceMeta,
        service.isAcceptableOrUnknown(data['service']!, _serviceMeta),
      );
    } else if (isInserting) {
      context.missing(_serviceMeta);
    }
    if (data.containsKey('eta_min')) {
      context.handle(
        _etaMinMeta,
        etaMin.isAcceptableOrUnknown(data['eta_min']!, _etaMinMeta),
      );
    } else if (isInserting) {
      context.missing(_etaMinMeta);
    }
    if (data.containsKey('eta_max')) {
      context.handle(
        _etaMaxMeta,
        etaMax.isAcceptableOrUnknown(data['eta_max']!, _etaMaxMeta),
      );
    } else if (isInserting) {
      context.missing(_etaMaxMeta);
    }
    if (data.containsKey('price_eur')) {
      context.handle(
        _priceEurMeta,
        priceEur.isAcceptableOrUnknown(data['price_eur']!, _priceEurMeta),
      );
    } else if (isInserting) {
      context.missing(_priceEurMeta);
    }
    if (data.containsKey('chargeable_kg')) {
      context.handle(
        _chargeableKgMeta,
        chargeableKg.isAcceptableOrUnknown(
          data['chargeable_kg']!,
          _chargeableKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chargeableKgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Quote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Quote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shipmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shipment_id'],
      )!,
      carrier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}carrier'],
      )!,
      service: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service'],
      )!,
      etaMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eta_min'],
      )!,
      etaMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eta_max'],
      )!,
      priceEur: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_eur'],
      )!,
      chargeableKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chargeable_kg'],
      )!,
    );
  }

  @override
  $QuotesTable createAlias(String alias) {
    return $QuotesTable(attachedDatabase, alias);
  }
}

class Quote extends DataClass implements Insertable<Quote> {
  final String id;
  final String shipmentId;
  final String carrier;
  final String service;
  final int etaMin;
  final int etaMax;
  final double priceEur;
  final double chargeableKg;
  const Quote({
    required this.id,
    required this.shipmentId,
    required this.carrier,
    required this.service,
    required this.etaMin,
    required this.etaMax,
    required this.priceEur,
    required this.chargeableKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shipment_id'] = Variable<String>(shipmentId);
    map['carrier'] = Variable<String>(carrier);
    map['service'] = Variable<String>(service);
    map['eta_min'] = Variable<int>(etaMin);
    map['eta_max'] = Variable<int>(etaMax);
    map['price_eur'] = Variable<double>(priceEur);
    map['chargeable_kg'] = Variable<double>(chargeableKg);
    return map;
  }

  QuotesCompanion toCompanion(bool nullToAbsent) {
    return QuotesCompanion(
      id: Value(id),
      shipmentId: Value(shipmentId),
      carrier: Value(carrier),
      service: Value(service),
      etaMin: Value(etaMin),
      etaMax: Value(etaMax),
      priceEur: Value(priceEur),
      chargeableKg: Value(chargeableKg),
    );
  }

  factory Quote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Quote(
      id: serializer.fromJson<String>(json['id']),
      shipmentId: serializer.fromJson<String>(json['shipmentId']),
      carrier: serializer.fromJson<String>(json['carrier']),
      service: serializer.fromJson<String>(json['service']),
      etaMin: serializer.fromJson<int>(json['etaMin']),
      etaMax: serializer.fromJson<int>(json['etaMax']),
      priceEur: serializer.fromJson<double>(json['priceEur']),
      chargeableKg: serializer.fromJson<double>(json['chargeableKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shipmentId': serializer.toJson<String>(shipmentId),
      'carrier': serializer.toJson<String>(carrier),
      'service': serializer.toJson<String>(service),
      'etaMin': serializer.toJson<int>(etaMin),
      'etaMax': serializer.toJson<int>(etaMax),
      'priceEur': serializer.toJson<double>(priceEur),
      'chargeableKg': serializer.toJson<double>(chargeableKg),
    };
  }

  Quote copyWith({
    String? id,
    String? shipmentId,
    String? carrier,
    String? service,
    int? etaMin,
    int? etaMax,
    double? priceEur,
    double? chargeableKg,
  }) => Quote(
    id: id ?? this.id,
    shipmentId: shipmentId ?? this.shipmentId,
    carrier: carrier ?? this.carrier,
    service: service ?? this.service,
    etaMin: etaMin ?? this.etaMin,
    etaMax: etaMax ?? this.etaMax,
    priceEur: priceEur ?? this.priceEur,
    chargeableKg: chargeableKg ?? this.chargeableKg,
  );
  Quote copyWithCompanion(QuotesCompanion data) {
    return Quote(
      id: data.id.present ? data.id.value : this.id,
      shipmentId: data.shipmentId.present
          ? data.shipmentId.value
          : this.shipmentId,
      carrier: data.carrier.present ? data.carrier.value : this.carrier,
      service: data.service.present ? data.service.value : this.service,
      etaMin: data.etaMin.present ? data.etaMin.value : this.etaMin,
      etaMax: data.etaMax.present ? data.etaMax.value : this.etaMax,
      priceEur: data.priceEur.present ? data.priceEur.value : this.priceEur,
      chargeableKg: data.chargeableKg.present
          ? data.chargeableKg.value
          : this.chargeableKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quote(')
          ..write('id: $id, ')
          ..write('shipmentId: $shipmentId, ')
          ..write('carrier: $carrier, ')
          ..write('service: $service, ')
          ..write('etaMin: $etaMin, ')
          ..write('etaMax: $etaMax, ')
          ..write('priceEur: $priceEur, ')
          ..write('chargeableKg: $chargeableKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shipmentId,
    carrier,
    service,
    etaMin,
    etaMax,
    priceEur,
    chargeableKg,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quote &&
          other.id == this.id &&
          other.shipmentId == this.shipmentId &&
          other.carrier == this.carrier &&
          other.service == this.service &&
          other.etaMin == this.etaMin &&
          other.etaMax == this.etaMax &&
          other.priceEur == this.priceEur &&
          other.chargeableKg == this.chargeableKg);
}

class QuotesCompanion extends UpdateCompanion<Quote> {
  final Value<String> id;
  final Value<String> shipmentId;
  final Value<String> carrier;
  final Value<String> service;
  final Value<int> etaMin;
  final Value<int> etaMax;
  final Value<double> priceEur;
  final Value<double> chargeableKg;
  final Value<int> rowid;
  const QuotesCompanion({
    this.id = const Value.absent(),
    this.shipmentId = const Value.absent(),
    this.carrier = const Value.absent(),
    this.service = const Value.absent(),
    this.etaMin = const Value.absent(),
    this.etaMax = const Value.absent(),
    this.priceEur = const Value.absent(),
    this.chargeableKg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuotesCompanion.insert({
    required String id,
    required String shipmentId,
    required String carrier,
    required String service,
    required int etaMin,
    required int etaMax,
    required double priceEur,
    required double chargeableKg,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shipmentId = Value(shipmentId),
       carrier = Value(carrier),
       service = Value(service),
       etaMin = Value(etaMin),
       etaMax = Value(etaMax),
       priceEur = Value(priceEur),
       chargeableKg = Value(chargeableKg);
  static Insertable<Quote> custom({
    Expression<String>? id,
    Expression<String>? shipmentId,
    Expression<String>? carrier,
    Expression<String>? service,
    Expression<int>? etaMin,
    Expression<int>? etaMax,
    Expression<double>? priceEur,
    Expression<double>? chargeableKg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shipmentId != null) 'shipment_id': shipmentId,
      if (carrier != null) 'carrier': carrier,
      if (service != null) 'service': service,
      if (etaMin != null) 'eta_min': etaMin,
      if (etaMax != null) 'eta_max': etaMax,
      if (priceEur != null) 'price_eur': priceEur,
      if (chargeableKg != null) 'chargeable_kg': chargeableKg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuotesCompanion copyWith({
    Value<String>? id,
    Value<String>? shipmentId,
    Value<String>? carrier,
    Value<String>? service,
    Value<int>? etaMin,
    Value<int>? etaMax,
    Value<double>? priceEur,
    Value<double>? chargeableKg,
    Value<int>? rowid,
  }) {
    return QuotesCompanion(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      carrier: carrier ?? this.carrier,
      service: service ?? this.service,
      etaMin: etaMin ?? this.etaMin,
      etaMax: etaMax ?? this.etaMax,
      priceEur: priceEur ?? this.priceEur,
      chargeableKg: chargeableKg ?? this.chargeableKg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shipmentId.present) {
      map['shipment_id'] = Variable<String>(shipmentId.value);
    }
    if (carrier.present) {
      map['carrier'] = Variable<String>(carrier.value);
    }
    if (service.present) {
      map['service'] = Variable<String>(service.value);
    }
    if (etaMin.present) {
      map['eta_min'] = Variable<int>(etaMin.value);
    }
    if (etaMax.present) {
      map['eta_max'] = Variable<int>(etaMax.value);
    }
    if (priceEur.present) {
      map['price_eur'] = Variable<double>(priceEur.value);
    }
    if (chargeableKg.present) {
      map['chargeable_kg'] = Variable<double>(chargeableKg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuotesCompanion(')
          ..write('id: $id, ')
          ..write('shipmentId: $shipmentId, ')
          ..write('carrier: $carrier, ')
          ..write('service: $service, ')
          ..write('etaMin: $etaMin, ')
          ..write('etaMax: $etaMax, ')
          ..write('priceEur: $priceEur, ')
          ..write('chargeableKg: $chargeableKg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShipmentsTable shipments = $ShipmentsTable(this);
  late final $CartonsTable cartons = $CartonsTable(this);
  late final $RateTablesTable rateTables = $RateTablesTable(this);
  late final $QuotesTable quotes = $QuotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shipments,
    cartons,
    rateTables,
    quotes,
  ];
}

typedef $$ShipmentsTableCreateCompanionBuilder =
    ShipmentsCompanion Function({
      required String id,
      required DateTime createdAt,
      required String originCity,
      required String originPostal,
      required String destCity,
      required String destPostal,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$ShipmentsTableUpdateCompanionBuilder =
    ShipmentsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String> originCity,
      Value<String> originPostal,
      Value<String> destCity,
      Value<String> destPostal,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$ShipmentsTableReferences
    extends BaseReferences<_$AppDatabase, $ShipmentsTable, Shipment> {
  $$ShipmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CartonsTable, List<Carton>> _cartonsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cartons,
    aliasName: $_aliasNameGenerator(db.shipments.id, db.cartons.shipmentId),
  );

  $$CartonsTableProcessedTableManager get cartonsRefs {
    final manager = $$CartonsTableTableManager(
      $_db,
      $_db.cartons,
    ).filter((f) => f.shipmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cartonsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuotesTable, List<Quote>> _quotesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quotes,
    aliasName: $_aliasNameGenerator(db.shipments.id, db.quotes.shipmentId),
  );

  $$QuotesTableProcessedTableManager get quotesRefs {
    final manager = $$QuotesTableTableManager(
      $_db,
      $_db.quotes,
    ).filter((f) => f.shipmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_quotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShipmentsTableFilterComposer
    extends Composer<_$AppDatabase, $ShipmentsTable> {
  $$ShipmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originCity => $composableBuilder(
    column: $table.originCity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originPostal => $composableBuilder(
    column: $table.originPostal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destCity => $composableBuilder(
    column: $table.destCity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destPostal => $composableBuilder(
    column: $table.destPostal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cartonsRefs(
    Expression<bool> Function($$CartonsTableFilterComposer f) f,
  ) {
    final $$CartonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cartons,
      getReferencedColumn: (t) => t.shipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartonsTableFilterComposer(
            $db: $db,
            $table: $db.cartons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quotesRefs(
    Expression<bool> Function($$QuotesTableFilterComposer f) f,
  ) {
    final $$QuotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.shipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableFilterComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShipmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShipmentsTable> {
  $$ShipmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originCity => $composableBuilder(
    column: $table.originCity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originPostal => $composableBuilder(
    column: $table.originPostal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destCity => $composableBuilder(
    column: $table.destCity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destPostal => $composableBuilder(
    column: $table.destPostal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShipmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShipmentsTable> {
  $$ShipmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get originCity => $composableBuilder(
    column: $table.originCity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originPostal => $composableBuilder(
    column: $table.originPostal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destCity =>
      $composableBuilder(column: $table.destCity, builder: (column) => column);

  GeneratedColumn<String> get destPostal => $composableBuilder(
    column: $table.destPostal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> cartonsRefs<T extends Object>(
    Expression<T> Function($$CartonsTableAnnotationComposer a) f,
  ) {
    final $$CartonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cartons,
      getReferencedColumn: (t) => t.shipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CartonsTableAnnotationComposer(
            $db: $db,
            $table: $db.cartons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> quotesRefs<T extends Object>(
    Expression<T> Function($$QuotesTableAnnotationComposer a) f,
  ) {
    final $$QuotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.shipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableAnnotationComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShipmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShipmentsTable,
          Shipment,
          $$ShipmentsTableFilterComposer,
          $$ShipmentsTableOrderingComposer,
          $$ShipmentsTableAnnotationComposer,
          $$ShipmentsTableCreateCompanionBuilder,
          $$ShipmentsTableUpdateCompanionBuilder,
          (Shipment, $$ShipmentsTableReferences),
          Shipment,
          PrefetchHooks Function({bool cartonsRefs, bool quotesRefs})
        > {
  $$ShipmentsTableTableManager(_$AppDatabase db, $ShipmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShipmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShipmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShipmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> originCity = const Value.absent(),
                Value<String> originPostal = const Value.absent(),
                Value<String> destCity = const Value.absent(),
                Value<String> destPostal = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShipmentsCompanion(
                id: id,
                createdAt: createdAt,
                originCity: originCity,
                originPostal: originPostal,
                destCity: destCity,
                destPostal: destPostal,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required String originCity,
                required String originPostal,
                required String destCity,
                required String destPostal,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShipmentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                originCity: originCity,
                originPostal: originPostal,
                destCity: destCity,
                destPostal: destPostal,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShipmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cartonsRefs = false, quotesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cartonsRefs) db.cartons,
                if (quotesRefs) db.quotes,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cartonsRefs)
                    await $_getPrefetchedData<
                      Shipment,
                      $ShipmentsTable,
                      Carton
                    >(
                      currentTable: table,
                      referencedTable: $$ShipmentsTableReferences
                          ._cartonsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ShipmentsTableReferences(db, table, p0).cartonsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.shipmentId == item.id),
                      typedResults: items,
                    ),
                  if (quotesRefs)
                    await $_getPrefetchedData<Shipment, $ShipmentsTable, Quote>(
                      currentTable: table,
                      referencedTable: $$ShipmentsTableReferences
                          ._quotesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ShipmentsTableReferences(db, table, p0).quotesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.shipmentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShipmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShipmentsTable,
      Shipment,
      $$ShipmentsTableFilterComposer,
      $$ShipmentsTableOrderingComposer,
      $$ShipmentsTableAnnotationComposer,
      $$ShipmentsTableCreateCompanionBuilder,
      $$ShipmentsTableUpdateCompanionBuilder,
      (Shipment, $$ShipmentsTableReferences),
      Shipment,
      PrefetchHooks Function({bool cartonsRefs, bool quotesRefs})
    >;
typedef $$CartonsTableCreateCompanionBuilder =
    CartonsCompanion Function({
      required String id,
      required String shipmentId,
      required double lengthCm,
      required double widthCm,
      required double heightCm,
      required double weightKg,
      required int qty,
      required String itemType,
      Value<int> rowid,
    });
typedef $$CartonsTableUpdateCompanionBuilder =
    CartonsCompanion Function({
      Value<String> id,
      Value<String> shipmentId,
      Value<double> lengthCm,
      Value<double> widthCm,
      Value<double> heightCm,
      Value<double> weightKg,
      Value<int> qty,
      Value<String> itemType,
      Value<int> rowid,
    });

final class $$CartonsTableReferences
    extends BaseReferences<_$AppDatabase, $CartonsTable, Carton> {
  $$CartonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShipmentsTable _shipmentIdTable(_$AppDatabase db) =>
      db.shipments.createAlias(
        $_aliasNameGenerator(db.cartons.shipmentId, db.shipments.id),
      );

  $$ShipmentsTableProcessedTableManager get shipmentId {
    final $_column = $_itemColumn<String>('shipment_id')!;

    final manager = $$ShipmentsTableTableManager(
      $_db,
      $_db.shipments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CartonsTableFilterComposer
    extends Composer<_$AppDatabase, $CartonsTable> {
  $$CartonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get widthCm => $composableBuilder(
    column: $table.widthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  $$ShipmentsTableFilterComposer get shipmentId {
    final $$ShipmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shipmentId,
      referencedTable: $db.shipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShipmentsTableFilterComposer(
            $db: $db,
            $table: $db.shipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CartonsTableOrderingComposer
    extends Composer<_$AppDatabase, $CartonsTable> {
  $$CartonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get widthCm => $composableBuilder(
    column: $table.widthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShipmentsTableOrderingComposer get shipmentId {
    final $$ShipmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shipmentId,
      referencedTable: $db.shipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShipmentsTableOrderingComposer(
            $db: $db,
            $table: $db.shipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CartonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CartonsTable> {
  $$CartonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get lengthCm =>
      $composableBuilder(column: $table.lengthCm, builder: (column) => column);

  GeneratedColumn<double> get widthCm =>
      $composableBuilder(column: $table.widthCm, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  $$ShipmentsTableAnnotationComposer get shipmentId {
    final $$ShipmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shipmentId,
      referencedTable: $db.shipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShipmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.shipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CartonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CartonsTable,
          Carton,
          $$CartonsTableFilterComposer,
          $$CartonsTableOrderingComposer,
          $$CartonsTableAnnotationComposer,
          $$CartonsTableCreateCompanionBuilder,
          $$CartonsTableUpdateCompanionBuilder,
          (Carton, $$CartonsTableReferences),
          Carton,
          PrefetchHooks Function({bool shipmentId})
        > {
  $$CartonsTableTableManager(_$AppDatabase db, $CartonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shipmentId = const Value.absent(),
                Value<double> lengthCm = const Value.absent(),
                Value<double> widthCm = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CartonsCompanion(
                id: id,
                shipmentId: shipmentId,
                lengthCm: lengthCm,
                widthCm: widthCm,
                heightCm: heightCm,
                weightKg: weightKg,
                qty: qty,
                itemType: itemType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shipmentId,
                required double lengthCm,
                required double widthCm,
                required double heightCm,
                required double weightKg,
                required int qty,
                required String itemType,
                Value<int> rowid = const Value.absent(),
              }) => CartonsCompanion.insert(
                id: id,
                shipmentId: shipmentId,
                lengthCm: lengthCm,
                widthCm: widthCm,
                heightCm: heightCm,
                weightKg: weightKg,
                qty: qty,
                itemType: itemType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CartonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shipmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shipmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shipmentId,
                                referencedTable: $$CartonsTableReferences
                                    ._shipmentIdTable(db),
                                referencedColumn: $$CartonsTableReferences
                                    ._shipmentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CartonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CartonsTable,
      Carton,
      $$CartonsTableFilterComposer,
      $$CartonsTableOrderingComposer,
      $$CartonsTableAnnotationComposer,
      $$CartonsTableCreateCompanionBuilder,
      $$CartonsTableUpdateCompanionBuilder,
      (Carton, $$CartonsTableReferences),
      Carton,
      PrefetchHooks Function({bool shipmentId})
    >;
typedef $$RateTablesTableCreateCompanionBuilder =
    RateTablesCompanion Function({
      required String id,
      required String carrier,
      required String service,
      required double baseFee,
      required double perKgLow,
      required double perKgHigh,
      required double breakpointKg,
      required double fuelPct,
      required double oversizeFee,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$RateTablesTableUpdateCompanionBuilder =
    RateTablesCompanion Function({
      Value<String> id,
      Value<String> carrier,
      Value<String> service,
      Value<double> baseFee,
      Value<double> perKgLow,
      Value<double> perKgHigh,
      Value<double> breakpointKg,
      Value<double> fuelPct,
      Value<double> oversizeFee,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$RateTablesTableFilterComposer
    extends Composer<_$AppDatabase, $RateTablesTable> {
  $$RateTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carrier => $composableBuilder(
    column: $table.carrier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baseFee => $composableBuilder(
    column: $table.baseFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get perKgLow => $composableBuilder(
    column: $table.perKgLow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get perKgHigh => $composableBuilder(
    column: $table.perKgHigh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get breakpointKg => $composableBuilder(
    column: $table.breakpointKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fuelPct => $composableBuilder(
    column: $table.fuelPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get oversizeFee => $composableBuilder(
    column: $table.oversizeFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RateTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $RateTablesTable> {
  $$RateTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carrier => $composableBuilder(
    column: $table.carrier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baseFee => $composableBuilder(
    column: $table.baseFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get perKgLow => $composableBuilder(
    column: $table.perKgLow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get perKgHigh => $composableBuilder(
    column: $table.perKgHigh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get breakpointKg => $composableBuilder(
    column: $table.breakpointKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fuelPct => $composableBuilder(
    column: $table.fuelPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get oversizeFee => $composableBuilder(
    column: $table.oversizeFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RateTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RateTablesTable> {
  $$RateTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get carrier =>
      $composableBuilder(column: $table.carrier, builder: (column) => column);

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<double> get baseFee =>
      $composableBuilder(column: $table.baseFee, builder: (column) => column);

  GeneratedColumn<double> get perKgLow =>
      $composableBuilder(column: $table.perKgLow, builder: (column) => column);

  GeneratedColumn<double> get perKgHigh =>
      $composableBuilder(column: $table.perKgHigh, builder: (column) => column);

  GeneratedColumn<double> get breakpointKg => $composableBuilder(
    column: $table.breakpointKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fuelPct =>
      $composableBuilder(column: $table.fuelPct, builder: (column) => column);

  GeneratedColumn<double> get oversizeFee => $composableBuilder(
    column: $table.oversizeFee,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$RateTablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RateTablesTable,
          RateTable,
          $$RateTablesTableFilterComposer,
          $$RateTablesTableOrderingComposer,
          $$RateTablesTableAnnotationComposer,
          $$RateTablesTableCreateCompanionBuilder,
          $$RateTablesTableUpdateCompanionBuilder,
          (
            RateTable,
            BaseReferences<_$AppDatabase, $RateTablesTable, RateTable>,
          ),
          RateTable,
          PrefetchHooks Function()
        > {
  $$RateTablesTableTableManager(_$AppDatabase db, $RateTablesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RateTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RateTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RateTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> carrier = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<double> baseFee = const Value.absent(),
                Value<double> perKgLow = const Value.absent(),
                Value<double> perKgHigh = const Value.absent(),
                Value<double> breakpointKg = const Value.absent(),
                Value<double> fuelPct = const Value.absent(),
                Value<double> oversizeFee = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RateTablesCompanion(
                id: id,
                carrier: carrier,
                service: service,
                baseFee: baseFee,
                perKgLow: perKgLow,
                perKgHigh: perKgHigh,
                breakpointKg: breakpointKg,
                fuelPct: fuelPct,
                oversizeFee: oversizeFee,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String carrier,
                required String service,
                required double baseFee,
                required double perKgLow,
                required double perKgHigh,
                required double breakpointKg,
                required double fuelPct,
                required double oversizeFee,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RateTablesCompanion.insert(
                id: id,
                carrier: carrier,
                service: service,
                baseFee: baseFee,
                perKgLow: perKgLow,
                perKgHigh: perKgHigh,
                breakpointKg: breakpointKg,
                fuelPct: fuelPct,
                oversizeFee: oversizeFee,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RateTablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RateTablesTable,
      RateTable,
      $$RateTablesTableFilterComposer,
      $$RateTablesTableOrderingComposer,
      $$RateTablesTableAnnotationComposer,
      $$RateTablesTableCreateCompanionBuilder,
      $$RateTablesTableUpdateCompanionBuilder,
      (RateTable, BaseReferences<_$AppDatabase, $RateTablesTable, RateTable>),
      RateTable,
      PrefetchHooks Function()
    >;
typedef $$QuotesTableCreateCompanionBuilder =
    QuotesCompanion Function({
      required String id,
      required String shipmentId,
      required String carrier,
      required String service,
      required int etaMin,
      required int etaMax,
      required double priceEur,
      required double chargeableKg,
      Value<int> rowid,
    });
typedef $$QuotesTableUpdateCompanionBuilder =
    QuotesCompanion Function({
      Value<String> id,
      Value<String> shipmentId,
      Value<String> carrier,
      Value<String> service,
      Value<int> etaMin,
      Value<int> etaMax,
      Value<double> priceEur,
      Value<double> chargeableKg,
      Value<int> rowid,
    });

final class $$QuotesTableReferences
    extends BaseReferences<_$AppDatabase, $QuotesTable, Quote> {
  $$QuotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShipmentsTable _shipmentIdTable(_$AppDatabase db) => db.shipments
      .createAlias($_aliasNameGenerator(db.quotes.shipmentId, db.shipments.id));

  $$ShipmentsTableProcessedTableManager get shipmentId {
    final $_column = $_itemColumn<String>('shipment_id')!;

    final manager = $$ShipmentsTableTableManager(
      $_db,
      $_db.shipments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuotesTableFilterComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carrier => $composableBuilder(
    column: $table.carrier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get etaMin => $composableBuilder(
    column: $table.etaMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get etaMax => $composableBuilder(
    column: $table.etaMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priceEur => $composableBuilder(
    column: $table.priceEur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chargeableKg => $composableBuilder(
    column: $table.chargeableKg,
    builder: (column) => ColumnFilters(column),
  );

  $$ShipmentsTableFilterComposer get shipmentId {
    final $$ShipmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shipmentId,
      referencedTable: $db.shipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShipmentsTableFilterComposer(
            $db: $db,
            $table: $db.shipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carrier => $composableBuilder(
    column: $table.carrier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get service => $composableBuilder(
    column: $table.service,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get etaMin => $composableBuilder(
    column: $table.etaMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get etaMax => $composableBuilder(
    column: $table.etaMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priceEur => $composableBuilder(
    column: $table.priceEur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chargeableKg => $composableBuilder(
    column: $table.chargeableKg,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShipmentsTableOrderingComposer get shipmentId {
    final $$ShipmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shipmentId,
      referencedTable: $db.shipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShipmentsTableOrderingComposer(
            $db: $db,
            $table: $db.shipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get carrier =>
      $composableBuilder(column: $table.carrier, builder: (column) => column);

  GeneratedColumn<String> get service =>
      $composableBuilder(column: $table.service, builder: (column) => column);

  GeneratedColumn<int> get etaMin =>
      $composableBuilder(column: $table.etaMin, builder: (column) => column);

  GeneratedColumn<int> get etaMax =>
      $composableBuilder(column: $table.etaMax, builder: (column) => column);

  GeneratedColumn<double> get priceEur =>
      $composableBuilder(column: $table.priceEur, builder: (column) => column);

  GeneratedColumn<double> get chargeableKg => $composableBuilder(
    column: $table.chargeableKg,
    builder: (column) => column,
  );

  $$ShipmentsTableAnnotationComposer get shipmentId {
    final $$ShipmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shipmentId,
      referencedTable: $db.shipments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShipmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.shipments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuotesTable,
          Quote,
          $$QuotesTableFilterComposer,
          $$QuotesTableOrderingComposer,
          $$QuotesTableAnnotationComposer,
          $$QuotesTableCreateCompanionBuilder,
          $$QuotesTableUpdateCompanionBuilder,
          (Quote, $$QuotesTableReferences),
          Quote,
          PrefetchHooks Function({bool shipmentId})
        > {
  $$QuotesTableTableManager(_$AppDatabase db, $QuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shipmentId = const Value.absent(),
                Value<String> carrier = const Value.absent(),
                Value<String> service = const Value.absent(),
                Value<int> etaMin = const Value.absent(),
                Value<int> etaMax = const Value.absent(),
                Value<double> priceEur = const Value.absent(),
                Value<double> chargeableKg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuotesCompanion(
                id: id,
                shipmentId: shipmentId,
                carrier: carrier,
                service: service,
                etaMin: etaMin,
                etaMax: etaMax,
                priceEur: priceEur,
                chargeableKg: chargeableKg,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shipmentId,
                required String carrier,
                required String service,
                required int etaMin,
                required int etaMax,
                required double priceEur,
                required double chargeableKg,
                Value<int> rowid = const Value.absent(),
              }) => QuotesCompanion.insert(
                id: id,
                shipmentId: shipmentId,
                carrier: carrier,
                service: service,
                etaMin: etaMin,
                etaMax: etaMax,
                priceEur: priceEur,
                chargeableKg: chargeableKg,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$QuotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({shipmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shipmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shipmentId,
                                referencedTable: $$QuotesTableReferences
                                    ._shipmentIdTable(db),
                                referencedColumn: $$QuotesTableReferences
                                    ._shipmentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuotesTable,
      Quote,
      $$QuotesTableFilterComposer,
      $$QuotesTableOrderingComposer,
      $$QuotesTableAnnotationComposer,
      $$QuotesTableCreateCompanionBuilder,
      $$QuotesTableUpdateCompanionBuilder,
      (Quote, $$QuotesTableReferences),
      Quote,
      PrefetchHooks Function({bool shipmentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShipmentsTableTableManager get shipments =>
      $$ShipmentsTableTableManager(_db, _db.shipments);
  $$CartonsTableTableManager get cartons =>
      $$CartonsTableTableManager(_db, _db.cartons);
  $$RateTablesTableTableManager get rateTables =>
      $$RateTablesTableTableManager(_db, _db.rateTables);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db, _db.quotes);
}
