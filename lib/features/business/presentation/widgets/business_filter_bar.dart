import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class BusinessFilterBar extends StatelessWidget {
  const BusinessFilterBar({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onYearChanged,
    required this.onMonthChanged,
  });

  final int? selectedYear;
  final int? selectedMonth;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<int?> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final int currentYear = DateTime.now().year;
    final List<int> yearOptions = List<int>.generate(
      5,
      (int index) => currentYear - 2 + index,
    );

    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      children: <Widget>[
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<int?>(
            key: ValueKey<int?>(selectedYear),
            initialValue: selectedYear,
            decoration: const InputDecoration(labelText: 'Year'),
            items: <DropdownMenuItem<int?>>[
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All Time'),
              ),
              ...yearOptions.map(
                (int year) => DropdownMenuItem<int?>(
                  value: year,
                  child: Text(year.toString()),
                ),
              ),
            ],
            onChanged: (int? value) {
              onYearChanged(value);
              if (value == null && selectedMonth != null) {
                onMonthChanged(null);
              }
            },
          ),
        ),
        SizedBox(
          width: 170,
          child: DropdownButtonFormField<int?>(
            key: ValueKey<int?>(selectedYear == null ? null : selectedMonth),
            initialValue: selectedYear == null ? null : selectedMonth,
            decoration: const InputDecoration(labelText: 'Month'),
            items: const <DropdownMenuItem<int?>>[
              DropdownMenuItem<int?>(value: null, child: Text('All Months')),
              DropdownMenuItem<int?>(value: 1, child: Text('Jan')),
              DropdownMenuItem<int?>(value: 2, child: Text('Feb')),
              DropdownMenuItem<int?>(value: 3, child: Text('Mar')),
              DropdownMenuItem<int?>(value: 4, child: Text('Apr')),
              DropdownMenuItem<int?>(value: 5, child: Text('May')),
              DropdownMenuItem<int?>(value: 6, child: Text('Jun')),
              DropdownMenuItem<int?>(value: 7, child: Text('Jul')),
              DropdownMenuItem<int?>(value: 8, child: Text('Aug')),
              DropdownMenuItem<int?>(value: 9, child: Text('Sep')),
              DropdownMenuItem<int?>(value: 10, child: Text('Oct')),
              DropdownMenuItem<int?>(value: 11, child: Text('Nov')),
              DropdownMenuItem<int?>(value: 12, child: Text('Dec')),
            ],
            onChanged: selectedYear == null ? null : onMonthChanged,
          ),
        ),
      ],
    );
  }
}
