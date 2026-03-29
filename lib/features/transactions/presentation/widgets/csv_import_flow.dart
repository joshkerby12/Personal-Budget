import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../helpers/csv_dedup.dart';
import '../../helpers/csv_institution_maps.dart';
import '../../helpers/csv_parser.dart';
import '../../helpers/transaction_calculations.dart';
import '../../models/csv_import_log.dart';
import '../../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'transaction_form.dart';

Future<void> showCsvImportFlow(
  BuildContext context,
  WidgetRef ref, {
  required bool isMobile,
  required String orgId,
  required List<Transaction> existingTransactions,
}) async {
  final Widget content = _CsvImportFlowContent(
    orgId: orgId,
    existingTransactions: existingTransactions,
  );

  if (isMobile) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.viewInsetsOf(sheetContext).bottom +
                AppConstants.spacingLg,
            left: AppConstants.spacingLg,
            right: AppConstants.spacingLg,
            top: AppConstants.spacingLg,
          ),
          child: content,
        );
      },
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: content,
        ),
      );
    },
  );
}

Future<void> showCsvImportDrillDown(
  BuildContext parentContext,
  WidgetRef ref, {
  required String orgId,
  required CsvImportLog log,
}) async {
  final NumberFormat currencyFormatter = NumberFormat.currency(symbol: r'$');
  final DateFormat dateFormatter = DateFormat('MMM d, yyyy');

  await showDialog<void>(
    context: parentContext,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('Import · ${log.filename}'),
        content: SizedBox(
          width: 760,
          height: 460,
          child: FutureBuilder<List<Transaction>>(
            future: ref
                .read(csvImportServiceProvider)
                .fetchTransactionsForImport(log.id),
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<Transaction>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Unable to load transactions for this import.',
                      ),
                    );
                  }

                  final List<Transaction> transactions =
                      snapshot.data ?? const <Transaction>[];
                  if (transactions.isEmpty) {
                    return const Center(
                      child: Text('No transactions found for this import.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final Transaction transaction = transactions[index];
                      final bool income = isIncome(transaction.category);

                      return ListTile(
                        dense: true,
                        title: Text(
                          transaction.merchant,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${dateFormatter.format(transaction.date)} · '
                          '${transaction.category} / ${transaction.subcategory}',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        trailing: Text(
                          currencyFormatter.format(transaction.amount),
                          style: AppTextStyles.cardTitle.copyWith(
                            color: income ? AppColors.green : AppColors.red,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () async {
                          Navigator.of(dialogContext).pop();
                          await showTransactionForm(
                            parentContext,
                            orgId: orgId,
                            initialTransaction: transaction,
                          );
                        },
                      );
                    },
                  );
                },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

class _CsvImportFlowContent extends ConsumerStatefulWidget {
  const _CsvImportFlowContent({
    required this.orgId,
    required this.existingTransactions,
  });

  final String orgId;
  final List<Transaction> existingTransactions;

  @override
  ConsumerState<_CsvImportFlowContent> createState() =>
      _CsvImportFlowContentState();
}

class _CsvImportFlowContentState extends ConsumerState<_CsvImportFlowContent> {
  CsvInstitution _selectedInstitution = CsvInstitution.ent;
  String? _filename;
  String? _rawCsv;
  int? _newCount;
  int? _duplicatesSkipped;
  String? _previewError;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final bool canImport =
        _rawCsv != null &&
        _previewError == null &&
        !_isImporting &&
        _newCount != null;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Import CSV', style: AppTextStyles.cardTitle),
          const SizedBox(height: AppConstants.spacingMd),
          DropdownButtonFormField<CsvInstitution>(
            initialValue: _selectedInstitution,
            decoration: const InputDecoration(labelText: 'Institution'),
            items: CsvInstitution.values
                .map(
                  (CsvInstitution institution) =>
                      DropdownMenuItem<CsvInstitution>(
                        value: institution,
                        child: Text(institution.label),
                      ),
                )
                .toList(growable: false),
            onChanged: (CsvInstitution? value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedInstitution = value;
              });
              _recomputePreview();
            },
          ),
          const SizedBox(height: AppConstants.spacingMd),
          OutlinedButton.icon(
            onPressed: _isImporting ? null : _pickCsvFile,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(
              _filename == null ? 'Pick CSV file' : 'Change CSV file',
            ),
          ),
          if (_filename != null) ...<Widget>[
            const SizedBox(height: AppConstants.spacingSm),
            Text('File: $_filename', style: AppTextStyles.body),
          ],
          if (_previewError != null) ...<Widget>[
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              _previewError!,
              style: AppTextStyles.body.copyWith(color: AppColors.red),
            ),
          ],
          if (_newCount != null && _duplicatesSkipped != null) ...<Widget>[
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              '$_newCount new transactions found '
              '($_duplicatesSkipped duplicates skipped)',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: AppConstants.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: _isImporting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              ElevatedButton(
                onPressed: canImport ? _runImport : null,
                child: _isImporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Import'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickCsvFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['csv'],
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final PlatformFile file = result.files.single;
    final String? filename = file.name.trim().isEmpty ? null : file.name;
    final List<int>? bytes = file.bytes;

    if (filename == null || bytes == null) {
      setState(() {
        _previewError = 'Unable to read the selected CSV file.';
        _rawCsv = null;
        _newCount = null;
        _duplicatesSkipped = null;
      });
      return;
    }

    final String rawCsv = utf8.decode(bytes, allowMalformed: true);
    setState(() {
      _filename = filename;
      _rawCsv = rawCsv;
    });
    _recomputePreview();
  }

  void _recomputePreview() {
    final String? rawCsv = _rawCsv;
    if (rawCsv == null) {
      return;
    }

    final CsvColumnMap map = kCsvInstitutionMaps[_selectedInstitution]!;

    try {
      final List<CsvRow> parsedRows = parseCsv(rawCsv, map);
      final List<CsvRow> deduplicatedRows = deduplicateCsvRows(
        parsedRows,
        widget.existingTransactions,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _previewError = null;
        _newCount = deduplicatedRows.length;
        _duplicatesSkipped = parsedRows.length - deduplicatedRows.length;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _newCount = null;
        _duplicatesSkipped = null;
        _previewError = 'Unable to parse CSV for this institution mapping.';
      });
    }
  }

  Future<void> _runImport() async {
    final String? rawCsv = _rawCsv;
    final String? filename = _filename;
    if (rawCsv == null || filename == null) {
      return;
    }

    final String? userId = ref
        .read(supabaseClientProvider)
        .auth
        .currentUser
        ?.id;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (userId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('You must be signed in to import CSVs.')),
      );
      return;
    }

    setState(() {
      _isImporting = true;
    });

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(const SnackBar(content: Text('Importing...')));

    try {
      final CsvImportLog log = await ref
          .read(csvImportControllerProvider.notifier)
          .runImport(
            institution: _selectedInstitution,
            filename: filename,
            rawCsv: rawCsv,
            orgId: widget.orgId,
            createdBy: userId,
          );

      if (!mounted) {
        return;
      }

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Imported ${log.transactionCount} transactions'),
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to import CSV right now.')),
      );
      setState(() {
        _isImporting = false;
      });
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isImporting = false;
    });
  }
}
