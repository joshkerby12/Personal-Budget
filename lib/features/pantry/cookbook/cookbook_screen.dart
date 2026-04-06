import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/current_org_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_view.dart';
import '../helpers/meal_slots.dart';
import '../models/pantry_meal.dart';
import '../presentation/providers/pantry_providers.dart';
import '../widgets/meal_form.dart';

final AutoDisposeStateProvider<String> _searchQueryProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');

class CookbookScreen extends ConsumerWidget {
  const CookbookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> orgIdAsync = ref.watch(currentOrgIdProvider);

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) =>
          const Center(child: ErrorView(message: 'Unable to load cookbook.')),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        final AsyncValue<List<PantryMeal>> mealsAsync = ref.watch(
          pantryMealsProvider(orgId),
        );
        final String query = ref
            .watch(_searchQueryProvider)
            .trim()
            .toLowerCase();

        return mealsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => const Center(
            child: ErrorView(message: 'Unable to load recipe library.'),
          ),
          data: (List<PantryMeal> meals) {
            final List<PantryMeal> filteredMeals = meals
                .where((PantryMeal meal) {
                  if (query.isEmpty) {
                    return true;
                  }
                  return meal.name.toLowerCase().contains(query);
                })
                .toList(growable: false);

            return SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppConstants.pagePaddingMobile,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('Cookbook', style: AppTextStyles.pageTitle),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _openRecipeSheet(context, ref, orgId: orgId),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Recipe'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search recipes',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (String value) {
                            ref.read(_searchQueryProvider.notifier).state =
                                value;
                          },
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        Expanded(
                          child: filteredMeals.isEmpty
                              ? const _EmptyCookbookState()
                              : ListView.separated(
                                  itemCount: filteredMeals.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const SizedBox(
                                            height: AppConstants.spacingMd,
                                          ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        final PantryMeal meal =
                                            filteredMeals[index];
                                        return _RecipeCard(
                                          meal: meal,
                                          onEdit: () => _openRecipeSheet(
                                            context,
                                            ref,
                                            orgId: orgId,
                                            meal: meal,
                                          ),
                                          onDelete: () => _confirmDeleteRecipe(
                                            context,
                                            ref,
                                            orgId: orgId,
                                            meal: meal,
                                          ),
                                          onAddToPlan: () =>
                                              _openAddToMealPlanSheet(
                                                context,
                                                ref,
                                                orgId: orgId,
                                                meal: meal,
                                              ),
                                        );
                                      },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.meal,
    required this.onEdit,
    required this.onDelete,
    required this.onAddToPlan,
  });

  final PantryMeal meal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddToPlan;

  static final NumberFormat _currency = NumberFormat.currency(symbol: r'$');

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(meal.name, style: AppTextStyles.cardTitle),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        '${meal.ingredients.length} ingredients',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (meal.costPerServing != null) ...<Widget>[
                        const SizedBox(height: AppConstants.spacingXs),
                        Text(
                          '${_currency.format(meal.costPerServing)} / serving · ${meal.servings} servings',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _SourcePill(source: meal.source),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Wrap(
              spacing: AppConstants.spacingSm,
              runSpacing: AppConstants.spacingSm,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddToPlan,
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('Add to meal plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourcePill extends StatelessWidget {
  const _SourcePill({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        source == 'url' ? 'URL' : 'Manual',
        style: AppTextStyles.label,
      ),
    );
  }
}

class _EmptyCookbookState extends StatelessWidget {
  const _EmptyCookbookState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.menu_book_outlined,
              size: 44,
              color: AppColors.navy,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'No recipes yet. Add your first recipe to get started.',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardTitle,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekDayChip extends StatelessWidget {
  const _WeekDayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        '${DateFormat('E').format(day)} ${DateFormat('d').format(day)}',
      ),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

Future<void> _openRecipeSheet(
  BuildContext context,
  WidgetRef ref, {
  required String orgId,
  PantryMeal? meal,
}) async {
  final bool isEditing = meal != null;
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppConstants.spacingLg,
          AppConstants.spacingMd,
          AppConstants.spacingLg,
          MediaQuery.viewInsetsOf(sheetContext).bottom + AppConstants.spacingLg,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                isEditing ? 'Edit Recipe' : 'Add Recipe',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              MealForm(
                initialName: meal?.name ?? '',
                initialIngredients: meal?.ingredients.join('\n') ?? '',
                initialCost: meal?.costPerServing?.toString() ?? '',
                initialServings: meal?.servings.toString() ?? '4',
                saveLabel: isEditing ? 'Save Changes' : 'Save Recipe',
                onSave: (MealFormDraft draft) async {
                  if (draft.name.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Meal name is required.')),
                    );
                    return;
                  }

                  try {
                    if (meal == null) {
                      await ref
                          .read(pantryMealServiceProvider)
                          .createMeal(
                            orgId: orgId,
                            name: draft.name,
                            ingredients: draft.ingredients,
                            costPerServing: draft.costPerServing,
                            servings: draft.servings,
                            source: 'manual',
                          );
                    } else {
                      await ref
                          .read(pantryMealServiceProvider)
                          .updateMeal(
                            meal.copyWith(
                              name: draft.name,
                              ingredients: draft.ingredients,
                              costPerServing: draft.costPerServing,
                              servings: draft.servings,
                            ),
                          );
                    }
                    ref.invalidate(pantryMealsProvider(orgId));
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  } catch (error) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Unable to save recipe: $error')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _confirmDeleteRecipe(
  BuildContext context,
  WidgetRef ref, {
  required String orgId,
  required PantryMeal meal,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('Delete ${meal.name}?'),
        content: const Text('This will also remove it from any planned days.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  try {
    await ref.read(pantryMealServiceProvider).deleteMeal(meal.id);
    ref.invalidate(pantryMealsProvider(orgId));
    ref.invalidate(pantryMealPlanProvider(orgId, _startOfWeek(DateTime.now())));
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Unable to delete recipe: $error')));
  }
}

Future<void> _openAddToMealPlanSheet(
  BuildContext context,
  WidgetRef ref, {
  required String orgId,
  required PantryMeal meal,
}) async {
  final DateTime weekStart = _startOfWeek(DateTime.now());
  final List<DateTime> weekDays = List<DateTime>.generate(
    7,
    (int index) => weekStart.add(Duration(days: index)),
  );
  DateTime selectedDate = _normalizeDate(DateTime.now());
  MealSlot selectedSlot = MealSlot.dinner;

  await showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Add ${meal.name}', style: AppTextStyles.cardTitle),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text('Meal slot', style: AppTextStyles.label),
                  const SizedBox(height: AppConstants.spacingSm),
                  Wrap(
                    spacing: AppConstants.spacingSm,
                    runSpacing: AppConstants.spacingSm,
                    children: kMealSlotOrder
                        .map((MealSlot slot) {
                          return ChoiceChip(
                            label: Text(slot.label),
                            selected: selectedSlot == slot,
                            onSelected: (_) {
                              setModalState(() {
                                selectedSlot = slot;
                              });
                            },
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text('Day', style: AppTextStyles.label),
                  const SizedBox(height: AppConstants.spacingSm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: weekDays
                          .map((DateTime day) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppConstants.spacingSm,
                              ),
                              child: _WeekDayChip(
                                day: day,
                                selected: _normalizeDate(selectedDate) == day,
                                onTap: () {
                                  setModalState(() {
                                    selectedDate = day;
                                  });
                                },
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await ref
                              .read(pantryMealPlanServiceProvider)
                              .addToPlan(
                                orgId,
                                meal.id,
                                selectedDate,
                                mealSlot: selectedSlot.value,
                              );
                          ref.invalidate(
                            pantryMealPlanProvider(orgId, weekStart),
                          );
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added ${meal.name} to ${selectedSlot.label} on ${DateFormat('EEE, MMM d').format(selectedDate)}.',
                                ),
                              ),
                            );
                          }
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Unable to add meal: $error'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Add to plan'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

DateTime _normalizeDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _startOfWeek(DateTime date) {
  final DateTime normalized = _normalizeDate(date);
  return normalized.subtract(Duration(days: normalized.weekday - 1));
}
