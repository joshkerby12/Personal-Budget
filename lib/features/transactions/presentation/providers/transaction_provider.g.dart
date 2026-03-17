// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionServiceHash() =>
    r'cf7c8bd9520b40dadaeeb2f3c18a1610d1b3a084';

/// See also [transactionService].
@ProviderFor(transactionService)
final transactionServiceProvider = Provider<TransactionService>.internal(
  transactionService,
  name: r'transactionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionServiceRef = ProviderRef<TransactionService>;
String _$transactionsHash() => r'cf2bcd7aa53ea04c57b82aef784bd4e63cabedda';

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

/// See also [transactions].
@ProviderFor(transactions)
const transactionsProvider = TransactionsFamily();

/// See also [transactions].
class TransactionsFamily extends Family<AsyncValue<List<Transaction>>> {
  /// See also [transactions].
  const TransactionsFamily();

  /// See also [transactions].
  TransactionsProvider call(
    String orgId, {
    TransactionFilter filter = const TransactionFilter(),
  }) {
    return TransactionsProvider(orgId, filter: filter);
  }

  @override
  TransactionsProvider getProviderOverride(
    covariant TransactionsProvider provider,
  ) {
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
  String? get name => r'transactionsProvider';
}

/// See also [transactions].
class TransactionsProvider
    extends AutoDisposeFutureProvider<List<Transaction>> {
  /// See also [transactions].
  TransactionsProvider(
    String orgId, {
    TransactionFilter filter = const TransactionFilter(),
  }) : this._internal(
         (ref) => transactions(ref as TransactionsRef, orgId, filter: filter),
         from: transactionsProvider,
         name: r'transactionsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$transactionsHash,
         dependencies: TransactionsFamily._dependencies,
         allTransitiveDependencies:
             TransactionsFamily._allTransitiveDependencies,
         orgId: orgId,
         filter: filter,
       );

  TransactionsProvider._internal(
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
  final TransactionFilter filter;

  @override
  Override overrideWith(
    FutureOr<List<Transaction>> Function(TransactionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionsProvider._internal(
        (ref) => create(ref as TransactionsRef),
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
  AutoDisposeFutureProviderElement<List<Transaction>> createElement() {
    return _TransactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsProvider &&
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
mixin TransactionsRef on AutoDisposeFutureProviderRef<List<Transaction>> {
  /// The parameter `orgId` of this provider.
  String get orgId;

  /// The parameter `filter` of this provider.
  TransactionFilter get filter;
}

class _TransactionsProviderElement
    extends AutoDisposeFutureProviderElement<List<Transaction>>
    with TransactionsRef {
  _TransactionsProviderElement(super.provider);

  @override
  String get orgId => (origin as TransactionsProvider).orgId;
  @override
  TransactionFilter get filter => (origin as TransactionsProvider).filter;
}

String _$transactionControllerHash() =>
    r'33dee52ab2e10156fd9f539f13589f0f0d2e0b5b';

/// See also [TransactionController].
@ProviderFor(TransactionController)
final transactionControllerProvider =
    AutoDisposeNotifierProvider<
      TransactionController,
      AsyncValue<void>
    >.internal(
      TransactionController.new,
      name: r'transactionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TransactionController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
