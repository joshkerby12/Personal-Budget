import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/business/business_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/mileage/mileage_screen.dart';
import '../../features/monthly/monthly_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/transactions/transactions_screen.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_routes.dart';
import 'router_notifier.dart';

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final RouterNotifier routerNotifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.root,
    refreshListenable: routerNotifier,
    redirect: routerNotifier.redirect,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.root,
        name: AppRoutes.rootName,
        builder: (BuildContext context, GoRouterState state) =>
            const _RoutePlaceholder(
              title: AppConstants.appTitle,
              description: 'Starting app...',
            ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (BuildContext context, GoRouterState state) =>
            const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signupName,
        builder: (BuildContext context, GoRouterState state) =>
            const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPasswordName,
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.dashboard,
                name: AppRoutes.dashboardName,
                builder: (BuildContext context, GoRouterState state) =>
                    const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.monthly,
                name: AppRoutes.monthlyName,
                builder: (BuildContext context, GoRouterState state) =>
                    const MonthlyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.transactions,
                name: AppRoutes.transactionsName,
                builder: (BuildContext context, GoRouterState state) =>
                    const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.mileage,
                name: AppRoutes.mileageName,
                builder: (BuildContext context, GoRouterState state) =>
                    const MileageScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.business,
                name: AppRoutes.businessName,
                builder: (BuildContext context, GoRouterState state) =>
                    const BusinessScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settings,
                name: AppRoutes.settingsName,
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _RoutePlaceholder extends ConsumerWidget {
  const _RoutePlaceholder({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Card(
            color: AppColors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.spacingSm),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingXxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: AppTextStyles.pageTitle),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(description, style: AppTextStyles.body),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
