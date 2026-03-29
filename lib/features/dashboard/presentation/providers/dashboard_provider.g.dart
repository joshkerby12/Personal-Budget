// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardOrgIdHash() => r'1cc77dd14ec7d4aa2d9c5c2b0f7b7f27b3d8410e';

/// See also [dashboardOrgId].
@ProviderFor(dashboardOrgId)
final dashboardOrgIdProvider = AutoDisposeFutureProvider<String?>.internal(
  dashboardOrgId,
  name: r'dashboardOrgIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardOrgIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardOrgIdRef = AutoDisposeFutureProviderRef<String?>;
String _$dashboardSummaryHash() => r'28dc103c27fc10f1ed44aeba6d71edd7d07ba4ca';

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

/// See also [dashboardSummary].
@ProviderFor(dashboardSummary)
const dashboardSummaryProvider = DashboardSummaryFamily();

/// See also [dashboardSummary].
class DashboardSummaryFamily extends Family<AsyncValue<DashboardSummary>> {
  /// See also [dashboardSummary].
  const DashboardSummaryFamily();

  /// See also [dashboardSummary].
  DashboardSummaryProvider call(String orgId, DashboardRange range) {
    return DashboardSummaryProvider(orgId, range);
  }

  @override
  DashboardSummaryProvider getProviderOverride(
    covariant DashboardSummaryProvider provider,
  ) {
    return call(provider.orgId, provider.range);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dashboardSummaryProvider';
}

/// See also [dashboardSummary].
class DashboardSummaryProvider
    extends AutoDisposeFutureProvider<DashboardSummary> {
  /// See also [dashboardSummary].
  DashboardSummaryProvider(String orgId, DashboardRange range)
    : this._internal(
        (ref) => dashboardSummary(ref as DashboardSummaryRef, orgId, range),
        from: dashboardSummaryProvider,
        name: r'dashboardSummaryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dashboardSummaryHash,
        dependencies: DashboardSummaryFamily._dependencies,
        allTransitiveDependencies:
            DashboardSummaryFamily._allTransitiveDependencies,
        orgId: orgId,
        range: range,
      );

  DashboardSummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orgId,
    required this.range,
  }) : super.internal();

  final String orgId;
  final DashboardRange range;

  @override
  Override overrideWith(
    FutureOr<DashboardSummary> Function(DashboardSummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DashboardSummaryProvider._internal(
        (ref) => create(ref as DashboardSummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orgId: orgId,
        range: range,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DashboardSummary> createElement() {
    return _DashboardSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardSummaryProvider &&
        other.orgId == orgId &&
        other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orgId.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DashboardSummaryRef on AutoDisposeFutureProviderRef<DashboardSummary> {
  /// The parameter `orgId` of this provider.
  String get orgId;

  /// The parameter `range` of this provider.
  DashboardRange get range;
}

class _DashboardSummaryProviderElement
    extends AutoDisposeFutureProviderElement<DashboardSummary>
    with DashboardSummaryRef {
  _DashboardSummaryProviderElement(super.provider);

  @override
  String get orgId => (origin as DashboardSummaryProvider).orgId;
  @override
  DashboardRange get range => (origin as DashboardSummaryProvider).range;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
