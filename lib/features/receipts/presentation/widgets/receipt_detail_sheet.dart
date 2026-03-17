import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../transactions/models/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../helpers/receipt_file_io.dart';
import '../../helpers/receipt_formatters.dart';
import '../../models/receipt.dart';
import '../providers/receipt_provider.dart';

Future<void> showReceiptDetailSheet(
  BuildContext context, {
  required String orgId,
  required Receipt receipt,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      return ReceiptDetailSheet(orgId: orgId, receipt: receipt);
    },
  );
}

class ReceiptDetailSheet extends ConsumerWidget {
  const ReceiptDetailSheet({
    super.key,
    required this.orgId,
    required this.receipt,
  });

  final String orgId;
  final Receipt receipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Transaction>> transactionsAsync = ref.watch(
      transactionsProvider(orgId),
    );

    final bool isLinked = receipt.transactionId != null;
    final Transaction? linkedTransaction = _findTransaction(
      transactionsAsync.valueOrNull ?? const <Transaction>[],
      receipt.transactionId,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppConstants.spacingLg,
          right: AppConstants.spacingLg,
          top: AppConstants.spacingLg,
          bottom:
              MediaQuery.viewInsetsOf(context).bottom + AppConstants.spacingLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Receipt Details', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingSm),
            _ReceiptPreview(receipt: receipt),
            const SizedBox(height: AppConstants.spacingMd),
            Text(receipt.filename, style: AppTextStyles.body),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              'Uploaded ${formatReceiptDate(receipt.createdAt)}',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              formatReceiptSize(receipt.sizeBytes),
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            if (isLinked) ...<Widget>[
              Text(
                linkedTransaction == null
                    ? 'Linked to a transaction'
                    : 'Linked to: ${linkedTransaction.merchant}',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              OutlinedButton(
                onPressed: () => _unlink(context, ref),
                child: const Text('Unlink'),
              ),
            ] else ...<Widget>[
              ElevatedButton(
                onPressed: () => _link(context, ref, transactionsAsync),
                child: const Text('Link to Transaction'),
              ),
            ],
            const SizedBox(height: AppConstants.spacingSm),
            OutlinedButton(
              onPressed: () => _download(context, ref),
              child: const Text('Download'),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            TextButton(
              onPressed: () => _delete(context, ref),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context, WidgetRef ref) async {
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

  Future<void> _unlink(BuildContext context, WidgetRef ref) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);

    try {
      await ref.read(receiptControllerProvider.notifier).unlink(receipt.id);
      messenger.showSnackBar(const SnackBar(content: Text('Receipt unlinked')));
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to unlink receipt right now.')),
      );
    }
  }

  Future<void> _link(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Transaction>> transactionsAsync,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);

    if (transactionsAsync.isLoading) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Transactions are still loading.')),
      );
      return;
    }
    if (transactionsAsync.hasError) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to load transactions right now.')),
      );
      return;
    }

    final List<Transaction> candidates =
        (transactionsAsync.value ?? const <Transaction>[])
            .where((Transaction tx) => tx.receiptId == null)
            .toList(growable: false);

    final Transaction? picked = await showDialog<Transaction>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _TransactionPickerDialog(transactions: candidates);
      },
    );

    if (picked == null) {
      return;
    }

    try {
      await ref
          .read(receiptControllerProvider.notifier)
          .linkToTransaction(receipt.id, picked.id);
      messenger.showSnackBar(const SnackBar(content: Text('Receipt linked')));
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to link receipt right now.')),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
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
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to delete receipt right now.')),
      );
    }
  }
}

class _ReceiptPreview extends ConsumerWidget {
  const _ReceiptPreview({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isImageReceipt(receipt.mimeType)) {
      return FutureBuilder<String>(
        future: ref
            .read(receiptServiceProvider)
            .getDownloadUrl(receipt.storagePath),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.spacingSm),
                color: AppColors.lightGray,
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.spacingSm),
            child: Image.network(
              snapshot.data!,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) => _fallbackBox(Icons.image_not_supported),
            ),
          );
        },
      );
    }

    if (isPdfReceipt(receipt.mimeType)) {
      return _fallbackBox(Icons.picture_as_pdf);
    }

    return _fallbackBox(Icons.insert_drive_file_outlined);
  }

  Widget _fallbackBox(IconData icon) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.spacingSm),
        color: AppColors.lightGray,
        border: Border.all(color: AppColors.border),
      ),
      child: Center(child: Icon(icon, size: 72, color: AppColors.textMuted)),
    );
  }
}

class _TransactionPickerDialog extends StatefulWidget {
  const _TransactionPickerDialog({required this.transactions});

  final List<Transaction> transactions;

  @override
  State<_TransactionPickerDialog> createState() =>
      _TransactionPickerDialogState();
}

class _TransactionPickerDialogState extends State<_TransactionPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  late final ValueNotifier<String> _queryNotifier;

  @override
  void initState() {
    super.initState();
    _queryNotifier = ValueNotifier<String>('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _queryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Link to Transaction'),
      content: SizedBox(
        width: 520,
        height: 420,
        child: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search transactions',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (String value) => _queryNotifier.value = value,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _queryNotifier,
                builder: (BuildContext context, String query, Widget? child) {
                  final String normalizedQuery = query.trim().toLowerCase();
                  final List<Transaction> filtered = widget.transactions
                      .where((Transaction tx) {
                        if (normalizedQuery.isEmpty) {
                          return true;
                        }
                        return tx.merchant.toLowerCase().contains(
                              normalizedQuery,
                            ) ||
                            tx.category.toLowerCase().contains(
                              normalizedQuery,
                            ) ||
                            tx.subcategory.toLowerCase().contains(
                              normalizedQuery,
                            );
                      })
                      .toList(growable: false);

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No available transactions',
                        style: AppTextStyles.body,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(height: AppConstants.spacingSm),
                    itemBuilder: (BuildContext context, int index) {
                      final Transaction tx = filtered[index];
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(tx),
                        title: Text(tx.merchant, style: AppTextStyles.body),
                        subtitle: Text(
                          '${formatReceiptDate(tx.date)} • ${tx.category} / ${tx.subcategory}',
                          style: AppTextStyles.label,
                        ),
                        trailing: Text(
                          '\$${tx.amount.toStringAsFixed(2)}',
                          style: AppTextStyles.body,
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
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

Transaction? _findTransaction(List<Transaction> items, String? id) {
  if (id == null) {
    return null;
  }

  for (final Transaction item in items) {
    if (item.id == id) {
      return item;
    }
  }
  return null;
}
