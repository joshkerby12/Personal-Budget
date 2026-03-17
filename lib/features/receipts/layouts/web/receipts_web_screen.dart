import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../transactions/models/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../helpers/receipt_file_io.dart';
import '../../helpers/receipt_formatters.dart';
import '../../models/receipt.dart';
import '../../models/receipt_filter.dart';
import '../../presentation/providers/receipt_provider.dart';
import '../../presentation/widgets/receipt_detail_sheet.dart';

class ReceiptsWebScreen extends ConsumerStatefulWidget {
  const ReceiptsWebScreen({super.key});

  @override
  ConsumerState<ReceiptsWebScreen> createState() => _ReceiptsWebScreenState();
}

class _ReceiptsWebScreenState extends ConsumerState<ReceiptsWebScreen> {
  late final TextEditingController _searchController;
  late final ValueNotifier<_WebQuery> _queryNotifier;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _queryNotifier = ValueNotifier<_WebQuery>(const _WebQuery());
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

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.pagePaddingDesktop),
              child: ValueListenableBuilder<_WebQuery>(
                valueListenable: _queryNotifier,
                builder:
                    (BuildContext context, _WebQuery query, Widget? child) {
                      final ReceiptFilter filter = ReceiptFilter(
                        startDate: query.startDate,
                        endDate: query.endDate,
                        searchText: query.searchText,
                        linkedOnly:
                            query.linkFilter == _ReceiptLinkFilter.linked
                            ? true
                            : null,
                        unlinkedOnly:
                            query.linkFilter == _ReceiptLinkFilter.unlinked
                            ? true
                            : null,
                      );

                      final AsyncValue<List<Receipt>> receiptsAsync = ref.watch(
                        receiptsProvider(orgId, filter: filter),
                      );
                      final AsyncValue<List<Transaction>> transactionsAsync =
                          ref.watch(transactionsProvider(orgId));

                      final Map<String, Transaction> transactionMap =
                          <String, Transaction>{
                            for (final Transaction tx
                                in transactionsAsync.valueOrNull ??
                                    const <Transaction>[])
                              tx.id: tx,
                          };

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text('Receipts', style: AppTextStyles.pageTitle),
                          const SizedBox(height: AppConstants.spacingMd),
                          _Toolbar(
                            searchController: _searchController,
                            query: query,
                            onSearchChanged: (String value) {
                              _queryNotifier.value = query.copyWith(
                                searchText: value,
                              );
                            },
                            onFilterChanged: (_ReceiptLinkFilter next) {
                              _queryNotifier.value = query.copyWith(
                                linkFilter: next,
                              );
                            },
                            onStartDatePressed: () => _pickStartDate(query),
                            onEndDatePressed: () => _pickEndDate(query),
                            onUploadPressed: () => _pickAndUpload(orgId),
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          Expanded(
                            child: receiptsAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (Object error, StackTrace stackTrace) =>
                                  const Center(
                                    child: ErrorView(
                                      message:
                                          'Unable to load receipts right now.',
                                    ),
                                  ),
                              data: (List<Receipt> receipts) {
                                if (receipts.isEmpty) {
                                  return _buildEmptyTable();
                                }
                                return _buildTable(
                                  orgId,
                                  receipts,
                                  transactionMap,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTable(
    String orgId,
    List<Receipt> receipts,
    Map<String, Transaction> transactionMap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.spacingSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          Container(
            color: AppColors.navy,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            child: const Row(
              children: <Widget>[
                SizedBox(
                  width: 72,
                  child: Text('Preview', style: _headerStyle),
                ),
                Expanded(flex: 3, child: Text('Filename', style: _headerStyle)),
                Expanded(child: Text('Uploaded', style: _headerStyle)),
                Expanded(child: Text('Size', style: _headerStyle)),
                Expanded(
                  flex: 2,
                  child: Text('Linked To', style: _headerStyle),
                ),
                SizedBox(
                  width: 120,
                  child: Text('Actions', style: _headerStyle),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: receipts.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final Receipt receipt = receipts[index];
                final Transaction? linked =
                    transactionMap[receipt.transactionId];
                final bool isEven = index % 2 == 0;
                return Container(
                  color: isEven ? AppColors.white : AppColors.lightGray,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingSm,
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 72,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildPreviewIcon(receipt),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          receipt.filename,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          formatReceiptDate(receipt.createdAt),
                          style: AppTextStyles.label,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          formatReceiptSize(receipt.sizeBytes),
                          style: AppTextStyles.label,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          linked == null
                              ? 'Unlinked'
                              : '${linked.merchant} • ${formatReceiptDate(linked.date)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: linked == null
                              ? AppTextStyles.body.copyWith(
                                  color: AppColors.amber,
                                )
                              : AppTextStyles.label,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              tooltip: 'Link / Unlink',
                              icon: const Icon(
                                Icons.link,
                                color: AppColors.teal,
                              ),
                              onPressed: () => showReceiptDetailSheet(
                                context,
                                orgId: orgId,
                                receipt: receipt,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Download',
                              icon: const Icon(
                                Icons.download_outlined,
                                color: AppColors.teal,
                              ),
                              onPressed: () => _download(receipt),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.red,
                              ),
                              onPressed: () => _delete(receipt),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewIcon(Receipt receipt) {
    final IconData icon = isPdfReceipt(receipt.mimeType)
        ? Icons.description_outlined
        : Icons.image_outlined;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.spacingSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, color: AppColors.textMuted),
    );
  }

  Widget _buildEmptyTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.spacingSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          Container(
            color: AppColors.navy,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            child: const Row(
              children: <Widget>[
                SizedBox(
                  width: 72,
                  child: Text('Preview', style: _headerStyle),
                ),
                Expanded(flex: 3, child: Text('Filename', style: _headerStyle)),
                Expanded(child: Text('Uploaded', style: _headerStyle)),
                Expanded(child: Text('Size', style: _headerStyle)),
                Expanded(
                  flex: 2,
                  child: Text('Linked To', style: _headerStyle),
                ),
                SizedBox(
                  width: 120,
                  child: Text('Actions', style: _headerStyle),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('No receipts found', style: AppTextStyles.body),
            ),
          ),
        ],
      ),
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

  Future<void> _download(Receipt receipt) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final String url = await ref
          .read(receiptServiceProvider)
          .getDownloadUrl(receipt.storagePath);
      await triggerBrowserDownload(receipt.filename, url);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to download receipt right now.')),
      );
    }
  }

  Future<void> _delete(Receipt receipt) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete this receipt?'),
          content: const Text('This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(receiptControllerProvider.notifier)
          .delete(receipt.id, receipt.storagePath);
      messenger.showSnackBar(const SnackBar(content: Text('Receipt deleted')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to delete receipt right now.')),
      );
    }
  }

  Future<void> _pickStartDate(_WebQuery query) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: query.startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _queryNotifier.value = query.copyWith(startDate: picked);
    }
  }

  Future<void> _pickEndDate(_WebQuery query) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: query.endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _queryNotifier.value = query.copyWith(endDate: picked);
    }
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.searchController,
    required this.query,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onStartDatePressed,
    required this.onEndDatePressed,
    required this.onUploadPressed,
  });

  final TextEditingController searchController;
  final _WebQuery query;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_ReceiptLinkFilter> onFilterChanged;
  final VoidCallback onStartDatePressed;
  final VoidCallback onEndDatePressed;
  final VoidCallback onUploadPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 260,
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              labelText: 'Search filename',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onStartDatePressed,
          icon: const Icon(Icons.event_outlined),
          label: Text(
            query.startDate == null
                ? 'From'
                : 'From ${formatReceiptDate(query.startDate!)}',
          ),
        ),
        OutlinedButton.icon(
          onPressed: onEndDatePressed,
          icon: const Icon(Icons.event_outlined),
          label: Text(
            query.endDate == null
                ? 'To'
                : 'To ${formatReceiptDate(query.endDate!)}',
          ),
        ),
        DropdownButton<_ReceiptLinkFilter>(
          value: query.linkFilter,
          items: const <DropdownMenuItem<_ReceiptLinkFilter>>[
            DropdownMenuItem<_ReceiptLinkFilter>(
              value: _ReceiptLinkFilter.all,
              child: Text('All'),
            ),
            DropdownMenuItem<_ReceiptLinkFilter>(
              value: _ReceiptLinkFilter.linked,
              child: Text('Linked Only'),
            ),
            DropdownMenuItem<_ReceiptLinkFilter>(
              value: _ReceiptLinkFilter.unlinked,
              child: Text('Unlinked Only'),
            ),
          ],
          onChanged: (_ReceiptLinkFilter? value) {
            if (value != null) {
              onFilterChanged(value);
            }
          },
        ),
        ElevatedButton.icon(
          onPressed: onUploadPressed,
          icon: const Icon(Icons.upload_file_outlined),
          label: const Text('Upload Receipt'),
        ),
      ],
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: AppColors.white,
);

enum _ReceiptLinkFilter { all, linked, unlinked }

class _WebQuery {
  const _WebQuery({
    this.startDate,
    this.endDate,
    this.searchText = '',
    this.linkFilter = _ReceiptLinkFilter.all,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String searchText;
  final _ReceiptLinkFilter linkFilter;

  _WebQuery copyWith({
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    String? searchText,
    _ReceiptLinkFilter? linkFilter,
  }) {
    return _WebQuery(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      searchText: searchText ?? this.searchText,
      linkFilter: linkFilter ?? this.linkFilter,
    );
  }
}
