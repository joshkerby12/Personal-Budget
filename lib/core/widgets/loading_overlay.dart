import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message = 'Loading...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.spacingSm),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(color: AppColors.teal),
              const SizedBox(height: AppConstants.spacingMd),
              Text(message, style: AppTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }
}
