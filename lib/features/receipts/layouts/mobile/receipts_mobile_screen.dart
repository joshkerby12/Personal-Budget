import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../transactions/models/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../helpers/receipt_formatters.dart';
import '../../models/receipt.dart';
import '../../models/receipt_filter.dart';
import '../../presentation/providers/receipt_provider.dart';
import '../../presentation/widgets/receipt_detail_sheet.dart';

class ReceiptsMobileScreen extends ConsumerStatefulWidget {
  const ReceiptsMobileScreen({super.key});

  @override
  ConsumerState<ReceiptsMobileScreen> createState() =>
      _ReceiptsMobileScreenState();
}

class _ReceiptsMobileScreenState extends ConsumerState<ReceiptsMobileScreen> {
  late final TextEditingController _searchController;
  late final ValueNotifier<_MobileQuery> _queryNotifier;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _queryNotifier = ValueNotifier<_MobileQuery>(const _MobileQuery());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _queryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<String?> orgIdAsync = ref.watch(receiptsOrgIdProvider);

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => const Center(
        child: ErrorView(message: 'Unable to load receipts right now.'),
      ),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        return ValueListenableBuilder<_MobileQuery>(
          valueListenable: _queryNotifier,
          builder: (BuildContext context, _MobileQuery query, Widget? child) {
            final ReceiptFilter filter = ReceiptFilter(
              searchText: query.searchText,
              linkedOnly: query.linkFilter == _ReceiptLinkFilter.linked
                  ? true
                  : null,
              unlinkedOnly: query.linkFilter == _ReceiptLinkFilter.unlinked
                  ? true
                  : null,
            );

            final AsyncValue<List<Receipt>> receiptsAsync = ref.watch(
              receiptsProvider(orgId, filter: filter),
            );
            final AsyncValue<List<Transaction>> transactionsAsync = ref.watch(
              transactionsProvider(orgId),
            );

            final Map<String, Transaction> transactionMap =
                <String, Transaction>{
                  for (final Transaction tx
                      in transactionsAsync.valueOrNull ?? const <Transaction>[])
                    tx.id: tx,
                };

            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.pagePaddingMobile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text('Receipts', style: AppTextStyles.pageTitle),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _pickAndUpload(orgId),
                          tooltip: 'Upload receipt',
                          icon: const Icon(Icons.upload_file_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _buildFilterChip(
                            label: 'All',
                            value: _ReceiptLinkFilter.all,
                            selected: query.linkFilter,
                          ),
                          const SizedBox(width: AppConstants.spacingSm),
                          _buildFilterChip(
                            label: 'Linked',
                            value: _ReceiptLinkFilter.linked,
                            selected: query.linkFilter,
                          ),
                          const SizedBox(width: AppConstants.spacingSm),
                          _buildFilterChip(
                            label: 'Unlinked',
                            value: _ReceiptLinkFilter.unlinked,
                            selected: query.linkFilter,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search by filename',
                      ),
                      onChanged: (String value) {
                        _queryNotifier.value = query.copyWith(
                          searchText: value,
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Expanded(
                      child: receiptsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (Object error, StackTrace stackTrace) =>
                            const Center(
                              child: ErrorView(
                                message: 'Unable to load receipts right now.',
                              ),
                            ),
                        data: (List<Receipt> receipts) {
                          if (receipts.isEmpty) {
                            return const _EmptyState();
                          }

                          return ListView.separated(
                            itemCount: receipts.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(
                                      height: AppConstants.spacingSm,
                                    ),
                            itemBuilder: (BuildContext context, int index) {
                              final Receipt receipt = receipts[index];
                              final Transaction? linkedTransaction =
                                  transactionMap[receipt.transactionId];
                              return _ReceiptCard(
                                receipt: receipt,
                                linkedTransaction: linkedTransaction,
                                onTap: () => showReceiptDetailSheet(
                                  context,
                                  orgId: orgId,
                                  receipt: receipt,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required _ReceiptLinkFilter value,
    required _ReceiptLinkFilter selected,
  }) {
    final bool isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.tealLight,
      backgroundColor: AppColors.white,
      side: const BorderSide(color: AppColors.border),
      onSelected: (_) {
        final _MobileQuery current = _queryNotifier.value;
        _queryNotifier.value = current.copyWith(linkFilter: value);
      },
    );
  }

  Future<void> _pickAndUpload(String orgId) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final Receipt? receipt = await ref
          .read(receiptControllerProvider.notifier)
          .pickAndUpload(orgId);
      if (receipt == null) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text('Uploaded ${receipt.filename}')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('StateError: ', '')),
        ),
      );
    }
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.receipt,
    required this.linkedTransaction,
    required this.onTap,
  });

  final Receipt receipt;
  final Transaction? linkedTransaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool linked = receipt.transactionId != null;
    final IconData icon = isPdfReceipt(receipt.mimeType)
        ? Icons.description_outlined
        : Icons.image_outlined;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.spacingSm),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppConstants.spacingSm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: AppColors.textMuted),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      receipt.filename,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      formatReceiptDate(receipt.createdAt),
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      formatReceiptSize(receipt.sizeBytes),
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSm,
                      vertical: AppConstants.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: linked ? AppColors.tealLight : AppColors.amberFill,
                      borderRadius: BorderRadius.circular(
                        AppConstants.spacingSm,
                      ),
                      border: Border.all(
                        color: linked ? AppColors.teal : AppColors.amber,
                      ),
                    ),
                    child: Text(
                      linked ? 'Linked' : 'Unlinked',
                      style: AppTextStyles.label.copyWith(
                        color: linked ? AppColors.teal : AppColors.amber,
                      ),
                    ),
                  ),
                  if (linkedTransaction != null) ...<Widget>[
                    const SizedBox(height: AppConstants.spacingXs),
                    SizedBox(
                      width: 96,
                      child: Text(
                        linkedTransaction!.merchant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: AppTextStyles.label,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.receipt_long_outlined,
            size: 36,
            color: AppColors.textMuted,
          ),
          SizedBox(height: AppConstants.spacingSm),
          Text('No receipts yet', style: AppTextStyles.cardTitle),
          SizedBox(height: AppConstants.spacingXs),
          Text(
            'Tap the upload button to add your first receipt',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

enum _ReceiptLinkFilter { all, linked, unlinked }

class _MobileQuery {
  const _MobileQuery({
    this.searchText = '',
    this.linkFilter = _ReceiptLinkFilter.all,
  });

  final String searchText;
  final _ReceiptLinkFilter linkFilter;

  _MobileQuery copyWith({String? searchText, _ReceiptLinkFilter? linkFilter}) {
    return _MobileQuery(
      searchText: searchText ?? this.searchText,
      linkFilter: linkFilter ?? this.linkFilter,
    );
  }
}
