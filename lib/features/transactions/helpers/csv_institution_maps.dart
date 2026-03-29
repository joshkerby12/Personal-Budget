enum CsvInstitution {
  ent('Ent Credit Union'),
  samsClub("Sam's Club");

  const CsvInstitution(this.label);
  final String label;
}

class CsvColumnMap {
  const CsvColumnMap({
    required this.dateColumn,
    required this.merchantColumn,
    required this.amountColumn,
    required this.dateFormat,
    required this.negativeIsExpense,
  });

  final String dateColumn;
  final String merchantColumn;
  final String amountColumn;
  final String dateFormat;

  /// If true, negative amount = expense and positive = income.
  /// If false, positive amount = expense and negative = income.
  final bool negativeIsExpense;
}

const Map<CsvInstitution, CsvColumnMap> kCsvInstitutionMaps =
    <CsvInstitution, CsvColumnMap>{
      CsvInstitution.ent: CsvColumnMap(
        dateColumn: 'Date',
        merchantColumn: 'Description',
        amountColumn: 'Amount',
        dateFormat: 'MM/dd/yyyy',
        negativeIsExpense: true,
      ),
      CsvInstitution.samsClub: CsvColumnMap(
        dateColumn: 'Transaction Date',
        merchantColumn: 'Description',
        amountColumn: 'Amount',
        dateFormat: 'MM/dd/yyyy',
        negativeIsExpense: false,
      ),
    };
