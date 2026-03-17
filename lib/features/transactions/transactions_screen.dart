import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'layouts/mobile/transactions_mobile_screen.dart';
import 'layouts/web/transactions_web_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile
        ? const TransactionsMobileScreen()
        : const TransactionsWebScreen();
  }
}
