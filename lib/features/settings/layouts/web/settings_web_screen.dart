import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_view.dart';
import '../../models/app_settings.dart';
import '../../models/budget_default.dart';
import '../../presentation/providers/settings_provider.dart';
import '../../presentation/widgets/settings_editor.dart';

class SettingsWebScreen extends ConsumerWidget {
  const SettingsWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> orgIdAsync = ref.watch(settingsOrgIdProvider);

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => const Center(
        child: ErrorView(message: 'Unable to load settings right now.'),
      ),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        final AsyncValue<AppSettings?> appSettingsAsync = ref.watch(
          appSettingsProvider(orgId),
        );
        final AsyncValue<List<BudgetDefault>> budgetsAsync = ref.watch(
          budgetDefaultsProvider(orgId),
        );

        if (appSettingsAsync.isLoading || budgetsAsync.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final Object? settingsError = appSettingsAsync.error;
        final Object? budgetsError = budgetsAsync.error;
        if (settingsError != null || budgetsError != null) {
          return const Center(
            child: ErrorView(message: 'Unable to load settings right now.'),
          );
        }

        final AppSettings? settings = appSettingsAsync.value;
        final List<BudgetDefault> budgets =
            budgetsAsync.value ?? const <BudgetDefault>[];

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.pagePaddingDesktop),
              child: SettingsEditor(
                key: ValueKey<String>('web-$orgId'),
                orgId: orgId,
                initialSettings: settings,
                initialBudgets: budgets,
                isMobile: false,
                showDataSection: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
