import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'layouts/mobile/monthly_mobile_screen.dart';
import 'layouts/web/monthly_web_screen.dart';

class MonthlyScreen extends StatelessWidget {
  const MonthlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile ? const MonthlyMobileScreen() : const MonthlyWebScreen();
  }
}
