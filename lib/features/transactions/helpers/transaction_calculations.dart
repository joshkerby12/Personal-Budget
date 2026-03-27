import '../models/transaction.dart';

/// Dollar amount attributed to personal use.
double calculatePersonalAmount(double amount, double bizPct) =>
    amount * (1 - bizPct);

/// Dollar amount attributed to business use.
double calculateBusinessAmount(double amount, double bizPct) => amount * bizPct;

bool isIncome(String category) => category == 'Income';

bool isTransfer(String category) => category == 'Transfers';

/// Canonical display order for parent categories.
/// Income first, then expenses in budget-priority order.
const List<String> kCategoryOrder = <String>[
  'Income',
  'Housing',
  'Food',
  'Transportation',
  'Healthcare',
  'Children',
  'Personal',
  'Savings',
  'Debt',
  'Business',
  'Giving',
  'Transfers',
  'Other',
];

/// Sorts a list of category names by [kCategoryOrder].
/// Unknown categories sort to the end alphabetically.
int compareCategoryOrder(String a, String b) {
  final int ai = kCategoryOrder.indexOf(a);
  final int bi = kCategoryOrder.indexOf(b);
  if (ai == -1 && bi == -1) return a.compareTo(b);
  if (ai == -1) return 1;
  if (bi == -1) return -1;
  return ai.compareTo(bi);
}

/// Summary totals for a list of transactions.
({double income, double expenses, double net, double businessTotal})
calculateTransactionSummary(List<Transaction> transactions) {
  double income = 0;
  double expenses = 0;
  double businessTotal = 0;

  for (final Transaction transaction in transactions) {
    if (isIncome(transaction.category)) {
      income += transaction.amount;
    } else if (!isTransfer(transaction.category)) {
      expenses += transaction.amount;
      businessTotal += calculateBusinessAmount(
        transaction.amount,
        transaction.bizPct,
      );
    }
  }

  return (
    income: income,
    expenses: expenses,
    net: income - expenses,
    businessTotal: businessTotal,
  );
}
