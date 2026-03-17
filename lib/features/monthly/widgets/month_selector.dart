import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MonthSelector extends StatefulWidget {
  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  final int selectedMonth;
  final ValueChanged<int> onChanged;

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const double _chipWidth = 76;
  static const double _chipSpacing = AppConstants.spacingSm;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
  }

  @override
  void didUpdateWidget(covariant MonthSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        separatorBuilder: (_, _) => const SizedBox(width: _chipSpacing),
        itemBuilder: (BuildContext context, int index) {
          final int month = index + 1;
          final bool isSelected = month == widget.selectedMonth;
          return SizedBox(
            width: _chipWidth,
            child: OutlinedButton(
              onPressed: () => widget.onChanged(month),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(
                  color: isSelected ? AppColors.teal : AppColors.teal,
                ),
                backgroundColor: isSelected ? AppColors.teal : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                _months[index],
                style: AppTextStyles.button.copyWith(
                  color: isSelected ? AppColors.white : AppColors.teal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _scrollToActive() {
    if (!_scrollController.hasClients) {
      return;
    }

    final double viewportWidth = _scrollController.position.viewportDimension;
    final double targetIndexOffset =
        (widget.selectedMonth - 1) * (_chipWidth + _chipSpacing);
    final double centeredOffset = targetIndexOffset - (viewportWidth / 2) + 40;
    final double maxOffset = _scrollController.position.maxScrollExtent;

    _scrollController.animateTo(
      centeredOffset.clamp(0, maxOffset),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}
