// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mileage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mileageServiceHash() => r'a5b9a435d788ee9a55f35de536a123ffaceffc9d';

/// See also [mileageService].
@ProviderFor(mileageService)
final mileageServiceProvider = Provider<MileageService>.internal(
  mileageService,
  name: r'mileageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mileageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MileageServiceRef = ProviderRef<MileageService>;
String _$mileageOrgIdHash() => r'a76c3ab9f15117716575a91fb8082581e5f7e696';

/// See also [mileageOrgId].
@ProviderFor(mileageOrgId)
final mileageOrgIdProvider = AutoDisposeFutureProvider<String?>.internal(
  mileageOrgId,
  name: r'mileageOrgIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mileageOrgIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MileageOrgIdRef = AutoDisposeFutureProviderRef<String?>;
String _$mileageTripsHash() => r'12a12e9e53b9f1cfe2c6bc437ad0ecceb9a07622';

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

/// See also [mileageTrips].
@ProviderFor(mileageTrips)
const mileageTripsProvider = MileageTripsFamily();

/// See also [mileageTrips].
class MileageTripsFamily extends Family<AsyncValue<List<MileageTrip>>> {
  /// See also [mileageTrips].
  const MileageTripsFamily();

  /// See also [mileageTrips].
  MileageTripsProvider call(String orgId, {int? year, int? month}) {
    return MileageTripsProvider(orgId, year: year, month: month);
  }

  @override
  MileageTripsProvider getProviderOverride(
    covariant MileageTripsProvider provider,
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
  String? get name => r'mileageTripsProvider';
}

/// See also [mileageTrips].
class MileageTripsProvider
    extends AutoDisposeFutureProvider<List<MileageTrip>> {
  /// See also [mileageTrips].
  MileageTripsProvider(String orgId, {int? year, int? month})
    : this._internal(
        (ref) => mileageTrips(
          ref as MileageTripsRef,
          orgId,
          year: year,
          month: month,
        ),
        from: mileageTripsProvider,
        name: r'mileageTripsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mileageTripsHash,
        dependencies: MileageTripsFamily._dependencies,
        allTransitiveDependencies:
            MileageTripsFamily._allTransitiveDependencies,
        orgId: orgId,
        year: year,
        month: month,
      );

  MileageTripsProvider._internal(
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
    FutureOr<List<MileageTrip>> Function(MileageTripsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MileageTripsProvider._internal(
        (ref) => create(ref as MileageTripsRef),
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
  AutoDisposeFutureProviderElement<List<MileageTrip>> createElement() {
    return _MileageTripsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MileageTripsProvider &&
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
mixin MileageTripsRef on AutoDisposeFutureProviderRef<List<MileageTrip>> {
  /// The parameter `orgId` of this provider.
  String get orgId;

  /// The parameter `year` of this provider.
  int? get year;

  /// The parameter `month` of this provider.
  int? get month;
}

class _MileageTripsProviderElement
    extends AutoDisposeFutureProviderElement<List<MileageTrip>>
    with MileageTripsRef {
  _MileageTripsProviderElement(super.provider);

  @override
  String get orgId => (origin as MileageTripsProvider).orgId;
  @override
  int? get year => (origin as MileageTripsProvider).year;
  @override
  int? get month => (origin as MileageTripsProvider).month;
}

String _$mileageControllerHash() => r'b16358335add795b09c7151acb356c79aad162e6';

/// See also [MileageController].
@ProviderFor(MileageController)
final mileageControllerProvider =
    AutoDisposeNotifierProvider<MileageController, AsyncValue<void>>.internal(
      MileageController.new,
      name: r'mileageControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$mileageControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MileageController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
