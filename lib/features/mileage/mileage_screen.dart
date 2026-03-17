import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'layouts/mobile/mileage_mobile_screen.dart';
import 'layouts/web/mileage_web_screen.dart';

class MileageScreen extends StatelessWidget {
  const MileageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile ? const MileageMobileScreen() : const MileageWebScreen();
  }
}
