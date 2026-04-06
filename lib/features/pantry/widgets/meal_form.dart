import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class MealFormDraft {
  const MealFormDraft({
    required this.name,
    required this.ingredients,
    required this.costPerServing,
    required this.servings,
  });

  final String name;
  final List<String> ingredients;
  final double? costPerServing;
  final int servings;
}

class MealForm extends StatefulWidget {
  const MealForm({
    super.key,
    required this.onSave,
    this.initialName = '',
    this.initialIngredients = '',
    this.initialCost = '',
    this.initialServings = '4',
    this.saveLabel = 'Save',
  });

  final Future<void> Function(MealFormDraft draft) onSave;
  final String initialName;
  final String initialIngredients;
  final String initialCost;
  final String initialServings;
  final String saveLabel;

  @override
  State<MealForm> createState() => _MealFormState();
}

class _MealFormState extends State<MealForm> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialName,
  );
  late final TextEditingController _ingredientsController =
      TextEditingController(text: widget.initialIngredients);
  late final TextEditingController _costController = TextEditingController(
    text: widget.initialCost,
  );
  late final TextEditingController _servingsController = TextEditingController(
    text: widget.initialServings,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _ingredientsController.dispose();
    _costController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final String name = _nameController.text.trim();
    final List<String> ingredients = _ingredientsController.text
        .split('\n')
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
    final double? costPerServing = double.tryParse(_costController.text.trim());
    final int servings = int.tryParse(_servingsController.text.trim()) ?? 1;

    await widget.onSave(
      MealFormDraft(
        name: name,
        ingredients: ingredients,
        costPerServing: costPerServing,
        servings: servings < 1 ? 1 : servings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Meal name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextFormField(
          controller: _ingredientsController,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Ingredients (one per line)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Cost per serving',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: TextFormField(
                controller: _servingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Servings',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),
        ElevatedButton.icon(
          onPressed: _handleSave,
          icon: const Icon(Icons.save_outlined),
          label: Text(widget.saveLabel),
        ),
      ],
    );
  }
}
