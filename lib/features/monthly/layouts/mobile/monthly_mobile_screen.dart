import 'package:flutter/material.dart';

import '../../widgets/monthly_budget_view.dart';

class MonthlyMobileScreen extends StatelessWidget {
  const MonthlyMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MonthlyBudgetView(isMobile: true);
  }
}
