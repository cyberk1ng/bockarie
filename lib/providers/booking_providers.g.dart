// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookShipmentServiceHash() =>
    r'4a7950d0ecdb5cd5df95f913377d98064ad0d35a';

/// Provider for BookShipmentService
///
/// Copied from [bookShipmentService].
@ProviderFor(bookShipmentService)
final bookShipmentServiceProvider =
    AutoDisposeProvider<BookShipmentService>.internal(
      bookShipmentService,
      name: r'bookShipmentServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookShipmentServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookShipmentServiceRef = AutoDisposeProviderRef<BookShipmentService>;
String _$customsProfilesHash() => r'eb4847c364d1b676459eb3f6b5dcb852d9751741';

/// Provider for customs profiles from database
///
/// Copied from [customsProfiles].
@ProviderFor(customsProfiles)
final customsProfilesProvider =
    AutoDisposeFutureProvider<List<models.CustomsProfile>>.internal(
      customsProfiles,
      name: r'customsProfilesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customsProfilesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomsProfilesRef =
    AutoDisposeFutureProviderRef<List<models.CustomsProfile>>;
String _$customsProfileHash() => r'f013c03e27b299c418054988307709e3e83e1b9b';

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

/// Provider for a single customs profile by ID
///
/// Copied from [customsProfile].
@ProviderFor(customsProfile)
const customsProfileProvider = CustomsProfileFamily();

/// Provider for a single customs profile by ID
///
/// Copied from [customsProfile].
class CustomsProfileFamily extends Family<AsyncValue<models.CustomsProfile?>> {
  /// Provider for a single customs profile by ID
  ///
  /// Copied from [customsProfile].
  const CustomsProfileFamily();

  /// Provider for a single customs profile by ID
  ///
  /// Copied from [customsProfile].
  CustomsProfileProvider call(String profileId) {
    return CustomsProfileProvider(profileId);
  }

  @override
  CustomsProfileProvider getProviderOverride(
    covariant CustomsProfileProvider provider,
  ) {
    return call(provider.profileId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'customsProfileProvider';
}

/// Provider for a single customs profile by ID
///
/// Copied from [customsProfile].
class CustomsProfileProvider
    extends AutoDisposeFutureProvider<models.CustomsProfile?> {
  /// Provider for a single customs profile by ID
  ///
  /// Copied from [customsProfile].
  CustomsProfileProvider(String profileId)
    : this._internal(
        (ref) => customsProfile(ref as CustomsProfileRef, profileId),
        from: customsProfileProvider,
        name: r'customsProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customsProfileHash,
        dependencies: CustomsProfileFamily._dependencies,
        allTransitiveDependencies:
            CustomsProfileFamily._allTransitiveDependencies,
        profileId: profileId,
      );

  CustomsProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.profileId,
  }) : super.internal();

  final String profileId;

  @override
  Override overrideWith(
    FutureOr<models.CustomsProfile?> Function(CustomsProfileRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomsProfileProvider._internal(
        (ref) => create(ref as CustomsProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        profileId: profileId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<models.CustomsProfile?> createElement() {
    return _CustomsProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomsProfileProvider && other.profileId == profileId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, profileId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomsProfileRef
    on AutoDisposeFutureProviderRef<models.CustomsProfile?> {
  /// The parameter `profileId` of this provider.
  String get profileId;
}

class _CustomsProfileProviderElement
    extends AutoDisposeFutureProviderElement<models.CustomsProfile?>
    with CustomsProfileRef {
  _CustomsProfileProviderElement(super.provider);

  @override
  String get profileId => (origin as CustomsProfileProvider).profileId;
}

String _$customsPacketHash() => r'005a235722aecea42493b340e92147a5b824ea91';

/// Provider for customs packet by shipment ID
///
/// Copied from [customsPacket].
@ProviderFor(customsPacket)
const customsPacketProvider = CustomsPacketFamily();

/// Provider for customs packet by shipment ID
///
/// Copied from [customsPacket].
class CustomsPacketFamily extends Family<AsyncValue<models.CustomsPacket?>> {
  /// Provider for customs packet by shipment ID
  ///
  /// Copied from [customsPacket].
  const CustomsPacketFamily();

  /// Provider for customs packet by shipment ID
  ///
  /// Copied from [customsPacket].
  CustomsPacketProvider call(String shipmentId) {
    return CustomsPacketProvider(shipmentId);
  }

  @override
  CustomsPacketProvider getProviderOverride(
    covariant CustomsPacketProvider provider,
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
  String? get name => r'customsPacketProvider';
}

/// Provider for customs packet by shipment ID
///
/// Copied from [customsPacket].
class CustomsPacketProvider
    extends AutoDisposeFutureProvider<models.CustomsPacket?> {
  /// Provider for customs packet by shipment ID
  ///
  /// Copied from [customsPacket].
  CustomsPacketProvider(String shipmentId)
    : this._internal(
        (ref) => customsPacket(ref as CustomsPacketRef, shipmentId),
        from: customsPacketProvider,
        name: r'customsPacketProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customsPacketHash,
        dependencies: CustomsPacketFamily._dependencies,
        allTransitiveDependencies:
            CustomsPacketFamily._allTransitiveDependencies,
        shipmentId: shipmentId,
      );

  CustomsPacketProvider._internal(
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
    FutureOr<models.CustomsPacket?> Function(CustomsPacketRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomsPacketProvider._internal(
        (ref) => create(ref as CustomsPacketRef),
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
  AutoDisposeFutureProviderElement<models.CustomsPacket?> createElement() {
    return _CustomsPacketProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomsPacketProvider && other.shipmentId == shipmentId;
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
mixin CustomsPacketRef on AutoDisposeFutureProviderRef<models.CustomsPacket?> {
  /// The parameter `shipmentId` of this provider.
  String get shipmentId;
}

class _CustomsPacketProviderElement
    extends AutoDisposeFutureProviderElement<models.CustomsPacket?>
    with CustomsPacketRef {
  _CustomsPacketProviderElement(super.provider);

  @override
  String get shipmentId => (origin as CustomsPacketProvider).shipmentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
