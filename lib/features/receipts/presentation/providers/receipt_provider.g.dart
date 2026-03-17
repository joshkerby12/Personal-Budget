// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$receiptServiceHash() => r'2284b1c8bb30360557b868286f8182b5ef62006a';

/// See also [receiptService].
@ProviderFor(receiptService)
final receiptServiceProvider = Provider<ReceiptService>.internal(
  receiptService,
  name: r'receiptServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$receiptServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReceiptServiceRef = ProviderRef<ReceiptService>;
String _$receiptsOrgIdHash() => r'e53f240ff6410e0679f16085ac4a5412ea869a72';

/// See also [receiptsOrgId].
@ProviderFor(receiptsOrgId)
final receiptsOrgIdProvider = AutoDisposeFutureProvider<String?>.internal(
  receiptsOrgId,
  name: r'receiptsOrgIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$receiptsOrgIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReceiptsOrgIdRef = AutoDisposeFutureProviderRef<String?>;
String _$receiptsHash() => r'c52a9773e6ecd72cf723ef531164c229d56abd42';

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

/// See also [receipts].
@ProviderFor(receipts)
const receiptsProvider = ReceiptsFamily();

/// See also [receipts].
class ReceiptsFamily extends Family<AsyncValue<List<Receipt>>> {
  /// See also [receipts].
  const ReceiptsFamily();

  /// See also [receipts].
  ReceiptsProvider call(
    String orgId, {
    ReceiptFilter filter = const ReceiptFilter(),
  }) {
    return ReceiptsProvider(orgId, filter: filter);
  }

  @override
  ReceiptsProvider getProviderOverride(covariant ReceiptsProvider provider) {
    return call(provider.orgId, filter: provider.filter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'receiptsProvider';
}

/// See also [receipts].
class ReceiptsProvider extends AutoDisposeFutureProvider<List<Receipt>> {
  /// See also [receipts].
  ReceiptsProvider(String orgId, {ReceiptFilter filter = const ReceiptFilter()})
    : this._internal(
        (ref) => receipts(ref as ReceiptsRef, orgId, filter: filter),
        from: receiptsProvider,
        name: r'receiptsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$receiptsHash,
        dependencies: ReceiptsFamily._dependencies,
        allTransitiveDependencies: ReceiptsFamily._allTransitiveDependencies,
        orgId: orgId,
        filter: filter,
      );

  ReceiptsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orgId,
    required this.filter,
  }) : super.internal();

  final String orgId;
  final ReceiptFilter filter;

  @override
  Override overrideWith(
    FutureOr<List<Receipt>> Function(ReceiptsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReceiptsProvider._internal(
        (ref) => create(ref as ReceiptsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orgId: orgId,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Receipt>> createElement() {
    return _ReceiptsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReceiptsProvider &&
        other.orgId == orgId &&
        other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orgId.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReceiptsRef on AutoDisposeFutureProviderRef<List<Receipt>> {
  /// The parameter `orgId` of this provider.
  String get orgId;

  /// The parameter `filter` of this provider.
  ReceiptFilter get filter;
}

class _ReceiptsProviderElement
    extends AutoDisposeFutureProviderElement<List<Receipt>>
    with ReceiptsRef {
  _ReceiptsProviderElement(super.provider);

  @override
  String get orgId => (origin as ReceiptsProvider).orgId;
  @override
  ReceiptFilter get filter => (origin as ReceiptsProvider).filter;
}

String _$receiptControllerHash() => r'6e8274f9d4a641deec982cc7a42f2aebdae92913';

/// See also [ReceiptController].
@ProviderFor(ReceiptController)
final receiptControllerProvider =
    AutoDisposeNotifierProvider<ReceiptController, AsyncValue<void>>.internal(
      ReceiptController.new,
      name: r'receiptControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$receiptControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReceiptController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
