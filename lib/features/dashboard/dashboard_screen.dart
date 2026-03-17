import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'layouts/mobile/dashboard_mobile_screen.dart';
import 'layouts/web/dashboard_web_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile
        ? const DashboardMobileScreen()
        : const DashboardWebScreen();
  }
}
