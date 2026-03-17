import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/current_org_provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../transactions/presentation/widgets/transaction_form.dart';

class MobileShell extends ConsumerStatefulWidget {
  const MobileShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends ConsumerState<MobileShell> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<String?> orgIdAsync = ref.watch(currentOrgIdProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Kerby Family Budget',
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: 15,
            color: AppColors.white,
          ),
        ),
      ),
      body: widget.navigationShell,
      bottomNavigationBar: SizedBox(
        height: 84,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
            Positioned.fill(
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _bottomNavIndexForBranch(
                  widget.navigationShell.currentIndex,
                ),
                selectedItemColor: AppColors.teal,
                unselectedItemColor: AppColors.textMuted,
                backgroundColor: AppColors.white,
                onTap: (int index) => _onBottomNavTapped(context, index),
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined),
                    activeIcon: Icon(Icons.calendar_month),
                    label: 'Monthly',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.circle,
                      color: Colors.transparent,
                      size: 1,
                    ),
                    activeIcon: Icon(
                      Icons.circle,
                      color: Colors.transparent,
                      size: 1,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_outlined),
                    activeIcon: Icon(Icons.receipt_long),
                    label: 'Transactions',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.more_horiz),
                    activeIcon: Icon(Icons.more_horiz),
                    label: 'More',
                  ),
                ],
              ),
            ),
            Positioned(
              top: -28,
              child: FloatingActionButton(
                backgroundColor: AppColors.teal,
                foregroundColor: AppColors.white,
                shape: const CircleBorder(),
                onPressed: () => _openAddTransactionForm(context, orgIdAsync),
                child: const Icon(Icons.add, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _bottomNavIndexForBranch(int branchIndex) {
    switch (branchIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
      case 4:
      case 5:
        return 4;
      default:
        return 0;
    }
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        return;
      case 1:
        context.go(AppRoutes.monthly);
        return;
      case 2:
        return;
      case 3:
        context.go(AppRoutes.transactions);
        return;
      case 4:
        _showMoreSheet(context);
        return;
    }
  }

  void _openAddTransactionForm(
    BuildContext context,
    AsyncValue<String?> orgIdAsync,
  ) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    orgIdAsync.when(
      loading: () {
        messenger.showSnackBar(
          const SnackBar(content: Text('Loading organization...')),
        );
      },
      error: (Object error, StackTrace stackTrace) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Unable to open add transaction form.')),
        );
      },
      data: (String? orgId) {
        if (orgId == null) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('No organization found for this user.'),
            ),
          );
          return;
        }
        showTransactionForm(context, orgId: orgId);
      },
    );
  }

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.route_outlined),
                title: const Text('Mileage'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.go(AppRoutes.mileage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.business_center_outlined),
                title: const Text('Business'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.go(AppRoutes.business);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.go(AppRoutes.settings);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
