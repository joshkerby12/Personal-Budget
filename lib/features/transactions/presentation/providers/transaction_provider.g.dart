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
String _$csvImportServiceHash() => r'85072c72767b6d5dd6f2d36458ce3d9ef52e75c1';

/// See also [csvImportService].
@ProviderFor(csvImportService)
final csvImportServiceProvider = Provider<CsvImportService>.internal(
  csvImportService,
  name: r'csvImportServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$csvImportServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CsvImportServiceRef = ProviderRef<CsvImportService>;
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

String _$recentCategorizedTransactionsHash() =>
    r'9bd82471b4b5e2fbf31696c9a5920a03c0eecf7f';

/// See also [recentCategorizedTransactions].
@ProviderFor(recentCategorizedTransactions)
const recentCategorizedTransactionsProvider =
    RecentCategorizedTransactionsFamily();

/// See also [recentCategorizedTransactions].
class RecentCategorizedTransactionsFamily
    extends Family<AsyncValue<List<Transaction>>> {
  /// See also [recentCategorizedTransactions].
  const RecentCategorizedTransactionsFamily();

  /// See also [recentCategorizedTransactions].
  RecentCategorizedTransactionsProvider call(String orgId) {
    return RecentCategorizedTransactionsProvider(orgId);
  }

  @override
  RecentCategorizedTransactionsProvider getProviderOverride(
    covariant RecentCategorizedTransactionsProvider provider,
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
  String? get name => r'recentCategorizedTransactionsProvider';
}

/// See also [recentCategorizedTransactions].
class RecentCategorizedTransactionsProvider
    extends AutoDisposeFutureProvider<List<Transaction>> {
  /// See also [recentCategorizedTransactions].
  RecentCategorizedTransactionsProvider(String orgId)
    : this._internal(
        (ref) => recentCategorizedTransactions(
          ref as RecentCategorizedTransactionsRef,
          orgId,
        ),
        from: recentCategorizedTransactionsProvider,
        name: r'recentCategorizedTransactionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recentCategorizedTransactionsHash,
        dependencies: RecentCategorizedTransactionsFamily._dependencies,
        allTransitiveDependencies:
            RecentCategorizedTransactionsFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  RecentCategorizedTransactionsProvider._internal(
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
    FutureOr<List<Transaction>> Function(
      RecentCategorizedTransactionsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecentCategorizedTransactionsProvider._internal(
        (ref) => create(ref as RecentCategorizedTransactionsRef),
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
  AutoDisposeFutureProviderElement<List<Transaction>> createElement() {
    return _RecentCategorizedTransactionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentCategorizedTransactionsProvider &&
        other.orgId == orgId;
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
mixin RecentCategorizedTransactionsRef
    on AutoDisposeFutureProviderRef<List<Transaction>> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _RecentCategorizedTransactionsProviderElement
    extends AutoDisposeFutureProviderElement<List<Transaction>>
    with RecentCategorizedTransactionsRef {
  _RecentCategorizedTransactionsProviderElement(super.provider);

  @override
  String get orgId => (origin as RecentCategorizedTransactionsProvider).orgId;
}

String _$csvImportLogsHash() => r'641c7a6800cad06542002b1431014fddeb6ec4a4';

/// See also [csvImportLogs].
@ProviderFor(csvImportLogs)
const csvImportLogsProvider = CsvImportLogsFamily();

/// See also [csvImportLogs].
class CsvImportLogsFamily extends Family<AsyncValue<List<CsvImportLog>>> {
  /// See also [csvImportLogs].
  const CsvImportLogsFamily();

  /// See also [csvImportLogs].
  CsvImportLogsProvider call(String orgId) {
    return CsvImportLogsProvider(orgId);
  }

  @override
  CsvImportLogsProvider getProviderOverride(
    covariant CsvImportLogsProvider provider,
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
  String? get name => r'csvImportLogsProvider';
}

/// See also [csvImportLogs].
class CsvImportLogsProvider
    extends AutoDisposeFutureProvider<List<CsvImportLog>> {
  /// See also [csvImportLogs].
  CsvImportLogsProvider(String orgId)
    : this._internal(
        (ref) => csvImportLogs(ref as CsvImportLogsRef, orgId),
        from: csvImportLogsProvider,
        name: r'csvImportLogsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$csvImportLogsHash,
        dependencies: CsvImportLogsFamily._dependencies,
        allTransitiveDependencies:
            CsvImportLogsFamily._allTransitiveDependencies,
        orgId: orgId,
      );

  CsvImportLogsProvider._internal(
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
    FutureOr<List<CsvImportLog>> Function(CsvImportLogsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CsvImportLogsProvider._internal(
        (ref) => create(ref as CsvImportLogsRef),
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
  AutoDisposeFutureProviderElement<List<CsvImportLog>> createElement() {
    return _CsvImportLogsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CsvImportLogsProvider && other.orgId == orgId;
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
mixin CsvImportLogsRef on AutoDisposeFutureProviderRef<List<CsvImportLog>> {
  /// The parameter `orgId` of this provider.
  String get orgId;
}

class _CsvImportLogsProviderElement
    extends AutoDisposeFutureProviderElement<List<CsvImportLog>>
    with CsvImportLogsRef {
  _CsvImportLogsProviderElement(super.provider);

  @override
  String get orgId => (origin as CsvImportLogsProvider).orgId;
}

String _$transactionSplitsHash() => r'aa249d9fc4e23515d4cbde0fbdb370c31e00a5d6';

/// See also [transactionSplits].
@ProviderFor(transactionSplits)
const transactionSplitsProvider = TransactionSplitsFamily();

/// See also [transactionSplits].
class TransactionSplitsFamily
    extends Family<AsyncValue<List<TransactionSplit>>> {
  /// See also [transactionSplits].
  const TransactionSplitsFamily();

  /// See also [transactionSplits].
  TransactionSplitsProvider call(String transactionId) {
    return TransactionSplitsProvider(transactionId);
  }

  @override
  TransactionSplitsProvider getProviderOverride(
    covariant TransactionSplitsProvider provider,
  ) {
    return call(provider.transactionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transactionSplitsProvider';
}

/// See also [transactionSplits].
class TransactionSplitsProvider
    extends AutoDisposeFutureProvider<List<TransactionSplit>> {
  /// See also [transactionSplits].
  TransactionSplitsProvider(String transactionId)
    : this._internal(
        (ref) => transactionSplits(ref as TransactionSplitsRef, transactionId),
        from: transactionSplitsProvider,
        name: r'transactionSplitsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$transactionSplitsHash,
        dependencies: TransactionSplitsFamily._dependencies,
        allTransitiveDependencies:
            TransactionSplitsFamily._allTransitiveDependencies,
        transactionId: transactionId,
      );

  TransactionSplitsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.transactionId,
  }) : super.internal();

  final String transactionId;

  @override
  Override overrideWith(
    FutureOr<List<TransactionSplit>> Function(TransactionSplitsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionSplitsProvider._internal(
        (ref) => create(ref as TransactionSplitsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        transactionId: transactionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TransactionSplit>> createElement() {
    return _TransactionSplitsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionSplitsProvider &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, transactionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TransactionSplitsRef
    on AutoDisposeFutureProviderRef<List<TransactionSplit>> {
  /// The parameter `transactionId` of this provider.
  String get transactionId;
}

class _TransactionSplitsProviderElement
    extends AutoDisposeFutureProviderElement<List<TransactionSplit>>
    with TransactionSplitsRef {
  _TransactionSplitsProviderElement(super.provider);

  @override
  String get transactionId =>
      (origin as TransactionSplitsProvider).transactionId;
}

String _$transactionControllerHash() =>
    r'0de95164662cc44800a42a3b33064b7baf9d06de';

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
String _$csvImportControllerHash() =>
    r'92d94189d29e5aa70bbf2a8bd3be08cd15c2205a';

/// See also [CsvImportController].
@ProviderFor(CsvImportController)
final csvImportControllerProvider =
    AutoDisposeNotifierProvider<CsvImportController, AsyncValue<void>>.internal(
      CsvImportController.new,
      name: r'csvImportControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$csvImportControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CsvImportController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
