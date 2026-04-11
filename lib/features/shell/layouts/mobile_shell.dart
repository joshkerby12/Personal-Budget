import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_mode_provider.dart';
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
  static const int _pantryBranchStartIndex = 6;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<String?> orgIdAsync = ref.watch(currentOrgIdProvider);
    final AppMode selectedMode = ref.watch(appModeProvider);
    final AppMode routeMode =
        widget.navigationShell.currentIndex >= _pantryBranchStartIndex
        ? AppMode.pantry
        : AppMode.budget;
    final AppMode appMode = routeMode;

    if (selectedMode != routeMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(appModeProvider.notifier).state = routeMode;
      });
    }

    final bool showFab = _shouldShowFab(
      appMode,
      widget.navigationShell.currentIndex,
    );

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
        actions: <Widget>[
          IconButton(
            onPressed: () => _showMoreSheet(context),
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'More',
            color: AppColors.white,
          ),
          if (appMode == AppMode.pantry)
            IconButton(
              onPressed: () {
                ref.read(appModeProvider.notifier).state = AppMode.budget;
                context.go(AppRoutes.dashboard);
              },
              icon: const Icon(Icons.account_balance_wallet_outlined),
              tooltip: 'Back to Budget',
              color: AppColors.white,
            ),
        ],
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
                  appMode,
                ),
                selectedItemColor: AppColors.teal,
                unselectedItemColor: AppColors.textMuted,
                backgroundColor: AppColors.white,
                onTap: (int index) =>
                    _onBottomNavTapped(context, index, appMode),
                items: _bottomNavItems(appMode),
              ),
            ),
            if (showFab)
              Positioned(
                top: -28,
                child: FloatingActionButton(
                  backgroundColor: AppColors.teal,
                  foregroundColor: AppColors.white,
                  shape: const CircleBorder(),
                  onPressed: () => _onFabPressed(context, orgIdAsync, appMode),
                  child: const Icon(Icons.add, size: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowFab(AppMode appMode, int branchIndex) {
    if (appMode == AppMode.budget) {
      return true;
    }
    return branchIndex == 6 || branchIndex == 7;
  }

  List<BottomNavigationBarItem> _bottomNavItems(AppMode appMode) {
    if (appMode == AppMode.budget) {
      return <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: 'Monthly',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: _modeToggleIcon(AppMode.budget, false),
          activeIcon: _modeToggleIcon(AppMode.budget, true),
          label: 'Pantry',
        ),
      ];
    }

    return <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.list_alt_outlined),
        activeIcon: Icon(Icons.list_alt),
        label: 'Lists',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today_outlined),
        activeIcon: Icon(Icons.calendar_today),
        label: 'Meals',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.menu_book_outlined),
        activeIcon: Icon(Icons.menu_book),
        label: 'Cookbook',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.kitchen_outlined),
        activeIcon: Icon(Icons.kitchen),
        label: 'Pantry',
      ),
    ];
  }

  int _bottomNavIndexForBranch(int branchIndex, AppMode appMode) {
    if (appMode == AppMode.pantry) {
      switch (branchIndex) {
        case 6:
          return 0;
        case 7:
          return 1;
        case 8:
          return 2;
        case 10:
          return 3;
        default:
          return 0;
      }
    }

    switch (branchIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 2;
      default:
        return 0;
    }
  }

  void _onBottomNavTapped(BuildContext context, int index, AppMode appMode) {
    if (appMode == AppMode.budget) {
      switch (index) {
        case 0:
          context.go(AppRoutes.dashboard);
          return;
        case 1:
          context.go(AppRoutes.monthly);
          return;
        case 2:
          context.go(AppRoutes.transactions);
          return;
        case 3:
          ref.read(appModeProvider.notifier).state = AppMode.pantry;
          context.go(AppRoutes.pantryLists);
          return;
      }
      return;
    }

    switch (index) {
      case 0:
        context.go(AppRoutes.pantryLists);
        return;
      case 1:
        context.go(AppRoutes.pantryMeals);
        return;
      case 2:
        context.go(AppRoutes.pantryCookbook);
        return;
      case 3:
        context.go(AppRoutes.pantryPantry);
        return;
    }
  }

  Widget _modeToggleIcon(AppMode appMode, bool isActive) {
    final bool toPantry = appMode == AppMode.budget;
    final Color background = toPantry
        ? AppColors.tealLight
        : AppColors.amberFill;
    final Color borderColor = toPantry ? AppColors.teal : AppColors.amber;
    final Color iconColor = toPantry ? AppColors.teal : AppColors.amber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive ? borderColor : borderColor.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Icon(
        toPantry
            ? Icons.shopping_cart_checkout_outlined
            : Icons.account_balance_wallet_outlined,
        color: iconColor,
        size: 18,
      ),
    );
  }

  void _onFabPressed(
    BuildContext context,
    AsyncValue<String?> orgIdAsync,
    AppMode appMode,
  ) {
    if (appMode == AppMode.pantry) {
      _openPantryFabStub(context);
      return;
    }

    _openAddTransactionForm(context, orgIdAsync);
  }

  void _openPantryFabStub(BuildContext context) {
    final int branchIndex = widget.navigationShell.currentIndex;
    String? message;
    if (branchIndex == 6) {
      message = 'Add item — coming soon';
    } else if (branchIndex == 7) {
      message = 'Use + in Breakfast, Lunch, or Dinner to add meals.';
    }

    if (message == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
