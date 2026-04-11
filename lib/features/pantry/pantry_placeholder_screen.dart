import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

class PantryPlaceholderScreen extends StatelessWidget {
  const PantryPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: AppTextStyles.pageTitle));
  }
}
