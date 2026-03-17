import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'layouts/mobile/receipts_mobile_screen.dart';
import 'layouts/web/receipts_web_screen.dart';

class ReceiptsScreen extends StatelessWidget {
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile ? const ReceiptsMobileScreen() : const ReceiptsWebScreen();
  }
}
