// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyOrgIdHash() => r'4ed10583b63180443dc5733b0c30442a3591a8db';

/// See also [monthlyOrgId].
@ProviderFor(monthlyOrgId)
final monthlyOrgIdProvider = AutoDisposeFutureProvider<String?>.internal(
  monthlyOrgId,
  name: r'monthlyOrgIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyOrgIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyOrgIdRef = AutoDisposeFutureProviderRef<String?>;
String _$monthlyBudgetDataHash() => r'79cd98105f6f0fef43e7006775cb0cc2464aa0c4';

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

/// See also [monthlyBudgetData].
@ProviderFor(monthlyBudgetData)
const monthlyBudgetDataProvider = MonthlyBudgetDataFamily();

/// See also [monthlyBudgetData].
class MonthlyBudgetDataFamily extends Family<AsyncValue<MonthlyBudgetData>> {
  /// See also [monthlyBudgetData].
  const MonthlyBudgetDataFamily();

  /// See also [monthlyBudgetData].
  MonthlyBudgetDataProvider call(String orgId, int year, int month) {
    return MonthlyBudgetDataProvider(orgId, year, month);
  }

  @override
  MonthlyBudgetDataProvider getProviderOverride(
    covariant MonthlyBudgetDataProvider provider,
  ) {
    return call(provider.orgId, provider.year, provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlyBudgetDataProvider';
}

/// See also [monthlyBudgetData].
class MonthlyBudgetDataProvider
    extends AutoDisposeFutureProvider<MonthlyBudgetData> {
  /// See also [monthlyBudgetData].
  MonthlyBudgetDataProvider(String orgId, int year, int month)
    : this._internal(
        (ref) =>
            monthlyBudgetData(ref as MonthlyBudgetDataRef, orgId, year, month),
        from: monthlyBudgetDataProvider,
        name: r'monthlyBudgetDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$monthlyBudgetDataHash,
        dependencies: MonthlyBudgetDataFamily._dependencies,
        allTransitiveDependencies:
            MonthlyBudgetDataFamily._allTransitiveDependencies,
        orgId: orgId,
        year: year,
        month: month,
      );

  MonthlyBudgetDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orgId,
    required this.year,
    required this.month,
  }) : super.internal();

  final String orgId;
  final int year;
  final int month;

  @override
  Override overrideWith(
    FutureOr<MonthlyBudgetData> Function(MonthlyBudgetDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyBudgetDataProvider._internal(
        (ref) => create(ref as MonthlyBudgetDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orgId: orgId,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MonthlyBudgetData> createElement() {
    return _MonthlyBudgetDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyBudgetDataProvider &&
        other.orgId == orgId &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orgId.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlyBudgetDataRef on AutoDisposeFutureProviderRef<MonthlyBudgetData> {
  /// The parameter `orgId` of this provider.
  String get orgId;

  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _MonthlyBudgetDataProviderElement
    extends AutoDisposeFutureProviderElement<MonthlyBudgetData>
    with MonthlyBudgetDataRef {
  _MonthlyBudgetDataProviderElement(super.provider);

  @override
  String get orgId => (origin as MonthlyBudgetDataProvider).orgId;
  @override
  int get year => (origin as MonthlyBudgetDataProvider).year;
  @override
  int get month => (origin as MonthlyBudgetDataProvider).month;
}

String _$monthlyControllerHash() => r'e95b2fee79ac90b0c805a8be101e2d77bd461fbd';

/// See also [MonthlyController].
@ProviderFor(MonthlyController)
final monthlyControllerProvider =
    AutoDisposeNotifierProvider<MonthlyController, AsyncValue<void>>.internal(
      MonthlyController.new,
      name: r'monthlyControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$monthlyControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MonthlyController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
