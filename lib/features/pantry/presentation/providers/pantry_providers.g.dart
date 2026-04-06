// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pantryStoreServiceHash() =>
    r'e0fd273f5f5445b39465e6b500772efb3c8624e2';

/// See also [pantryStoreService].
@ProviderFor(pantryStoreService)
final pantryStoreServiceProvider = Provider<PantryStoreService>.internal(
  pantryStoreService,
  name: r'pantryStoreServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pantryStoreServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PantryStoreServiceRef = ProviderRef<PantryStoreService>;
String _$pantryItemServiceHash() => r'3bbd8597d3da05775a833dc859bb03703923aa60';

/// See also [pantryItemService].
@ProviderFor(pantryItemService)
final pantryItemServiceProvider = Provider<PantryItemService>.internal(
  pantryItemService,
  name: r'pantryItemServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pantryItemServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PantryItemServiceRef = ProviderRef<PantryItemService>;
String _$pantryStockedServiceHash() =>
    r'1776a1954d3bf0e33803e2555a7fee6ed6c36a84';

/// See also [pantryStockedService].
@ProviderFor(pantryStockedService)
final pantryStockedServiceProvider = Provider<PantryStockedService>.internal(
  pantryStockedService,
  name: r'pantryStockedServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pantryStockedServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PantryStockedServiceRef = ProviderRef<PantryStockedService>;
String _$pantryMealServiceHash() => r'0f8f1b3e5fbc05a198c5fcbb92b5d9f2a918ebe3';

/// See also [pantryMealService].
@ProviderFor(pantryMealService)
final pantryMealServiceProvider = Provider<PantryMealService>.internal(
  pantryMealService,
  name: r'pantryMealServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pantryMealServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PantryMealServiceRef = ProviderRef<PantryMealService>;
String _$pantryMealPlanServiceHash() =>
    r'09d24ff13db7a4ea65156c3fd1226ae4f255f00d';

/// See also [pantryMealPlanService].
@ProviderFor(pantryMealPlanService)
final pantryMealPlanServiceProvider = Provider<PantryMealPlanService>.internal(
  pantryMealPlanService,
  name: r'pantryMealPlanServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pantryMealPlanServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PantryMealPlanServiceRef = ProviderRef<PantryMealPlanService>;
String _$pantryDealServiceHash() => r'f355dbbd86bb143eff7c2710b730b7d8fb87d04a';

/// See also [pantryDealService].
@ProviderFor(pantryDealService)
final pantryDealServiceProvider = Provider<PantryDealService>.internal(
  pantryDealService,
  name: r'pantryDealServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pantryDealServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PantryDealServiceRef = ProviderRef<PantryDealService>;
String _$pantryStoresHash() => r'224e720b3052cd72869e2611cb6f152ad075ba7b';

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

/// See also [pantryStores].
@ProviderFor(pantryStores)
const pantryStoresProvider = PantryStoresFamily();

/// See also [pantryStores].
class PantryStoresFamily extends Family<AsyncValue<List<PantryStore>>> {
  /// See also [pantryStores].
  const PantryStoresFamily();

  /// See also [pantryStores].
  PantryStoresProvider call(String orgId) {
    return PantryStoresProvider(orgId);
  }

  @override
  PantryStoresProvider getProviderOverride(
    covariant PantryStoresProvider provider,
  ) {
    return call(provider.orgId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pantryStoresProvider';
}

/// See also [pantryStores].
class PantryStoresProvider
    extends AutoDisposeStreamProvider<List<PantryStore>> {
  /// See also [pantryStores].
  PantryStoresProvider(String orgId)
    : this._internal(
        (ref) => pantryStores(ref as PantryStoresRef, orgId),
        from: pantryStoresProvider,
        name: r'pantryStoresProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pantryStoresHash,
        dependencies: PantryStoresFamily._dependencies,
        allTransitiveDependencies:
            PantryStoresFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  PantryStoresProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orgId,
  }) : super.internal();

  final String orgId;

  @override
  Override overrideWith(
    Stream<List<PantryStore>> Function(PantryStoresRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PantryStoresProvider._internal(
        (ref) => create(ref as PantryStoresRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orgId: orgId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PantryStore>> createElement() {
    return _PantryStoresProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PantryStoresProvider && other.orgId == orgId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orgId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PantryStoresRef on AutoDisposeStreamProviderRef<List<PantryStore>> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _PantryStoresProviderElement
    extends AutoDisposeStreamProviderElement<List<PantryStore>>
    with PantryStoresRef {
  _PantryStoresProviderElement(super.provider);

  @override
  String get orgId => (origin as PantryStoresProvider).orgId;
}

String _$pantryItemsHash() => r'3d7662a47b9457924be7bfa67bbbd0bf2319c344';

/// See also [pantryItems].
@ProviderFor(pantryItems)
const pantryItemsProvider = PantryItemsFamily();

/// See also [pantryItems].
class PantryItemsFamily extends Family<AsyncValue<List<PantryItem>>> {
  /// See also [pantryItems].
  const PantryItemsFamily();

  /// See also [pantryItems].
  PantryItemsProvider call(String orgId, String storeId) {
    return PantryItemsProvider(orgId, storeId);
  }

  @override
  PantryItemsProvider getProviderOverride(
    covariant PantryItemsProvider provider,
  ) {
    return call(provider.orgId, provider.storeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pantryItemsProvider';
}

/// See also [pantryItems].
class PantryItemsProvider extends AutoDisposeStreamProvider<List<PantryItem>> {
  /// See also [pantryItems].
  PantryItemsProvider(String orgId, String storeId)
    : this._internal(
        (ref) => pantryItems(ref as PantryItemsRef, orgId, storeId),
        from: pantryItemsProvider,
        name: r'pantryItemsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pantryItemsHash,
        dependencies: PantryItemsFamily._dependencies,
        allTransitiveDependencies: PantryItemsFamily._allTransitiveDependencies,
        orgId: orgId,
        storeId: storeId,
      );

  PantryItemsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orgId,
    required this.storeId,
  }) : super.internal();

  final String orgId;
  final String storeId;

  @override
  Override overrideWith(
    Stream<List<PantryItem>> Function(PantryItemsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PantryItemsProvider._internal(
        (ref) => create(ref as PantryItemsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orgId: orgId,
        storeId: storeId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PantryItem>> createElement() {
    return _PantryItemsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PantryItemsProvider &&
        other.orgId == orgId &&
        other.storeId == storeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orgId.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PantryItemsRef on AutoDisposeStreamProviderRef<List<PantryItem>> {
  /// The parameter `orgId` of this provider.
  String get orgId;

  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _PantryItemsProviderElement
    extends AutoDisposeStreamProviderElement<List<PantryItem>>
    with PantryItemsRef {
  _PantryItemsProviderElement(super.provider);

  @override
  String get orgId => (origin as PantryItemsProvider).orgId;
  @override
  String get storeId => (origin as PantryItemsProvider).storeId;
}

String _$pantryStockedHash() => r'7c364b0c58fc9b6a36d6ae7999f98f544654cd81';

/// See also [pantryStocked].
@ProviderFor(pantryStocked)
const pantryStockedProvider = PantryStockedFamily();

/// See also [pantryStocked].
class PantryStockedFamily extends Family<AsyncValue<List<PantryStockedItem>>> {
  /// See also [pantryStocked].
  const PantryStockedFamily();

  /// See also [pantryStocked].
  PantryStockedProvider call(String orgId) {
    return PantryStockedProvider(orgId);
  }

  @override
  PantryStockedProvider getProviderOverride(
    covariant PantryStockedProvider provider,
  ) {
    return call(provider.orgId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pantryStockedProvider';
}

/// See also [pantryStocked].
class PantryStockedProvider
    extends AutoDisposeStreamProvider<List<PantryStockedItem>> {
  /// See also [pantryStocked].
  PantryStockedProvider(String orgId)
    : this._internal(
        (ref) => pantryStocked(ref as PantryStockedRef, orgId),
        from: pantryStockedProvider,
        name: r'pantryStockedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pantryStockedHash,
        dependencies: PantryStockedFamily._dependencies,
        allTransitiveDependencies:
            PantryStockedFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  PantryStockedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orgId,
  }) : super.internal();

  final String orgId;

  @override
  Override overrideWith(
    Stream<List<PantryStockedItem>> Function(PantryStockedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PantryStockedProvider._internal(
        (ref) => create(ref as PantryStockedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orgId: orgId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PantryStockedItem>> createElement() {
    return _PantryStockedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PantryStockedProvider && other.orgId == orgId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orgId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PantryStockedRef
    on AutoDisposeStreamProviderRef<List<PantryStockedItem>> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _PantryStockedProviderElement
    extends AutoDisposeStreamProviderElement<List<PantryStockedItem>>
    with PantryStockedRef {
  _PantryStockedProviderElement(super.provider);

  @override
  String get orgId => (origin as PantryStockedProvider).orgId;
}

String _$pantryMealsHash() => r'9ed90f1afd4131ca737e15f364693f287bf8ab6b';

/// See also [pantryMeals].
@ProviderFor(pantryMeals)
const pantryMealsProvider = PantryMealsFamily();

/// See also [pantryMeals].
class PantryMealsFamily extends Family<AsyncValue<List<PantryMeal>>> {
  /// See also [pantryMeals].
  const PantryMealsFamily();

  /// See also [pantryMeals].
  PantryMealsProvider call(String orgId) {
    return PantryMealsProvider(orgId);
  }

  @override
  PantryMealsProvider getProviderOverride(
    covariant PantryMealsProvider provider,
  ) {
    return call(provider.orgId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pantryMealsProvider';
}

/// See also [pantryMeals].
class PantryMealsProvider extends AutoDisposeStreamProvider<List<PantryMeal>> {
  /// See also [pantryMeals].
  PantryMealsProvider(String orgId)
    : this._internal(
        (ref) => pantryMeals(ref as PantryMealsRef, orgId),
        from: pantryMealsProvider,
        name: r'pantryMealsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pantryMealsHash,
        dependencies: PantryMealsFamily._dependencies,
        allTransitiveDependencies: PantryMealsFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  PantryMealsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orgId,
  }) : super.internal();

  final String orgId;

  @override
  Override overrideWith(
    Stream<List<PantryMeal>> Function(PantryMealsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PantryMealsProvider._internal(
        (ref) => create(ref as PantryMealsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orgId: orgId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PantryMeal>> createElement() {
    return _PantryMealsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PantryMealsProvider && other.orgId == orgId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orgId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PantryMealsRef on AutoDisposeStreamProviderRef<List<PantryMeal>> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _PantryMealsProviderElement
    extends AutoDisposeStreamProviderElement<List<PantryMeal>>
    with PantryMealsRef {
  _PantryMealsProviderElement(super.provider);

  @override
  String get orgId => (origin as PantryMealsProvider).orgId;
}

String _$pantryMealPlanHash() => r'02117aad2a66de5a18ae8a99c9368163335a05f4';

/// See also [pantryMealPlan].
@ProviderFor(pantryMealPlan)
const pantryMealPlanProvider = PantryMealPlanFamily();

/// See also [pantryMealPlan].
class PantryMealPlanFamily
    extends Family<AsyncValue<List<PantryMealPlanEntry>>> {
  /// See also [pantryMealPlan].
  const PantryMealPlanFamily();

  /// See also [pantryMealPlan].
  PantryMealPlanProvider call(String orgId, DateTime weekStart) {
    return PantryMealPlanProvider(orgId, weekStart);
  }

  @override
  PantryMealPlanProvider getProviderOverride(
    covariant PantryMealPlanProvider provider,
  ) {
    return call(provider.orgId, provider.weekStart);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pantryMealPlanProvider';
}

/// See also [pantryMealPlan].
class PantryMealPlanProvider
    extends AutoDisposeStreamProvider<List<PantryMealPlanEntry>> {
  /// See also [pantryMealPlan].
  PantryMealPlanProvider(String orgId, DateTime weekStart)
    : this._internal(
        (ref) => pantryMealPlan(ref as PantryMealPlanRef, orgId, weekStart),
        from: pantryMealPlanProvider,
        name: r'pantryMealPlanProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pantryMealPlanHash,
        dependencies: PantryMealPlanFamily._dependencies,
        allTransitiveDependencies:
            PantryMealPlanFamily._allTransitiveDependencies,
        orgId: orgId,
        weekStart: weekStart,
      );

  PantryMealPlanProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orgId,
    required this.weekStart,
  }) : super.internal();

  final String orgId;
  final DateTime weekStart;

  @override
  Override overrideWith(
    Stream<List<PantryMealPlanEntry>> Function(PantryMealPlanRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PantryMealPlanProvider._internal(
        (ref) => create(ref as PantryMealPlanRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orgId: orgId,
        weekStart: weekStart,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PantryMealPlanEntry>> createElement() {
    return _PantryMealPlanProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PantryMealPlanProvider &&
        other.orgId == orgId &&
        other.weekStart == weekStart;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orgId.hashCode);
    hash = _SystemHash.combine(hash, weekStart.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PantryMealPlanRef
    on AutoDisposeStreamProviderRef<List<PantryMealPlanEntry>> {
  /// The parameter `orgId` of this provider.
  String get orgId;

  /// The parameter `weekStart` of this provider.
  DateTime get weekStart;
}

class _PantryMealPlanProviderElement
    extends AutoDisposeStreamProviderElement<List<PantryMealPlanEntry>>
    with PantryMealPlanRef {
  _PantryMealPlanProviderElement(super.provider);

  @override
  String get orgId => (origin as PantryMealPlanProvider).orgId;
  @override
  DateTime get weekStart => (origin as PantryMealPlanProvider).weekStart;
}

String _$pantryDealsHash() => r'704424c211bc3dfad88cb6a07674034d98044bfe';

/// See also [pantryDeals].
@ProviderFor(pantryDeals)
const pantryDealsProvider = PantryDealsFamily();

/// See also [pantryDeals].
class PantryDealsFamily extends Family<AsyncValue<List<PantryDeal>>> {
  /// See also [pantryDeals].
  const PantryDealsFamily();

  /// See also [pantryDeals].
  PantryDealsProvider call(String orgId) {
    return PantryDealsProvider(orgId);
  }

  @override
  PantryDealsProvider getProviderOverride(
    covariant PantryDealsProvider provider,
  ) {
    return call(provider.orgId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pantryDealsProvider';
}

/// See also [pantryDeals].
class PantryDealsProvider extends AutoDisposeFutureProvider<List<PantryDeal>> {
  /// See also [pantryDeals].
  PantryDealsProvider(String orgId)
    : this._internal(
        (ref) => pantryDeals(ref as PantryDealsRef, orgId),
        from: pantryDealsProvider,
        name: r'pantryDealsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pantryDealsHash,
        dependencies: PantryDealsFamily._dependencies,
        allTransitiveDependencies: PantryDealsFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  PantryDealsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orgId,
  }) : super.internal();

  final String orgId;

  @override
  Override overrideWith(
    FutureOr<List<PantryDeal>> Function(PantryDealsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PantryDealsProvider._internal(
        (ref) => create(ref as PantryDealsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orgId: orgId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PantryDeal>> createElement() {
    return _PantryDealsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PantryDealsProvider && other.orgId == orgId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orgId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PantryDealsRef on AutoDisposeFutureProviderRef<List<PantryDeal>> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _PantryDealsProviderElement
    extends AutoDisposeFutureProviderElement<List<PantryDeal>>
    with PantryDealsRef {
  _PantryDealsProviderElement(super.provider);

  @override
  String get orgId => (origin as PantryDealsProvider).orgId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
