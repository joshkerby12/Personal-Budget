import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_mode_provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DesktopShell extends ConsumerWidget {
  const DesktopShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int _pantryBranchStartIndex = 6;

  static const List<_DesktopTabItem> _budgetTabs = <_DesktopTabItem>[
    _DesktopTabItem(label: 'Dashboard', route: AppRoutes.dashboard, branch: 0),
    _DesktopTabItem(label: 'Monthly', route: AppRoutes.monthly, branch: 1),
    _DesktopTabItem(
      label: 'Transactions',
      route: AppRoutes.transactions,
      branch: 2,
    ),
    _DesktopTabItem(label: 'Mileage', route: AppRoutes.mileage, branch: 3),
    _DesktopTabItem(label: 'Business', route: AppRoutes.business, branch: 4),
    _DesktopTabItem(label: 'Settings', route: AppRoutes.settings, branch: 5),
  ];

  static const List<_DesktopTabItem> _pantryTabs = <_DesktopTabItem>[
    _DesktopTabItem(label: 'Lists', route: AppRoutes.pantryLists, branch: 6),
    _DesktopTabItem(label: 'Meals', route: AppRoutes.pantryMeals, branch: 7),
    _DesktopTabItem(
      label: 'Cookbook',
      route: AppRoutes.pantryCookbook,
      branch: 8,
    ),
    _DesktopTabItem(label: 'Deals', route: AppRoutes.pantryDeals, branch: 9),
    _DesktopTabItem(label: 'Pantry', route: AppRoutes.pantryPantry, branch: 10),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppMode selectedMode = ref.watch(appModeProvider);
    final AppMode routeMode = _isPantryBranch(navigationShell.currentIndex)
        ? AppMode.pantry
        : AppMode.budget;
    final AppMode appMode = routeMode;

    if (selectedMode != routeMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(appModeProvider.notifier).state = routeMode;
      });
    }

    final List<_DesktopTabItem> tabs = appMode == AppMode.budget
        ? _budgetTabs
        : _pantryTabs;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Column(
        children: <Widget>[
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingXxl,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[AppColors.navy, AppColors.teal],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  'Kerby Family Budget',
                  style: AppTextStyles.pageTitle.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  DateTime.now().year.toString(),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                _ModeToggleButton(
                  appMode: appMode,
                  onTap: () => _toggleMode(context, ref, appMode),
                ),
              ],
            ),
          ),
          Container(
            height: 44,
            width: double.infinity,
            color: AppColors.navy,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs
                    .map((_DesktopTabItem tab) {
                      final bool isActive =
                          navigationShell.currentIndex == tab.branch;
                      return InkWell(
                        onTap: () => context.go(tab.route),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isActive
                                    ? AppColors.teal
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              tab.label,
                              style: AppTextStyles.button.copyWith(
                                fontSize: 13,
                                color: isActive
                                    ? AppColors.white
                                    : AppColors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingDesktop,
              ),
              child: navigationShell,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMode(BuildContext context, WidgetRef ref, AppMode appMode) {
    if (appMode == AppMode.budget) {
      ref.read(appModeProvider.notifier).state = AppMode.pantry;
      context.go(AppRoutes.pantryLists);
      return;
    }

    ref.read(appModeProvider.notifier).state = AppMode.budget;
    context.go(AppRoutes.dashboard);
  }

  bool _isPantryBranch(int branchIndex) {
    return branchIndex >= _pantryBranchStartIndex && branchIndex <= 10;
  }
}

class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({required this.appMode, required this.onTap});

  final AppMode appMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool toPantry = appMode == AppMode.budget;
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        backgroundColor: toPantry
            ? AppColors.tealLight.withValues(alpha: 0.8)
            : AppColors.amberFill.withValues(alpha: 0.95),
        foregroundColor: toPantry ? AppColors.navy : AppColors.amber,
        textStyle: AppTextStyles.button.copyWith(
          fontSize: 12,
          color: toPantry ? AppColors.navy : AppColors.amber,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      onPressed: onTap,
      child: Text(toPantry ? 'Pantry & Plan →' : '← Budget'),
    );
  }
}

class _DesktopTabItem {
  const _DesktopTabItem({
    required this.label,
    required this.route,
    required this.branch,
  });

  final String label;
  final String route;
  final int branch;
}
