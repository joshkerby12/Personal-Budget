import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import 'csv_institution_maps.dart';

class CsvRow {
  const CsvRow({
    required this.date,
    required this.merchant,
    required this.amount,
    required this.isIncome,
  });

  final DateTime date;
  final String merchant;
  final double amount;
  final bool isIncome;
}

List<CsvRow> parseCsv(String rawCsv, CsvColumnMap map) {
  final String normalizedCsv = rawCsv.replaceFirst('\uFEFF', '').trim();
  if (normalizedCsv.isEmpty) {
    return const <CsvRow>[];
  }

  final List<List<dynamic>> table = const CsvToListConverter(
    shouldParseNumbers: false,
    eol: '\n',
  ).convert(normalizedCsv);

  if (table.isEmpty) {
    return const <CsvRow>[];
  }

  final List<String> headers = table.first
      .map((dynamic value) => _cellToString(value).trim())
      .toList(growable: false);

  final int dateIndex = headers.indexOf(map.dateColumn);
  final int merchantIndex = headers.indexOf(map.merchantColumn);
  final int amountIndex = headers.indexOf(map.amountColumn);

  if (dateIndex == -1 || merchantIndex == -1 || amountIndex == -1) {
    throw const FormatException('CSV file is missing required columns.');
  }

  final DateFormat dateFormatter = DateFormat(map.dateFormat);
  final List<CsvRow> rows = <CsvRow>[];

  for (final List<dynamic> row in table.skip(1)) {
    final String dateValue = _valueAt(row, dateIndex).trim();
    final String merchantValue = _valueAt(row, merchantIndex).trim();
    final String amountValue = _valueAt(row, amountIndex).trim();

    if (dateValue.isEmpty || amountValue.isEmpty) {
      continue;
    }

    DateTime parsedDate;
    try {
      parsedDate = dateFormatter.parseStrict(dateValue);
    } catch (_) {
      continue;
    }

    final double? signedAmount = _parseAmount(amountValue);
    if (signedAmount == null || signedAmount == 0) {
      continue;
    }

    final bool isIncome = map.negativeIsExpense
        ? signedAmount > 0
        : signedAmount < 0;

    rows.add(
      CsvRow(
        date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
        merchant: merchantValue,
        amount: signedAmount.abs(),
        isIncome: isIncome,
      ),
    );
  }

  return rows;
}

String _valueAt(List<dynamic> row, int index) {
  if (index < 0 || index >= row.length) {
    return '';
  }
  return _cellToString(row[index]);
}

String _cellToString(dynamic value) => value?.toString() ?? '';

double? _parseAmount(String raw) {
  String normalized = raw
      .replaceAll(r'$', '')
      .replaceAll(',', '')
      .replaceAll('\r', '')
      .trim();

  if (normalized.isEmpty) {
    return null;
  }

  if (normalized.startsWith('(') && normalized.endsWith(')')) {
    normalized = '-${normalized.substring(1, normalized.length - 1)}';
  }

  return double.tryParse(normalized);
}
