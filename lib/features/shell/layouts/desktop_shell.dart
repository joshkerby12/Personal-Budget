import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DesktopShell extends StatelessWidget {
  const DesktopShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<_DesktopTabItem> _tabs = <_DesktopTabItem>[
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

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
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
                  ],
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
                children: _tabs.map((_DesktopTabItem tab) {
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
                }).toList(),
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
