import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../receipts/helpers/receipt_formatters.dart';
import '../../../receipts/models/receipt.dart';
import '../../../receipts/presentation/providers/receipt_provider.dart';
import '../../../teller/helpers/teller_connect.dart';
import '../../../teller/models/teller_enrollment.dart';
import '../../../teller/presentation/providers/teller_provider.dart';
import '../../../transactions/helpers/transaction_calculations.dart';
import '../../helpers/settings_file_io.dart';
import '../../models/app_settings.dart';
import '../../models/budget_default.dart';
import '../providers/settings_provider.dart';

class SettingsEditor extends ConsumerStatefulWidget {
  const SettingsEditor({
    super.key,
    required this.orgId,
    required this.initialSettings,
    required this.initialBudgets,
    required this.isMobile,
    required this.showDataSection,
  });

  final String orgId;
  final AppSettings? initialSettings;
  final List<BudgetDefault> initialBudgets;
  final bool isMobile;
  final bool showDataSection;


  @override
  ConsumerState<SettingsEditor> createState() => _SettingsEditorState();
}

class _SettingsEditorState extends ConsumerState<SettingsEditor> {
  late final TextEditingController _irsRateController;
  late final ValueNotifier<List<_BudgetRow>> _rowsNotifier;
  late final ValueNotifier<Set<String>> _expandedCategoriesNotifier;
  late final ValueNotifier<Set<String>> _editingRowsNotifier;

  final Map<String, TextEditingController> _nameControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _amountControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _bizPctControllers =
      <String, TextEditingController>{};

  int _newRowCounter = 0;
  bool _isRegeneratingInviteCode = false;
  bool _isConnectingBankAccount = false;
  final Set<String> _pendingDeleteIds = <String>{};

  @override
  void initState() {
    super.initState();
    _irsRateController = TextEditingController();
    _rowsNotifier = ValueNotifier<List<_BudgetRow>>(<_BudgetRow>[]);
    _expandedCategoriesNotifier = ValueNotifier<Set<String>>(<String>{});
    _editingRowsNotifier = ValueNotifier<Set<String>>(<String>{});
    _hydrateFromSource(
      settings: widget.initialSettings,
      defaults: widget.initialBudgets,
      resetExpansion: true,
    );
  }

  @override
  void didUpdateWidget(covariant SettingsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSettings != widget.initialSettings ||
        oldWidget.initialBudgets != widget.initialBudgets ||
        oldWidget.orgId != widget.orgId) {
      _hydrateFromSource(
        settings: widget.initialSettings,
        defaults: widget.initialBudgets,
        resetExpansion: oldWidget.orgId != widget.orgId,
      );
    }
  }

  @override
  void dispose() {
    _irsRateController.dispose();
    _rowsNotifier.dispose();
    _expandedCategoriesNotifier.dispose();
    _editingRowsNotifier.dispose();
    _disposeRowControllers();
    super.dispose();
  }

  void _disposeRowControllers() {
    for (final TextEditingController controller in _nameControllers.values) {
      controller.dispose();
    }
    for (final TextEditingController controller in _amountControllers.values) {
      controller.dispose();
    }
    for (final TextEditingController controller in _bizPctControllers.values) {
      controller.dispose();
    }
    _nameControllers.clear();
    _amountControllers.clear();
    _bizPctControllers.clear();
  }

  void _hydrateFromSource({
    required AppSettings? settings,
    required List<BudgetDefault> defaults,
    required bool resetExpansion,
  }) {
    _irsRateController.text = (settings?.irsRatePerMile ?? 0.670)
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');

    _disposeRowControllers();

    final List<_BudgetRow> rows = <_BudgetRow>[];
    final Set<String> usedKeys = <String>{};
    for (final BudgetDefault item in defaults) {
      String key = item.id.isNotEmpty
          ? item.id
          : '${item.category}::${item.subcategory}';
      if (usedKeys.contains(key)) {
        key = '$key::${usedKeys.length}';
      }
      usedKeys.add(key);

      rows.add(
        _BudgetRow(
          localKey: key,
          id: item.id,
          category: item.category,
          isNew: false,
        ),
      );

      _nameControllers[key] = TextEditingController(text: item.subcategory);
      _amountControllers[key] = TextEditingController(
        text: item.monthlyAmount.toStringAsFixed(2),
      );
      _bizPctControllers[key] = TextEditingController(
        text: (item.defaultBizPct * 100).toStringAsFixed(0),
      );
    }

    _rowsNotifier.value = rows;
    _editingRowsNotifier.value = <String>{};

    if (resetExpansion) {
      _expandedCategoriesNotifier.value = rows.isEmpty
          ? <String>{}
          : <String>{rows.first.category};
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSubmitting =
        ref.watch(settingsControllerProvider).isLoading ||
        _isRegeneratingInviteCode;
    final Map<String, Map<String, double>> spendingAvgs = ref
        .watch(spendingAveragesProvider(widget.orgId))
        .valueOrNull ?? const <String, Map<String, double>>{};
    final AsyncValue<List<TellerEnrollment>> enrollmentsAsync = ref.watch(
      tellerEnrollmentsProvider(widget.orgId),
    );
    final bool isTellerLoading =
        ref.watch(tellerControllerProvider).isLoading ||
        _isConnectingBankAccount;
    final AsyncValue<String?> inviteCodeAsync = ref.watch(
      inviteCodeProvider(widget.orgId),
    );
    final AsyncValue<bool> isOwnerAsync = ref.watch(
      isCurrentUserOwnerProvider(widget.orgId),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Settings', style: AppTextStyles.pageTitle),
          const SizedBox(height: AppConstants.spacingMd),
          _buildInviteCard(
            inviteCodeAsync: inviteCodeAsync,
            isOwnerAsync: isOwnerAsync,
            isSubmitting: isSubmitting,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildConnectedAccountsCard(
            enrollmentsAsync: enrollmentsAsync,
            isBusy: isTellerLoading,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          if (widget.isMobile) ...<Widget>[
            _buildMileageRateCard(isSubmitting),
            const SizedBox(height: AppConstants.spacingMd),
            _buildBudgetDefaultsCard(isSubmitting, spendingAvgs),
          ] else ...<Widget>[
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool stackCards = constraints.maxWidth < 980;
                if (stackCards) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildMileageRateCard(isSubmitting),
                      const SizedBox(height: AppConstants.spacingMd),
                      _buildBudgetDefaultsCard(isSubmitting, spendingAvgs),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: _buildMileageRateCard(isSubmitting)),
                    const SizedBox(width: AppConstants.spacingMd),
                    Expanded(
                      flex: 2,
                      child: _buildBudgetDefaultsCard(isSubmitting, spendingAvgs),
                    ),
                  ],
                );
              },
            ),
          ],
          if (widget.showDataSection) ...<Widget>[
            const SizedBox(height: AppConstants.spacingMd),
            _buildDataSectionCard(isSubmitting),
          ],
        ],
      ),
    );
  }

  Widget _buildInviteCard({
    required AsyncValue<String?> inviteCodeAsync,
    required AsyncValue<bool> isOwnerAsync,
    required bool isSubmitting,
  }) {
    final String inviteCode = (inviteCodeAsync.valueOrNull ?? '')
        .trim()
        .toUpperCase();
    final bool isCodeLoading = inviteCodeAsync.isLoading;
    final bool canCopy =
        inviteCode.isNotEmpty && !isCodeLoading && !isSubmitting;
    final bool canRegenerate =
        isOwnerAsync.valueOrNull == true && !isCodeLoading && !isSubmitting;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Household Invite Code', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingXs),
            const Text(
              'Share this code with family members so they can join.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            if (inviteCodeAsync.hasError) ...<Widget>[
              const ErrorView(message: 'Unable to load invite code right now.'),
            ] else ...<Widget>[
              if (isCodeLoading) ...<Widget>[
                const LinearProgressIndicator(minHeight: 2),
                const SizedBox(height: AppConstants.spacingSm),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                  vertical: AppConstants.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppConstants.spacingSm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  inviteCode.isEmpty ? '......' : inviteCode,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Wrap(
                spacing: AppConstants.spacingSm,
                runSpacing: AppConstants.spacingSm,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: canCopy
                        ? () => _copyInviteCode(inviteCode)
                        : null,
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy'),
                  ),
                  if (isOwnerAsync.valueOrNull == true)
                    ElevatedButton.icon(
                      onPressed: canRegenerate ? _regenerateInviteCode : null,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Regenerate'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedAccountsCard({
    required AsyncValue<List<TellerEnrollment>> enrollmentsAsync,
    required bool isBusy,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Connected Bank Accounts',
                    style: AppTextStyles.cardTitle,
                  ),
                ),
                ElevatedButton(
                  onPressed: isBusy ? null : _connectBankAccount,
                  child: const Text('Connect Account'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingXs),
            const Text(
              'Connect your bank to import transactions automatically.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            if (isBusy) ...<Widget>[
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: AppConstants.spacingSm),
            ],
            enrollmentsAsync.when(
              loading: () => const Text(
                'Loading connected accounts...',
                style: AppTextStyles.body,
              ),
              error: (Object error, StackTrace stackTrace) => const ErrorView(
                message: 'Unable to load connected accounts right now.',
              ),
              data: (List<TellerEnrollment> enrollments) {
                if (enrollments.isEmpty) {
                  return const Text(
                    'No bank accounts connected.',
                    style: AppTextStyles.body,
                  );
                }

                return Column(
                  children: enrollments
                      .map(
                        (TellerEnrollment enrollment) =>
                            _buildConnectedAccountRow(
                              enrollment,
                              isBusy: isBusy,
                            ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedAccountRow(
    TellerEnrollment enrollment, {
    required bool isBusy,
  }) {
    final String accountLastFour =
        enrollment.accountLastFour == null ||
            enrollment.accountLastFour!.trim().isEmpty
        ? ''
        : ' ••••${enrollment.accountLastFour}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.spacingSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${enrollment.institutionName} • ${enrollment.accountName}$accountLastFour',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            'Last synced: ${_formatLastSynced(enrollment.lastSyncedAt)}',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            children: <Widget>[
              OutlinedButton(
                onPressed: isBusy ? null : () => _syncNow(enrollment),
                child: const Text('Sync Now'),
              ),
              TextButton(
                onPressed: isBusy
                    ? null
                    : () => _disconnectEnrollment(enrollment),
                style: TextButton.styleFrom(foregroundColor: AppColors.red),
                child: const Text('Disconnect'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLastSynced(DateTime? value) {
    if (value == null) {
      return 'Never';
    }
    return DateFormat('MMM d, y \'at\' h:mm a').format(value.toLocal());
  }

  Future<void> _connectBankAccount() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String appId = (SupabaseConstants.tellerAppId ?? '').trim();
    if (appId.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Missing TELLER_APP_ID in your .env file.'),
        ),
      );
      return;
    }

    setState(() {
      _isConnectingBankAccount = true;
    });

    try {
      launchTellerConnect(
        appId: appId,
        onSuccess: (String enrollmentId, String accessToken) {
          unawaited(_completeTellerEnrollment(enrollmentId, accessToken));
        },
        onError: (String message) {
          if (!mounted) {
            return;
          }
          setState(() {
            _isConnectingBankAccount = false;
          });
          if (message == 'Teller Connect was canceled.') {
            return;
          }
          messenger.showSnackBar(SnackBar(content: Text(message)));
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isConnectingBankAccount = false;
      });
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to launch Teller Connect right now.'),
        ),
      );
    }
  }

  Future<void> _completeTellerEnrollment(
    String enrollmentId,
    String accessToken,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(tellerControllerProvider.notifier)
          .enroll(widget.orgId, enrollmentId, accessToken);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Connected! Importing transactions...')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to connect account right now.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isConnectingBankAccount = false;
        });
      }
    }
  }

  Future<void> _syncNow(TellerEnrollment enrollment) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final int imported = await ref
          .read(tellerControllerProvider.notifier)
          .syncNow(widget.orgId, enrollment.id);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text('Imported $imported transactions')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to sync account right now.')),
      );
    }
  }

  Future<void> _disconnectEnrollment(TellerEnrollment enrollment) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool? shouldDisconnect = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Disconnect bank account?'),
          content: Text(
            'Disconnect ${enrollment.institutionName} • ${enrollment.accountName}? '
            'You can reconnect later.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Disconnect'),
            ),
          ],
        );
      },
    );

    if (shouldDisconnect != true) {
      return;
    }

    try {
      await ref
          .read(tellerControllerProvider.notifier)
          .disconnect(widget.orgId, enrollment.id);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Bank account disconnected')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to disconnect account right now.'),
        ),
      );
    }
  }

  Widget _buildMileageRateCard(bool isSubmitting) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Mileage Rate', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _irsRateController,
              enabled: !isSubmitting,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'IRS Rate Per Mile',
                prefixText: r'$ ',
                helperText: 'Update each January when IRS publishes new rate',
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _saveRate,
                child: const Text('Save Rate'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetDefaultsCard(
    bool isSubmitting,
    Map<String, Map<String, double>> spendingAvgs,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Monthly Budget Defaults', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingSm),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppConstants.spacingSm,
              runSpacing: AppConstants.spacingSm,
              children: <Widget>[
                ElevatedButton(
                  onPressed: isSubmitting ? null : _saveBudgets,
                  child: const Text('Save All Budgets'),
                ),
                OutlinedButton(
                  onPressed: isSubmitting ? null : _resetToDefaults,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                  ),
                  child: const Text('Reset to Defaults'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ValueListenableBuilder<List<_BudgetRow>>(
              valueListenable: _rowsNotifier,
              builder:
                  (BuildContext context, List<_BudgetRow> rows, Widget? child) {
                    if (rows.isEmpty) {
                      return const Text(
                        'No budget defaults yet.',
                        style: AppTextStyles.body,
                      );
                    }

                    final LinkedHashMap<String, List<_BudgetRow>> grouped =
                        _groupByCategory(rows);
                    return widget.isMobile
                        ? _buildMobileBudgetGroups(grouped, spendingAvgs)
                        : _buildDesktopBudgetGroups(grouped, spendingAvgs);
                  },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopBudgetGroups(
    LinkedHashMap<String, List<_BudgetRow>> grouped,
    Map<String, Map<String, double>> spendingAvgs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: grouped.entries
          .map((MapEntry<String, List<_BudgetRow>> entry) {
            final String category = entry.key;
            final List<_BudgetRow> rows = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    color: AppColors.navy,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                      vertical: AppConstants.spacingSm,
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Container(
                    color: AppColors.lightGray,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                      vertical: AppConstants.spacingXs,
                    ),
                    child: Row(
                      children: const <Widget>[
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Subcategory',
                            style: AppTextStyles.label,
                          ),
                        ),
                        SizedBox(width: AppConstants.spacingSm),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Monthly Amount',
                            style: AppTextStyles.label,
                          ),
                        ),
                        SizedBox(width: AppConstants.spacingSm),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Default Biz %',
                            style: AppTextStyles.label,
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    onReorder: (int oldIndex, int newIndex) => _moveRow(
                      category,
                      oldIndex,
                      newIndex > oldIndex ? newIndex - 1 : newIndex,
                    ),
                    children: rows
                        .asMap()
                        .entries
                        .map(
                          (MapEntry<int, _BudgetRow> e) => _buildDesktopRow(
                            e.value,
                            index: e.key,
                            spendingAvgs: spendingAvgs,
                          ),
                        )
                        .toList(growable: false),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _addSubcategory(category),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('+ Add subcategory'),
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }

  Widget _buildDesktopRow(
    _BudgetRow row, {
    required int index,
    required Map<String, Map<String, double>> spendingAvgs,
  }) {
    return Container(
      key: ValueKey<String>(row.localKey),
      color: row.isNew ? AppColors.greenFill : AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingXs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 2),
              child: Icon(
                Icons.drag_handle,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(flex: 3, child: _buildSubcategoryCell(row, compact: false)),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            flex: 2,
            child: _buildAmountField(row, compact: false, spendingAvgs: spendingAvgs),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(flex: 2, child: _buildBizPctField(row, compact: false)),
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: () => _deleteRow(row),
              icon: const Icon(Icons.delete_outline),
              color: AppColors.red,
              tooltip: 'Delete subcategory',
            ),
          ),
        ],
      ),
    );
  }

  void _moveRow(String category, int fromIndex, int toIndex) {
    final List<_BudgetRow> current = List<_BudgetRow>.from(_rowsNotifier.value);
    final List<int> indices = <int>[
      for (int i = 0; i < current.length; i++)
        if (current[i].category == category) i,
    ];
    if (fromIndex >= indices.length || toIndex >= indices.length) return;
    final int fromGlobal = indices[fromIndex];
    final int toGlobal = indices[toIndex];
    final _BudgetRow moved = current.removeAt(fromGlobal);
    current.insert(toGlobal, moved);
    _rowsNotifier.value = current;
  }

  Widget _buildMobileBudgetGroups(
    LinkedHashMap<String, List<_BudgetRow>> grouped,
    Map<String, Map<String, double>> spendingAvgs,
  ) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: _expandedCategoriesNotifier,
      builder: (BuildContext context, Set<String> expanded, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: grouped.entries
              .map((MapEntry<String, List<_BudgetRow>> entry) {
                final bool isExpanded = expanded.contains(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppConstants.spacingSm,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppConstants.spacingSm,
                      ),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () => _toggleCategoryExpanded(entry.key),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.navy,
                              borderRadius: BorderRadius.vertical(
                                top: const Radius.circular(
                                  AppConstants.spacingSm,
                                ),
                                bottom: Radius.circular(
                                  isExpanded ? 0 : AppConstants.spacingSm,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingMd,
                              vertical: AppConstants.spacingSm,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: AppTextStyles.cardTitle.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: AppColors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded) ...<Widget>[
                          Padding(
                            padding: const EdgeInsets.all(
                              AppConstants.spacingSm,
                            ),
                            child: Column(
                              children: <Widget>[
                                ...entry.value.map(
                                  (_BudgetRow r) =>
                                      _buildMobileRow(r, spendingAvgs),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: () => _addSubcategory(entry.key),
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('+ Add subcategory'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildMobileRow(
    _BudgetRow row,
    Map<String, Map<String, double>> spendingAvgs,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      decoration: BoxDecoration(
        color: row.isNew ? AppColors.greenFill : AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.spacingSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildSubcategoryCell(row, compact: true),
          const SizedBox(height: AppConstants.spacingSm),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildAmountField(
                  row,
                  compact: true,
                  spendingAvgs: spendingAvgs,
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(child: _buildBizPctField(row, compact: true)),
              IconButton(
                onPressed: () => _deleteRow(row),
                icon: const Icon(Icons.delete_outline),
                color: AppColors.red,
                tooltip: 'Delete subcategory',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryCell(_BudgetRow row, {required bool compact}) {
    final TextEditingController controller = _nameControllers[row.localKey]!;

    return ValueListenableBuilder<Set<String>>(
      valueListenable: _editingRowsNotifier,
      builder: (BuildContext context, Set<String> editingRows, Widget? child) {
        final bool isEditing = row.isNew || editingRows.contains(row.localKey);

        if (isEditing) {
          return TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Subcategory',
              isDense: compact,
              filled: true,
              fillColor: row.isNew ? AppColors.greenFill : AppColors.amberFill,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.amber),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: AppColors.amber,
                  width: 1.5,
                ),
              ),
            ),
            onSubmitted: (_) => _toggleRowEditing(row.localKey, false),
          );
        }

        return InkWell(
          onTap: () => _toggleRowEditing(row.localKey, true),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingSm,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    controller.text,
                    style: AppTextStyles.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.amber,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountField(
    _BudgetRow row, {
    required bool compact,
    required Map<String, Map<String, double>> spendingAvgs,
  }) {
    final TextEditingController controller = _amountControllers[row.localKey]!;
    final String subcategory = _nameControllers[row.localKey]?.text ?? '';
    final double? avg = spendingAvgs[row.category]?[subcategory];

    return ValueListenableBuilder<Set<String>>(
      valueListenable: _editingRowsNotifier,
      builder: (BuildContext context, Set<String> editingRows, _) {
        final bool isEditing = row.isNew || editingRows.contains(row.localKey);
        if (isEditing) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: compact ? 'Amount' : 'Monthly Amount',
                  prefixText: r'$ ',
                  isDense: compact,
                  filled: true,
                  fillColor:
                      row.isNew ? AppColors.greenFill : AppColors.amberFill,
                ),
              ),
              if (avg != null)
                GestureDetector(
                  onTap: () {
                    controller.text = avg.toStringAsFixed(2);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '3-mo avg: \$${avg.toStringAsFixed(2)} — tap to use',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.navy,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
        final double? currentAmount = double.tryParse(controller.text);
        final bool isUnset = currentAmount == null || currentAmount == 0;
        final bool isDifferent = avg != null &&
            currentAmount != null &&
            currentAmount > 0 &&
            (currentAmount - avg).abs() > 0.99;

        if (isUnset && avg != null) {
          return InkWell(
            onTap: () {
              controller.text = avg.toStringAsFixed(2);
              _toggleRowEditing(row.localKey, true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingXs,
              ),
              child: Text(
                'Use avg: \$${avg.toStringAsFixed(2)}/mo',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () => _toggleRowEditing(row.localKey, true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingXs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('\$${controller.text}', style: AppTextStyles.body),
                    if (avg != null && !isDifferent)
                      Text(
                        '3-mo avg: \$${avg.toStringAsFixed(2)}',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isDifferent)
              InkWell(
                onTap: () {
                  controller.text = avg.toStringAsFixed(2);
                  _toggleRowEditing(row.localKey, true);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    'Avg \$${avg.toStringAsFixed(2)} — update?',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.amber,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBizPctField(_BudgetRow row, {required bool compact}) {
    final TextEditingController controller = _bizPctControllers[row.localKey]!;
    return ValueListenableBuilder<Set<String>>(
      valueListenable: _editingRowsNotifier,
      builder: (BuildContext context, Set<String> editingRows, _) {
        final bool isEditing = row.isNew || editingRows.contains(row.localKey);
        if (isEditing) {
          return TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: compact ? 'Biz %' : 'Default Biz %',
              suffixText: '%',
              isDense: compact,
              filled: true,
              fillColor: row.isNew ? AppColors.greenFill : AppColors.amberFill,
            ),
          );
        }
        return InkWell(
          onTap: () => _toggleRowEditing(row.localKey, true),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingSm,
            ),
            child: Text('${controller.text}%', style: AppTextStyles.body),
          ),
        );
      },
    );
  }

  Widget _buildDataSectionCard(bool isSubmitting) {
    final AsyncValue<List<Receipt>> receiptsAsync = ref.watch(
      receiptsProvider(widget.orgId),
    );
    final String storageUsageText = receiptsAsync.when(
      loading: () => 'Loading...',
      error: (Object error, StackTrace stackTrace) => 'Unavailable',
      data: (List<Receipt> receipts) {
        int totalBytes = 0;
        for (final Receipt receipt in receipts) {
          totalBytes += receipt.sizeBytes;
        }
        return formatStorageUsageMb(totalBytes);
      },
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Data', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingMd),
            Wrap(
              spacing: AppConstants.spacingSm,
              runSpacing: AppConstants.spacingSm,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: isSubmitting ? null : _exportData,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export Data'),
                ),
                OutlinedButton.icon(
                  onPressed: isSubmitting ? null : _importData,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Import Data'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Receipts storage: $storageUsageText',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  LinkedHashMap<String, List<_BudgetRow>> _groupByCategory(
    List<_BudgetRow> rows,
  ) {
    final Map<String, List<_BudgetRow>> grouped = <String, List<_BudgetRow>>{};
    for (final _BudgetRow row in rows) {
      grouped.putIfAbsent(row.category, () => <_BudgetRow>[]).add(row);
    }
    final List<String> sortedCategories = grouped.keys.toList()
      ..sort(compareCategoryOrder);
    final LinkedHashMap<String, List<_BudgetRow>> ordered =
        LinkedHashMap<String, List<_BudgetRow>>();
    for (final String cat in sortedCategories) {
      ordered[cat] = grouped[cat]!;
    }
    return ordered;
  }

  void _toggleCategoryExpanded(String category) {
    final Set<String> next = Set<String>.from(
      _expandedCategoriesNotifier.value,
    );
    if (next.contains(category)) {
      next.remove(category);
    } else {
      next.add(category);
    }
    _expandedCategoriesNotifier.value = next;
  }

  void _toggleRowEditing(String localKey, bool isEditing) {
    final Set<String> next = Set<String>.from(_editingRowsNotifier.value);
    if (isEditing) {
      next.add(localKey);
    } else {
      next.remove(localKey);
    }
    _editingRowsNotifier.value = next;
  }

  void _addSubcategory(String category) {
    final List<_BudgetRow> current = List<_BudgetRow>.from(_rowsNotifier.value);
    final String localKey =
        'new-${category.toLowerCase().replaceAll(' ', '-')}-${_newRowCounter++}';
    final _BudgetRow row = _BudgetRow(
      localKey: localKey,
      id: '',
      category: category,
      isNew: true,
    );

    final int insertIndex = current.lastIndexWhere(
      (_BudgetRow item) => item.category == category,
    );

    if (insertIndex == -1) {
      current.add(row);
    } else {
      current.insert(insertIndex + 1, row);
    }

    _nameControllers[localKey] = TextEditingController();
    _amountControllers[localKey] = TextEditingController(text: '0.00');
    _bizPctControllers[localKey] = TextEditingController(
      text: category == 'Business' ? '100' : '0',
    );

    _rowsNotifier.value = current;
    _toggleRowEditing(localKey, true);

    final Set<String> expanded = Set<String>.from(
      _expandedCategoriesNotifier.value,
    )..add(category);
    _expandedCategoriesNotifier.value = expanded;
  }

  void _deleteRow(_BudgetRow row) {
    if (row.id.isNotEmpty) {
      _pendingDeleteIds.add(row.id);
    }

    final List<_BudgetRow> current = List<_BudgetRow>.from(_rowsNotifier.value)
      ..removeWhere((_BudgetRow item) => item.localKey == row.localKey);

    _nameControllers.remove(row.localKey)?.dispose();
    _amountControllers.remove(row.localKey)?.dispose();
    _bizPctControllers.remove(row.localKey)?.dispose();

    final Set<String> editing = Set<String>.from(_editingRowsNotifier.value)
      ..remove(row.localKey);

    _rowsNotifier.value = current;
    _editingRowsNotifier.value = editing;
  }

  Future<void> _copyInviteCode(String inviteCode) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (inviteCode.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No invite code available to copy.')),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!mounted) {
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('Invite code copied to clipboard')),
    );
  }

  Future<void> _regenerateInviteCode() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool? shouldRegenerate = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Generate new code?'),
          content: const Text(
            'Generate a new code? The old code will stop working.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Regenerate'),
            ),
          ],
        );
      },
    );

    if (shouldRegenerate != true) {
      return;
    }

    setState(() {
      _isRegeneratingInviteCode = true;
    });

    try {
      await ref
          .read(settingsInviteServiceProvider)
          .regenerateCode(widget.orgId);
      ref.invalidate(inviteCodeProvider(widget.orgId));
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        const SnackBar(content: Text('Invite code regenerated')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to regenerate code right now.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRegeneratingInviteCode = false;
        });
      }
    }
  }

  Future<void> _saveRate() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final double? rate = double.tryParse(_irsRateController.text.trim());
    if (rate == null || rate <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter a valid mileage rate.')),
      );
      return;
    }

    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .saveIrsRate(widget.orgId, rate);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('IRS mileage rate saved')),
      );

      final AppSettings? refreshed = await ref.refresh(
        appSettingsProvider(widget.orgId).future,
      );
      if (!mounted) {
        return;
      }
      _irsRateController.text = (refreshed?.irsRatePerMile ?? rate)
          .toStringAsFixed(3)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to save rate right now.')),
      );
    }
  }

  Future<void> _saveBudgets() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final List<BudgetDefault>? payload = _buildBudgetPayload();
    if (payload == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Check subcategory names, amounts, and business %.'),
        ),
      );
      return;
    }

    final List<String> deleteIds = List<String>.from(_pendingDeleteIds);

    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .saveBudgets(widget.orgId, payload, deleteIds: deleteIds);
      if (!mounted) {
        return;
      }
      _pendingDeleteIds.clear();
      messenger.showSnackBar(
        const SnackBar(content: Text('Budget defaults saved')),
      );

      final List<BudgetDefault> refreshedBudgets = await ref.refresh(
        budgetDefaultsProvider(widget.orgId).future,
      );
      final AppSettings? refreshedSettings = await ref.refresh(
        appSettingsProvider(widget.orgId).future,
      );
      if (!mounted) {
        return;
      }

      _hydrateFromSource(
        settings: refreshedSettings,
        defaults: refreshedBudgets,
        resetExpansion: false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to save budgets right now.')),
      );
    }
  }

  List<BudgetDefault>? _buildBudgetPayload() {
    final List<_BudgetRow> rows = _rowsNotifier.value;
    final List<BudgetDefault> payload = <BudgetDefault>[];
    final Set<String> uniqueness = <String>{};

    // Track per-category position to assign sort_order
    final Map<String, int> categoryIndex = <String, int>{};

    for (final _BudgetRow row in rows) {
      final String subcategory = _nameControllers[row.localKey]!.text.trim();
      final double? amount = _parseNumber(
        _amountControllers[row.localKey]!.text,
      );
      final double? bizPct = _parseNumber(
        _bizPctControllers[row.localKey]!.text,
      );

      if (subcategory.isEmpty || amount == null || amount < 0) {
        return null;
      }
      if (bizPct == null || bizPct < 0 || bizPct > 100) {
        return null;
      }

      final String key =
          '${row.category.toLowerCase()}::${subcategory.toLowerCase()}';
      if (uniqueness.contains(key)) {
        return null;
      }
      uniqueness.add(key);

      final int position = (categoryIndex[row.category] ?? 0) + 1;
      categoryIndex[row.category] = position;

      payload.add(
        BudgetDefault(
          id: row.id,
          orgId: widget.orgId,
          category: row.category,
          subcategory: subcategory,
          monthlyAmount: amount,
          defaultBizPct: (bizPct / 100).clamp(0, 1),
          month: null,
          sortOrder: position * 10,
        ),
      );
    }

    return payload;
  }

  Future<void> _resetToDefaults() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset to defaults?'),
          content: const Text(
            'This will reset all global budget defaults. '
            'Per-month overrides are not affected. Continue?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Reset',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) {
      return;
    }

    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .resetGlobalDefaults(widget.orgId);
      if (!mounted) {
        return;
      }

      final List<BudgetDefault> refreshed = await ref.refresh(
        budgetDefaultsProvider(widget.orgId).future,
      );
      if (!mounted) {
        return;
      }

      _hydrateFromSource(
        settings: widget.initialSettings,
        defaults: refreshed,
        resetExpansion: false,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Budget defaults reset')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to reset defaults right now.')),
      );
    }
  }

  Future<void> _exportData() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      final Map<String, dynamic> payload = await ref
          .read(settingsControllerProvider.notifier)
          .exportData(widget.orgId);
      final String pretty = const JsonEncoder.withIndent('  ').convert(payload);
      final String filename =
          'budget-settings-${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';

      await downloadJsonFile(filename, pretty);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Settings export downloaded')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to export data right now.')),
      );
    }
  }

  Future<void> _importData() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      final String? jsonContent = await pickJsonFileContent();
      if (jsonContent == null || jsonContent.trim().isEmpty) {
        return;
      }

      final dynamic decoded = jsonDecode(jsonContent);
      if (decoded is! Map<String, dynamic>) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Invalid JSON file format.')),
        );
        return;
      }

      await ref
          .read(settingsControllerProvider.notifier)
          .importData(widget.orgId, decoded);

      final AppSettings? refreshedSettings = await ref.refresh(
        appSettingsProvider(widget.orgId).future,
      );
      final List<BudgetDefault> refreshedBudgets = await ref.refresh(
        budgetDefaultsProvider(widget.orgId).future,
      );
      if (!mounted) {
        return;
      }

      _hydrateFromSource(
        settings: refreshedSettings,
        defaults: refreshedBudgets,
        resetExpansion: false,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Settings imported successfully')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to import data right now.')),
      );
    }
  }

  double? _parseNumber(String raw) {
    final String cleaned = raw.replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }
}

class _BudgetRow {
  const _BudgetRow({
    required this.localKey,
    required this.id,
    required this.category,
    required this.isNew,
  });

  final String localKey;
  final String id;
  final String category;
  final bool isNew;
}
