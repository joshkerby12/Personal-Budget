// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsServiceHash() => r'8acd7f9da1733ab8885213fb3bcf3d2c56733933';

/// See also [settingsService].
@ProviderFor(settingsService)
final settingsServiceProvider = Provider<SettingsService>.internal(
  settingsService,
  name: r'settingsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsServiceRef = ProviderRef<SettingsService>;
String _$settingsInviteServiceHash() =>
    r'238a0aa87e66dbb386d3c119d8cf067c42ac3e8d';

/// See also [settingsInviteService].
@ProviderFor(settingsInviteService)
final settingsInviteServiceProvider = Provider<InviteService>.internal(
  settingsInviteService,
  name: r'settingsInviteServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsInviteServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsInviteServiceRef = ProviderRef<InviteService>;
String _$settingsOrgIdHash() => r'e8ee2e6989216ae7468572356bded2099ffe3b34';

/// See also [settingsOrgId].
@ProviderFor(settingsOrgId)
final settingsOrgIdProvider = AutoDisposeFutureProvider<String?>.internal(
  settingsOrgId,
  name: r'settingsOrgIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsOrgIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsOrgIdRef = AutoDisposeFutureProviderRef<String?>;
String _$inviteCodeHash() => r'61faf0d3409fd7c32071ea910e51588ebc3c5a3e';

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

/// See also [inviteCode].
@ProviderFor(inviteCode)
const inviteCodeProvider = InviteCodeFamily();

/// See also [inviteCode].
class InviteCodeFamily extends Family<AsyncValue<String?>> {
  /// See also [inviteCode].
  const InviteCodeFamily();

  /// See also [inviteCode].
  InviteCodeProvider call(String orgId) {
    return InviteCodeProvider(orgId);
  }

  @override
  InviteCodeProvider getProviderOverride(
    covariant InviteCodeProvider provider,
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
  String? get name => r'inviteCodeProvider';
}

/// See also [inviteCode].
class InviteCodeProvider extends AutoDisposeFutureProvider<String?> {
  /// See also [inviteCode].
  InviteCodeProvider(String orgId)
    : this._internal(
        (ref) => inviteCode(ref as InviteCodeRef, orgId),
        from: inviteCodeProvider,
        name: r'inviteCodeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$inviteCodeHash,
        dependencies: InviteCodeFamily._dependencies,
        allTransitiveDependencies: InviteCodeFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  InviteCodeProvider._internal(
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
    FutureOr<String?> Function(InviteCodeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InviteCodeProvider._internal(
        (ref) => create(ref as InviteCodeRef),
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
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _InviteCodeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InviteCodeProvider && other.orgId == orgId;
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
mixin InviteCodeRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _InviteCodeProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with InviteCodeRef {
  _InviteCodeProviderElement(super.provider);

  @override
  String get orgId => (origin as InviteCodeProvider).orgId;
}

String _$isCurrentUserOwnerHash() =>
    r'7093d045996553f761c98a16c8cef85c0bb91aaa';

/// See also [isCurrentUserOwner].
@ProviderFor(isCurrentUserOwner)
const isCurrentUserOwnerProvider = IsCurrentUserOwnerFamily();

/// See also [isCurrentUserOwner].
class IsCurrentUserOwnerFamily extends Family<AsyncValue<bool>> {
  /// See also [isCurrentUserOwner].
  const IsCurrentUserOwnerFamily();

  /// See also [isCurrentUserOwner].
  IsCurrentUserOwnerProvider call(String orgId) {
    return IsCurrentUserOwnerProvider(orgId);
  }

  @override
  IsCurrentUserOwnerProvider getProviderOverride(
    covariant IsCurrentUserOwnerProvider provider,
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
  String? get name => r'isCurrentUserOwnerProvider';
}

/// See also [isCurrentUserOwner].
class IsCurrentUserOwnerProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [isCurrentUserOwner].
  IsCurrentUserOwnerProvider(String orgId)
    : this._internal(
        (ref) => isCurrentUserOwner(ref as IsCurrentUserOwnerRef, orgId),
        from: isCurrentUserOwnerProvider,
        name: r'isCurrentUserOwnerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isCurrentUserOwnerHash,
        dependencies: IsCurrentUserOwnerFamily._dependencies,
        allTransitiveDependencies:
            IsCurrentUserOwnerFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  IsCurrentUserOwnerProvider._internal(
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
    FutureOr<bool> Function(IsCurrentUserOwnerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsCurrentUserOwnerProvider._internal(
        (ref) => create(ref as IsCurrentUserOwnerRef),
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
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsCurrentUserOwnerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsCurrentUserOwnerProvider && other.orgId == orgId;
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
mixin IsCurrentUserOwnerRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _IsCurrentUserOwnerProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with IsCurrentUserOwnerRef {
  _IsCurrentUserOwnerProviderElement(super.provider);

  @override
  String get orgId => (origin as IsCurrentUserOwnerProvider).orgId;
}

String _$appSettingsHash() => r'5290209a7cef6aeebbe695f8f21dcd2a50afaa91';

/// See also [appSettings].
@ProviderFor(appSettings)
const appSettingsProvider = AppSettingsFamily();

/// See also [appSettings].
class AppSettingsFamily extends Family<AsyncValue<AppSettings?>> {
  /// See also [appSettings].
  const AppSettingsFamily();

  /// See also [appSettings].
  AppSettingsProvider call(String orgId) {
    return AppSettingsProvider(orgId);
  }

  @override
  AppSettingsProvider getProviderOverride(
    covariant AppSettingsProvider provider,
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
  String? get name => r'appSettingsProvider';
}

/// See also [appSettings].
class AppSettingsProvider extends AutoDisposeFutureProvider<AppSettings?> {
  /// See also [appSettings].
  AppSettingsProvider(String orgId)
    : this._internal(
        (ref) => appSettings(ref as AppSettingsRef, orgId),
        from: appSettingsProvider,
        name: r'appSettingsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$appSettingsHash,
        dependencies: AppSettingsFamily._dependencies,
        allTransitiveDependencies: AppSettingsFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  AppSettingsProvider._internal(
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
    FutureOr<AppSettings?> Function(AppSettingsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AppSettingsProvider._internal(
        (ref) => create(ref as AppSettingsRef),
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
  AutoDisposeFutureProviderElement<AppSettings?> createElement() {
    return _AppSettingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettingsProvider && other.orgId == orgId;
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
mixin AppSettingsRef on AutoDisposeFutureProviderRef<AppSettings?> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _AppSettingsProviderElement
    extends AutoDisposeFutureProviderElement<AppSettings?>
    with AppSettingsRef {
  _AppSettingsProviderElement(super.provider);

  @override
  String get orgId => (origin as AppSettingsProvider).orgId;
}

String _$budgetDefaultsHash() => r'fe6960f46f90a0d8d8aeb0822a36fc86745a2665';

/// See also [budgetDefaults].
@ProviderFor(budgetDefaults)
const budgetDefaultsProvider = BudgetDefaultsFamily();

/// See also [budgetDefaults].
class BudgetDefaultsFamily extends Family<AsyncValue<List<BudgetDefault>>> {
  /// See also [budgetDefaults].
  const BudgetDefaultsFamily();

  /// See also [budgetDefaults].
  BudgetDefaultsProvider call(String orgId) {
    return BudgetDefaultsProvider(orgId);
  }

  @override
  BudgetDefaultsProvider getProviderOverride(
    covariant BudgetDefaultsProvider provider,
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
  String? get name => r'budgetDefaultsProvider';
}

/// See also [budgetDefaults].
class BudgetDefaultsProvider extends FutureProvider<List<BudgetDefault>> {
  /// See also [budgetDefaults].
  BudgetDefaultsProvider(String orgId)
    : this._internal(
        (ref) => budgetDefaults(ref as BudgetDefaultsRef, orgId),
        from: budgetDefaultsProvider,
        name: r'budgetDefaultsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$budgetDefaultsHash,
        dependencies: BudgetDefaultsFamily._dependencies,
        allTransitiveDependencies:
            BudgetDefaultsFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  BudgetDefaultsProvider._internal(
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
    FutureOr<List<BudgetDefault>> Function(BudgetDefaultsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BudgetDefaultsProvider._internal(
        (ref) => create(ref as BudgetDefaultsRef),
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
  FutureProviderElement<List<BudgetDefault>> createElement() {
    return _BudgetDefaultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetDefaultsProvider && other.orgId == orgId;
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
mixin BudgetDefaultsRef on FutureProviderRef<List<BudgetDefault>> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _BudgetDefaultsProviderElement
    extends FutureProviderElement<List<BudgetDefault>>
    with BudgetDefaultsRef {
  _BudgetDefaultsProviderElement(super.provider);

  @override
  String get orgId => (origin as BudgetDefaultsProvider).orgId;
}

String _$spendingAveragesHash() => r'95d0ccbc44626160438e20fc79d83317e124f772';

/// Returns a map of category → subcategory → average monthly spend
/// based on the last 3 complete calendar months.
///
/// Copied from [spendingAverages].
@ProviderFor(spendingAverages)
const spendingAveragesProvider = SpendingAveragesFamily();

/// Returns a map of category → subcategory → average monthly spend
/// based on the last 3 complete calendar months.
///
/// Copied from [spendingAverages].
class SpendingAveragesFamily
    extends Family<AsyncValue<Map<String, Map<String, double>>>> {
  /// Returns a map of category → subcategory → average monthly spend
  /// based on the last 3 complete calendar months.
  ///
  /// Copied from [spendingAverages].
  const SpendingAveragesFamily();

  /// Returns a map of category → subcategory → average monthly spend
  /// based on the last 3 complete calendar months.
  ///
  /// Copied from [spendingAverages].
  SpendingAveragesProvider call(String orgId) {
    return SpendingAveragesProvider(orgId);
  }

  @override
  SpendingAveragesProvider getProviderOverride(
    covariant SpendingAveragesProvider provider,
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
  String? get name => r'spendingAveragesProvider';
}

/// Returns a map of category → subcategory → average monthly spend
/// based on the last 3 complete calendar months.
///
/// Copied from [spendingAverages].
class SpendingAveragesProvider
    extends AutoDisposeFutureProvider<Map<String, Map<String, double>>> {
  /// Returns a map of category → subcategory → average monthly spend
  /// based on the last 3 complete calendar months.
  ///
  /// Copied from [spendingAverages].
  SpendingAveragesProvider(String orgId)
    : this._internal(
        (ref) => spendingAverages(ref as SpendingAveragesRef, orgId),
        from: spendingAveragesProvider,
        name: r'spendingAveragesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$spendingAveragesHash,
        dependencies: SpendingAveragesFamily._dependencies,
        allTransitiveDependencies:
            SpendingAveragesFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  SpendingAveragesProvider._internal(
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
    FutureOr<Map<String, Map<String, double>>> Function(
      SpendingAveragesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SpendingAveragesProvider._internal(
        (ref) => create(ref as SpendingAveragesRef),
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
  AutoDisposeFutureProviderElement<Map<String, Map<String, double>>>
  createElement() {
    return _SpendingAveragesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SpendingAveragesProvider && other.orgId == orgId;
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
mixin SpendingAveragesRef
    on AutoDisposeFutureProviderRef<Map<String, Map<String, double>>> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _SpendingAveragesProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, Map<String, double>>>
    with SpendingAveragesRef {
  _SpendingAveragesProviderElement(super.provider);

  @override
  String get orgId => (origin as SpendingAveragesProvider).orgId;
}

String _$settingsControllerHash() =>
    r'daaee8fdb7cc96d9a9b621d6686948dfa6db9c81';

/// See also [SettingsController].
@ProviderFor(SettingsController)
final settingsControllerProvider =
    AutoDisposeNotifierProvider<SettingsController, AsyncValue<void>>.internal(
      SettingsController.new,
      name: r'settingsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettingsController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
