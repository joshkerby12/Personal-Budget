// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tellerServiceHash() => r'c28aa4cbbff82632487574d2bdac6584e301cade';

/// See also [tellerService].
@ProviderFor(tellerService)
final tellerServiceProvider = Provider<TellerService>.internal(
  tellerService,
  name: r'tellerServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tellerServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TellerServiceRef = ProviderRef<TellerService>;
String _$tellerEnrollmentsHash() => r'240212a604bfdfc5e5be73bf1be83cdc85d0b835';

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

/// See also [tellerEnrollments].
@ProviderFor(tellerEnrollments)
const tellerEnrollmentsProvider = TellerEnrollmentsFamily();

/// See also [tellerEnrollments].
class TellerEnrollmentsFamily
    extends Family<AsyncValue<List<TellerEnrollment>>> {
  /// See also [tellerEnrollments].
  const TellerEnrollmentsFamily();

  /// See also [tellerEnrollments].
  TellerEnrollmentsProvider call(String orgId) {
    return TellerEnrollmentsProvider(orgId);
  }

  @override
  TellerEnrollmentsProvider getProviderOverride(
    covariant TellerEnrollmentsProvider provider,
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
  String? get name => r'tellerEnrollmentsProvider';
}

/// See also [tellerEnrollments].
class TellerEnrollmentsProvider
    extends AutoDisposeFutureProvider<List<TellerEnrollment>> {
  /// See also [tellerEnrollments].
  TellerEnrollmentsProvider(String orgId)
    : this._internal(
        (ref) => tellerEnrollments(ref as TellerEnrollmentsRef, orgId),
        from: tellerEnrollmentsProvider,
        name: r'tellerEnrollmentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tellerEnrollmentsHash,
        dependencies: TellerEnrollmentsFamily._dependencies,
        allTransitiveDependencies:
            TellerEnrollmentsFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  TellerEnrollmentsProvider._internal(
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
    FutureOr<List<TellerEnrollment>> Function(TellerEnrollmentsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TellerEnrollmentsProvider._internal(
        (ref) => create(ref as TellerEnrollmentsRef),
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
  AutoDisposeFutureProviderElement<List<TellerEnrollment>> createElement() {
    return _TellerEnrollmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TellerEnrollmentsProvider && other.orgId == orgId;
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
mixin TellerEnrollmentsRef
    on AutoDisposeFutureProviderRef<List<TellerEnrollment>> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _TellerEnrollmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<TellerEnrollment>>
    with TellerEnrollmentsRef {
  _TellerEnrollmentsProviderElement(super.provider);

  @override
  String get orgId => (origin as TellerEnrollmentsProvider).orgId;
}

String _$tellerControllerHash() => r'76d38d6dc7b3ab3151112fbe46c5832e912c8f70';

/// See also [TellerController].
@ProviderFor(TellerController)
final tellerControllerProvider =
    AutoDisposeNotifierProvider<TellerController, AsyncValue<void>>.internal(
      TellerController.new,
      name: r'tellerControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tellerControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TellerController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
