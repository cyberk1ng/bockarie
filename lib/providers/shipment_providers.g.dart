// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'ee09cc2018ceb262a8954514869979a571d5f4d7';

/// Provider for accessing the database
///
/// Copied from [database].
@ProviderFor(database)
final databaseProvider = AutoDisposeProvider<AppDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseRef = AutoDisposeProviderRef<AppDatabase>;
String _$shipmentHash() => r'3a9bf5f984c38279a83c39cf20cceca33b38452a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for fetching a single shipment by ID
///
/// Copied from [shipment].
@ProviderFor(shipment)
const shipmentProvider = ShipmentFamily();

/// Provider for fetching a single shipment by ID
///
/// Copied from [shipment].
class ShipmentFamily extends Family<AsyncValue<Shipment>> {
  /// Provider for fetching a single shipment by ID
  ///
  /// Copied from [shipment].
  const ShipmentFamily();

  /// Provider for fetching a single shipment by ID
  ///
  /// Copied from [shipment].
  ShipmentProvider call(String shipmentId) {
    return ShipmentProvider(shipmentId);
  }

  @override
  ShipmentProvider getProviderOverride(covariant ShipmentProvider provider) {
    return call(provider.shipmentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'shipmentProvider';
}

/// Provider for fetching a single shipment by ID
///
/// Copied from [shipment].
class ShipmentProvider extends AutoDisposeFutureProvider<Shipment> {
  /// Provider for fetching a single shipment by ID
  ///
  /// Copied from [shipment].
  ShipmentProvider(String shipmentId)
    : this._internal(
        (ref) => shipment(ref as ShipmentRef, shipmentId),
        from: shipmentProvider,
        name: r'shipmentProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$shipmentHash,
        dependencies: ShipmentFamily._dependencies,
        allTransitiveDependencies: ShipmentFamily._allTransitiveDependencies,
        shipmentId: shipmentId,
      );

  ShipmentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shipmentId,
  }) : super.internal();

  final String shipmentId;

  @override
  Override overrideWith(
    FutureOr<Shipment> Function(ShipmentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShipmentProvider._internal(
        (ref) => create(ref as ShipmentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shipmentId: shipmentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Shipment> createElement() {
    return _ShipmentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShipmentProvider && other.shipmentId == shipmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shipmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShipmentRef on AutoDisposeFutureProviderRef<Shipment> {
  /// The parameter `shipmentId` of this provider.
  String get shipmentId;
}

class _ShipmentProviderElement
    extends AutoDisposeFutureProviderElement<Shipment>
    with ShipmentRef {
  _ShipmentProviderElement(super.provider);

  @override
  String get shipmentId => (origin as ShipmentProvider).shipmentId;
}

String _$cartonsHash() => r'de25438b7e633723ed1c5388ada2ec7c8e29526c';

/// Provider for fetching all cartons for a shipment
///
/// Copied from [cartons].
@ProviderFor(cartons)
const cartonsProvider = CartonsFamily();

/// Provider for fetching all cartons for a shipment
///
/// Copied from [cartons].
class CartonsFamily extends Family<AsyncValue<List<Carton>>> {
  /// Provider for fetching all cartons for a shipment
  ///
  /// Copied from [cartons].
  const CartonsFamily();

  /// Provider for fetching all cartons for a shipment
  ///
  /// Copied from [cartons].
  CartonsProvider call(String shipmentId) {
    return CartonsProvider(shipmentId);
  }

  @override
  CartonsProvider getProviderOverride(covariant CartonsProvider provider) {
    return call(provider.shipmentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cartonsProvider';
}

/// Provider for fetching all cartons for a shipment
///
/// Copied from [cartons].
class CartonsProvider extends AutoDisposeFutureProvider<List<Carton>> {
  /// Provider for fetching all cartons for a shipment
  ///
  /// Copied from [cartons].
  CartonsProvider(String shipmentId)
    : this._internal(
        (ref) => cartons(ref as CartonsRef, shipmentId),
        from: cartonsProvider,
        name: r'cartonsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cartonsHash,
        dependencies: CartonsFamily._dependencies,
        allTransitiveDependencies: CartonsFamily._allTransitiveDependencies,
        shipmentId: shipmentId,
      );

  CartonsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shipmentId,
  }) : super.internal();

  final String shipmentId;

  @override
  Override overrideWith(
    FutureOr<List<Carton>> Function(CartonsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CartonsProvider._internal(
        (ref) => create(ref as CartonsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shipmentId: shipmentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Carton>> createElement() {
    return _CartonsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CartonsProvider && other.shipmentId == shipmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shipmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CartonsRef on AutoDisposeFutureProviderRef<List<Carton>> {
  /// The parameter `shipmentId` of this provider.
  String get shipmentId;
}

class _CartonsProviderElement
    extends AutoDisposeFutureProviderElement<List<Carton>>
    with CartonsRef {
  _CartonsProviderElement(super.provider);

  @override
  String get shipmentId => (origin as CartonsProvider).shipmentId;
}

String _$cartonModelsHash() => r'9931c74a15c957c5508a64a7081d0a248bb403a6';

/// Provider for fetching cartons as models (for calculations)
///
/// Copied from [cartonModels].
@ProviderFor(cartonModels)
const cartonModelsProvider = CartonModelsFamily();

/// Provider for fetching cartons as models (for calculations)
///
/// Copied from [cartonModels].
class CartonModelsFamily extends Family<AsyncValue<List<models.Carton>>> {
  /// Provider for fetching cartons as models (for calculations)
  ///
  /// Copied from [cartonModels].
  const CartonModelsFamily();

  /// Provider for fetching cartons as models (for calculations)
  ///
  /// Copied from [cartonModels].
  CartonModelsProvider call(String shipmentId) {
    return CartonModelsProvider(shipmentId);
  }

  @override
  CartonModelsProvider getProviderOverride(
    covariant CartonModelsProvider provider,
  ) {
    return call(provider.shipmentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cartonModelsProvider';
}

/// Provider for fetching cartons as models (for calculations)
///
/// Copied from [cartonModels].
class CartonModelsProvider
    extends AutoDisposeFutureProvider<List<models.Carton>> {
  /// Provider for fetching cartons as models (for calculations)
  ///
  /// Copied from [cartonModels].
  CartonModelsProvider(String shipmentId)
    : this._internal(
        (ref) => cartonModels(ref as CartonModelsRef, shipmentId),
        from: cartonModelsProvider,
        name: r'cartonModelsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cartonModelsHash,
        dependencies: CartonModelsFamily._dependencies,
        allTransitiveDependencies:
            CartonModelsFamily._allTransitiveDependencies,
        shipmentId: shipmentId,
      );

  CartonModelsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shipmentId,
  }) : super.internal();

  final String shipmentId;

  @override
  Override overrideWith(
    FutureOr<List<models.Carton>> Function(CartonModelsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CartonModelsProvider._internal(
        (ref) => create(ref as CartonModelsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shipmentId: shipmentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<models.Carton>> createElement() {
    return _CartonModelsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CartonModelsProvider && other.shipmentId == shipmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shipmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CartonModelsRef on AutoDisposeFutureProviderRef<List<models.Carton>> {
  /// The parameter `shipmentId` of this provider.
  String get shipmentId;
}

class _CartonModelsProviderElement
    extends AutoDisposeFutureProviderElement<List<models.Carton>>
    with CartonModelsRef {
  _CartonModelsProviderElement(super.provider);

  @override
  String get shipmentId => (origin as CartonModelsProvider).shipmentId;
}

String _$quotesHash() => r'c4e50c8fb3fd9ff7bed44b1f3bb8dadae9e3dfb4';

/// Provider for fetching all quotes for a shipment
///
/// Copied from [quotes].
@ProviderFor(quotes)
const quotesProvider = QuotesFamily();

/// Provider for fetching all quotes for a shipment
///
/// Copied from [quotes].
class QuotesFamily extends Family<AsyncValue<List<Quote>>> {
  /// Provider for fetching all quotes for a shipment
  ///
  /// Copied from [quotes].
  const QuotesFamily();

  /// Provider for fetching all quotes for a shipment
  ///
  /// Copied from [quotes].
  QuotesProvider call(String shipmentId) {
    return QuotesProvider(shipmentId);
  }

  @override
  QuotesProvider getProviderOverride(covariant QuotesProvider provider) {
    return call(provider.shipmentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'quotesProvider';
}

/// Provider for fetching all quotes for a shipment
///
/// Copied from [quotes].
class QuotesProvider extends AutoDisposeStreamProvider<List<Quote>> {
  /// Provider for fetching all quotes for a shipment
  ///
  /// Copied from [quotes].
  QuotesProvider(String shipmentId)
    : this._internal(
        (ref) => quotes(ref as QuotesRef, shipmentId),
        from: quotesProvider,
        name: r'quotesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$quotesHash,
        dependencies: QuotesFamily._dependencies,
        allTransitiveDependencies: QuotesFamily._allTransitiveDependencies,
        shipmentId: shipmentId,
      );

  QuotesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shipmentId,
  }) : super.internal();

  final String shipmentId;

  @override
  Override overrideWith(
    Stream<List<Quote>> Function(QuotesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuotesProvider._internal(
        (ref) => create(ref as QuotesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shipmentId: shipmentId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Quote>> createElement() {
    return _QuotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuotesProvider && other.shipmentId == shipmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shipmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuotesRef on AutoDisposeStreamProviderRef<List<Quote>> {
  /// The parameter `shipmentId` of this provider.
  String get shipmentId;
}

class _QuotesProviderElement
    extends AutoDisposeStreamProviderElement<List<Quote>>
    with QuotesRef {
  _QuotesProviderElement(super.provider);

  @override
  String get shipmentId => (origin as QuotesProvider).shipmentId;
}

String _$recentShipmentsHash() => r'0155d9e2282065e53dc1f8b2288947b8f338d9c5';

/// Provider for fetching recent shipments (for home page)
///
/// Copied from [recentShipments].
@ProviderFor(recentShipments)
final recentShipmentsProvider =
    AutoDisposeStreamProvider<List<Shipment>>.internal(
      recentShipments,
      name: r'recentShipmentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentShipmentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentShipmentsRef = AutoDisposeStreamProviderRef<List<Shipment>>;
String _$cheapestQuoteHash() => r'060a572b6a551bde020bf4e4327bdd79311dd3e4';

/// Provider for cheapest quote for a shipment
///
/// Copied from [cheapestQuote].
@ProviderFor(cheapestQuote)
const cheapestQuoteProvider = CheapestQuoteFamily();

/// Provider for cheapest quote for a shipment
///
/// Copied from [cheapestQuote].
class CheapestQuoteFamily extends Family<AsyncValue<Quote?>> {
  /// Provider for cheapest quote for a shipment
  ///
  /// Copied from [cheapestQuote].
  const CheapestQuoteFamily();

  /// Provider for cheapest quote for a shipment
  ///
  /// Copied from [cheapestQuote].
  CheapestQuoteProvider call(String shipmentId) {
    return CheapestQuoteProvider(shipmentId);
  }

  @override
  CheapestQuoteProvider getProviderOverride(
    covariant CheapestQuoteProvider provider,
  ) {
    return call(provider.shipmentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cheapestQuoteProvider';
}

/// Provider for cheapest quote for a shipment
///
/// Copied from [cheapestQuote].
class CheapestQuoteProvider extends AutoDisposeFutureProvider<Quote?> {
  /// Provider for cheapest quote for a shipment
  ///
  /// Copied from [cheapestQuote].
  CheapestQuoteProvider(String shipmentId)
    : this._internal(
        (ref) => cheapestQuote(ref as CheapestQuoteRef, shipmentId),
        from: cheapestQuoteProvider,
        name: r'cheapestQuoteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cheapestQuoteHash,
        dependencies: CheapestQuoteFamily._dependencies,
        allTransitiveDependencies:
            CheapestQuoteFamily._allTransitiveDependencies,
        shipmentId: shipmentId,
      );

  CheapestQuoteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shipmentId,
  }) : super.internal();

  final String shipmentId;

  @override
  Override overrideWith(
    FutureOr<Quote?> Function(CheapestQuoteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CheapestQuoteProvider._internal(
        (ref) => create(ref as CheapestQuoteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shipmentId: shipmentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Quote?> createElement() {
    return _CheapestQuoteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CheapestQuoteProvider && other.shipmentId == shipmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shipmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CheapestQuoteRef on AutoDisposeFutureProviderRef<Quote?> {
  /// The parameter `shipmentId` of this provider.
  String get shipmentId;
}

class _CheapestQuoteProviderElement
    extends AutoDisposeFutureProviderElement<Quote?>
    with CheapestQuoteRef {
  _CheapestQuoteProviderElement(super.provider);

  @override
  String get shipmentId => (origin as CheapestQuoteProvider).shipmentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
