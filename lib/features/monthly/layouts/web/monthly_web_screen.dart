import 'package:flutter/material.dart';

import '../../widgets/monthly_budget_view.dart';

class MonthlyWebScreen extends StatelessWidget {
  const MonthlyWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MonthlyBudgetView(isMobile: false);
  }
}
