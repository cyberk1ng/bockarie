// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currencyRepositoryHash() =>
    r'6cf8aed8ef4bd3e1dd55821e11bbae8a4613b7ab';

/// Provider for CurrencyRepository - must be overridden in tests
///
/// Copied from [currencyRepository].
@ProviderFor(currencyRepository)
final currencyRepositoryProvider =
    AutoDisposeProvider<CurrencyRepository>.internal(
      currencyRepository,
      name: r'currencyRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currencyRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrencyRepositoryRef = AutoDisposeProviderRef<CurrencyRepository>;
String _$currencyServiceHash() => r'270dc9d29d1ba050130107b38169df699371efa6';

/// Provider for currency service
///
/// Copied from [currencyService].
@ProviderFor(currencyService)
final currencyServiceProvider = AutoDisposeProvider<CurrencyService>.internal(
  currencyService,
  name: r'currencyServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currencyServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrencyServiceRef = AutoDisposeProviderRef<CurrencyService>;
String _$formatCurrencyHash() => r'2de96254a64e11b4524574a2b5566534155e1619';

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

/// Helper provider to format amounts in current currency
///
/// Copied from [formatCurrency].
@ProviderFor(formatCurrency)
const formatCurrencyProvider = FormatCurrencyFamily();

/// Helper provider to format amounts in current currency
///
/// Copied from [formatCurrency].
class FormatCurrencyFamily extends Family<String> {
  /// Helper provider to format amounts in current currency
  ///
  /// Copied from [formatCurrency].
  const FormatCurrencyFamily();

  /// Helper provider to format amounts in current currency
  ///
  /// Copied from [formatCurrency].
  FormatCurrencyProvider call(double amountInEur, {int decimals = 2}) {
    return FormatCurrencyProvider(amountInEur, decimals: decimals);
  }

  @override
  FormatCurrencyProvider getProviderOverride(
    covariant FormatCurrencyProvider provider,
  ) {
    return call(provider.amountInEur, decimals: provider.decimals);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'formatCurrencyProvider';
}

/// Helper provider to format amounts in current currency
///
/// Copied from [formatCurrency].
class FormatCurrencyProvider extends AutoDisposeProvider<String> {
  /// Helper provider to format amounts in current currency
  ///
  /// Copied from [formatCurrency].
  FormatCurrencyProvider(double amountInEur, {int decimals = 2})
    : this._internal(
        (ref) => formatCurrency(
          ref as FormatCurrencyRef,
          amountInEur,
          decimals: decimals,
        ),
        from: formatCurrencyProvider,
        name: r'formatCurrencyProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$formatCurrencyHash,
        dependencies: FormatCurrencyFamily._dependencies,
        allTransitiveDependencies:
            FormatCurrencyFamily._allTransitiveDependencies,
        amountInEur: amountInEur,
        decimals: decimals,
      );

  FormatCurrencyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.amountInEur,
    required this.decimals,
  }) : super.internal();

  final double amountInEur;
  final int decimals;

  @override
  Override overrideWith(String Function(FormatCurrencyRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: FormatCurrencyProvider._internal(
        (ref) => create(ref as FormatCurrencyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        amountInEur: amountInEur,
        decimals: decimals,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _FormatCurrencyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FormatCurrencyProvider &&
        other.amountInEur == amountInEur &&
        other.decimals == decimals;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, amountInEur.hashCode);
    hash = _SystemHash.combine(hash, decimals.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FormatCurrencyRef on AutoDisposeProviderRef<String> {
  /// The parameter `amountInEur` of this provider.
  double get amountInEur;

  /// The parameter `decimals` of this provider.
  int get decimals;
}

class _FormatCurrencyProviderElement extends AutoDisposeProviderElement<String>
    with FormatCurrencyRef {
  _FormatCurrencyProviderElement(super.provider);

  @override
  double get amountInEur => (origin as FormatCurrencyProvider).amountInEur;
  @override
  int get decimals => (origin as FormatCurrencyProvider).decimals;
}

String _$currencyNotifierHash() => r'85dcfaa80715b36bf1ce92c06e9ffca123b9c4e1';

/// See also [CurrencyNotifier].
@ProviderFor(CurrencyNotifier)
final currencyNotifierProvider =
    AutoDisposeNotifierProvider<CurrencyNotifier, SupportedCurrency>.internal(
      CurrencyNotifier.new,
      name: r'currencyNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currencyNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrencyNotifier = AutoDisposeNotifier<SupportedCurrency>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
