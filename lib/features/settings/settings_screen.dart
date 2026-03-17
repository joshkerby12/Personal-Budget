import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'layouts/mobile/settings_mobile_screen.dart';
import 'layouts/web/settings_web_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile ? const SettingsMobileScreen() : const SettingsWebScreen();
  }
}
