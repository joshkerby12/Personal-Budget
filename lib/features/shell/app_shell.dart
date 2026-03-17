import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import 'layouts/desktop_shell.dart';
import 'layouts/mobile_shell.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile
        ? MobileShell(navigationShell: navigationShell)
        : DesktopShell(navigationShell: navigationShell);
  }
}
