// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$businessOrgIdHash() => r'deda703045cd05d508d581329e6a6f754bd32467';

/// See also [businessOrgId].
@ProviderFor(businessOrgId)
final businessOrgIdProvider = AutoDisposeFutureProvider<String?>.internal(
  businessOrgId,
  name: r'businessOrgIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$businessOrgIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusinessOrgIdRef = AutoDisposeFutureProviderRef<String?>;
String _$businessSummaryHash() => r'd26160882e6169c6c383d7f14ce372ee56c21151';

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

/// See also [businessSummary].
@ProviderFor(businessSummary)
const businessSummaryProvider = BusinessSummaryFamily();

/// See also [businessSummary].
class BusinessSummaryFamily extends Family<AsyncValue<BusinessSummaryData>> {
  /// See also [businessSummary].
  const BusinessSummaryFamily();

  /// See also [businessSummary].
  BusinessSummaryProvider call(String orgId, {int? year, int? month}) {
    return BusinessSummaryProvider(orgId, year: year, month: month);
  }

  @override
  BusinessSummaryProvider getProviderOverride(
    covariant BusinessSummaryProvider provider,
  ) {
    return call(provider.orgId, year: provider.year, month: provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'businessSummaryProvider';
}

/// See also [businessSummary].
class BusinessSummaryProvider
    extends AutoDisposeFutureProvider<BusinessSummaryData> {
  /// See also [businessSummary].
  BusinessSummaryProvider(String orgId, {int? year, int? month})
    : this._internal(
        (ref) => businessSummary(
          ref as BusinessSummaryRef,
          orgId,
          year: year,
          month: month,
        ),
        from: businessSummaryProvider,
        name: r'businessSummaryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$businessSummaryHash,
        dependencies: BusinessSummaryFamily._dependencies,
        allTransitiveDependencies:
            BusinessSummaryFamily._allTransitiveDependencies,
        orgId: orgId,
        year: year,
        month: month,
      );

  BusinessSummaryProvider._internal(
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
  final int? year;
  final int? month;

  @override
  Override overrideWith(
    FutureOr<BusinessSummaryData> Function(BusinessSummaryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BusinessSummaryProvider._internal(
        (ref) => create(ref as BusinessSummaryRef),
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
  AutoDisposeFutureProviderElement<BusinessSummaryData> createElement() {
    return _BusinessSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BusinessSummaryProvider &&
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
mixin BusinessSummaryRef on AutoDisposeFutureProviderRef<BusinessSummaryData> {
  /// The parameter `orgId` of this provider.
  String get orgId;

  /// The parameter `year` of this provider.
  int? get year;

  /// The parameter `month` of this provider.
  int? get month;
}

class _BusinessSummaryProviderElement
    extends AutoDisposeFutureProviderElement<BusinessSummaryData>
    with BusinessSummaryRef {
  _BusinessSummaryProviderElement(super.provider);

  @override
  String get orgId => (origin as BusinessSummaryProvider).orgId;
  @override
  int? get year => (origin as BusinessSummaryProvider).year;
  @override
  int? get month => (origin as BusinessSummaryProvider).month;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
