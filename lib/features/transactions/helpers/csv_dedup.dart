import '../models/transaction.dart';
import 'csv_parser.dart';

List<CsvRow> deduplicateCsvRows(List<CsvRow> rows, List<Transaction> existing) {
  final List<CsvRow> deduplicated = <CsvRow>[];
  int consecutiveMatches = 0;

  for (final CsvRow row in rows) {
    final bool matchesExisting = existing.any(
      (Transaction transaction) => _matchesRow(row, transaction),
    );

    if (matchesExisting) {
      consecutiveMatches += 1;
      if (consecutiveMatches >= 3) {
        break;
      }
      continue;
    }

    consecutiveMatches = 0;
    deduplicated.add(row);
  }

  return deduplicated;
}

bool _matchesRow(CsvRow row, Transaction transaction) {
  final DateTime rowDate = row.date;
  final DateTime existingDate = transaction.date;
  if (rowDate.year != existingDate.year ||
      rowDate.month != existingDate.month ||
      rowDate.day != existingDate.day) {
    return false;
  }

  if (_roundToCents(row.amount) != _roundToCents(transaction.amount)) {
    return false;
  }

  final String firstWord = _firstWord(row.merchant).toLowerCase();
  if (firstWord.isEmpty) {
    return false;
  }

  return transaction.merchant.toLowerCase().contains(firstWord);
}

int _roundToCents(double value) => (value * 100).round();

String _firstWord(String text) {
  final List<String> parts = text
      .trim()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList(growable: false);

  return parts.isEmpty ? '' : parts.first;
}
