import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/current_org_provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_view.dart';
import '../helpers/meal_slots.dart';
import '../helpers/pantry_taxonomy.dart';
import '../models/pantry_meal.dart';
import '../models/pantry_meal_plan_entry.dart';
import '../models/pantry_store.dart';
import '../presentation/providers/pantry_providers.dart';
import '../widgets/meal_form.dart';

final AutoDisposeStateProvider<DateTime> _weekStartProvider =
    StateProvider.autoDispose<DateTime>((Ref ref) {
      return _startOfWeek(DateTime.now());
    });
final AutoDisposeStateProvider<DateTime> _activeDayProvider =
    StateProvider.autoDispose<DateTime>((Ref ref) {
      return _normalizeDate(DateTime.now());
    });
final AutoDisposeStateProvider<String> _librarySearchProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');

class MealPlanScreen extends ConsumerWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> orgIdAsync = ref.watch(currentOrgIdProvider);

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) =>
          const Center(child: ErrorView(message: 'Unable to load meal plan.')),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        final DateTime weekStart = ref.watch(_weekStartProvider);
        final DateTime activeDay = ref.watch(_activeDayProvider);
        if (!_isWithinWeek(activeDay, weekStart)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(_activeDayProvider.notifier).state = weekStart;
          });
        }

        final AsyncValue<List<PantryMeal>> mealsAsync = ref.watch(
          pantryMealsProvider(orgId),
        );
        final AsyncValue<List<PantryMealPlanEntry>> planAsync = ref.watch(
          pantryMealPlanProvider(orgId, weekStart),
        );
        final AsyncValue<List<PantryStore>> storesAsync = ref.watch(
          pantryStoresProvider(orgId),
        );

        return planAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => const Center(
            child: ErrorView(message: 'Unable to load meal plan entries.'),
          ),
          data: (List<PantryMealPlanEntry> entries) {
            return mealsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stackTrace) => const Center(
                child: ErrorView(message: 'Unable to load meal library.'),
              ),
              data: (List<PantryMeal> meals) {
                final Map<String, PantryMeal> mealById = <String, PantryMeal>{
                  for (final PantryMeal meal in meals) meal.id: meal,
                };

                final Map<DateTime, Map<MealSlot, List<_PlannedMealCardModel>>>
                cardsByDayAndSlot =
                    <DateTime, Map<MealSlot, List<_PlannedMealCardModel>>>{};
                for (final PantryMealPlanEntry entry in entries) {
                  final PantryMeal? meal = mealById[entry.mealId];
                  if (meal == null) {
                    continue;
                  }
                  final DateTime dayKey = _normalizeDate(entry.planDate);
                  final MealSlot slot = mealSlotFromValue(entry.mealSlot);
                  final Map<MealSlot, List<_PlannedMealCardModel>> dayMap =
                      cardsByDayAndSlot.putIfAbsent(
                        dayKey,
                        () => <MealSlot, List<_PlannedMealCardModel>>{},
                      );
                  dayMap.putIfAbsent(slot, () => <_PlannedMealCardModel>[]);
                  dayMap[slot]!.add(
                    _PlannedMealCardModel(entry: entry, meal: meal),
                  );
                }

                final List<DateTime> weekDays = List<DateTime>.generate(
                  7,
                  (int index) => weekStart.add(Duration(days: index)),
                );

                final double weekTotal = entries.fold<double>(0, (
                  double running,
                  PantryMealPlanEntry entry,
                ) {
                  final PantryMeal? meal = mealById[entry.mealId];
                  if (meal == null) {
                    return running;
                  }
                  return running + _mealTotal(meal);
                });

                final DateTime activeDayKey = _normalizeDate(activeDay);
                final Map<MealSlot, List<_PlannedMealCardModel>>
                activeDaySlots =
                    cardsByDayAndSlot[activeDayKey] ??
                    <MealSlot, List<_PlannedMealCardModel>>{};

                double dayTotal = 0;
                for (final MealSlot slot in kMealSlotOrder) {
                  final List<_PlannedMealCardModel> cards =
                      activeDaySlots[slot] ?? <_PlannedMealCardModel>[];
                  for (final _PlannedMealCardModel card in cards) {
                    dayTotal += _mealTotal(card.meal);
                  }
                }

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
                            Text('Meal Plan', style: AppTextStyles.pageTitle),
                            const SizedBox(height: AppConstants.spacingMd),
                            Row(
                              children: <Widget>[
                                IconButton(
                                  onPressed: () => _shiftWeek(ref, -7),
                                  icon: const Icon(Icons.chevron_left),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Week of ${DateFormat('MMM d').format(weekStart)}',
                                      style: AppTextStyles.cardTitle,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _shiftWeek(ref, 7),
                                  icon: const Icon(Icons.chevron_right),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingSm),
                            SizedBox(
                              height: 90,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  final DateTime day = weekDays[index];
                                  final int count =
                                      cardsByDayAndSlot[day]?.values.fold<int>(
                                        0,
                                        (
                                          int sum,
                                          List<_PlannedMealCardModel> slot,
                                        ) => sum + slot.length,
                                      ) ??
                                      0;
                                  final bool selected =
                                      _normalizeDate(activeDay) == day;
                                  return _DayChip(
                                    day: day,
                                    count: count,
                                    selected: selected,
                                    onTap: () {
                                      ref
                                              .read(_activeDayProvider.notifier)
                                              .state =
                                          day;
                                    },
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(
                                          width: AppConstants.spacingSm,
                                        ),
                                itemCount: weekDays.length,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingMd),
                            _BudgetBar(
                              dayTotal: dayTotal,
                              weekTotal: weekTotal,
                              dayLabel: DateFormat(
                                'EEE, MMM d',
                              ).format(_normalizeDate(activeDay)),
                            ),
                            const SizedBox(height: AppConstants.spacingMd),
                            Expanded(
                              child: ListView.separated(
                                itemCount: kMealSlotOrder.length,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(
                                          height: AppConstants.spacingMd,
                                        ),
                                itemBuilder: (BuildContext context, int index) {
                                  final MealSlot slot = kMealSlotOrder[index];
                                  final List<_PlannedMealCardModel> cards =
                                      activeDaySlots[slot] ??
                                      <_PlannedMealCardModel>[];
                                  return _MealSlotSection(
                                    slot: slot,
                                    cards: cards,
                                    onAddMeal: () => _openAddMealSheet(
                                      context,
                                      ref,
                                      orgId: orgId,
                                      activeDay: activeDay,
                                      weekStart: weekStart,
                                      meals: meals,
                                      slot: slot,
                                    ),
                                    cardBuilder: (_PlannedMealCardModel card) {
                                      return _MealCard(
                                        model: card,
                                        onRemove: () => _removeFromPlan(
                                          context,
                                          ref,
                                          orgId: orgId,
                                          weekStart: weekStart,
                                          entryId: card.entry.id,
                                        ),
                                        onEditMeal: () => _openEditMealSheet(
                                          context,
                                          ref,
                                          orgId: orgId,
                                          weekStart: weekStart,
                                          meal: card.meal,
                                        ),
                                        onDeleteMealFromLibrary: () =>
                                            _confirmDeleteMealFromLibrary(
                                              context,
                                              ref,
                                              orgId: orgId,
                                              weekStart: weekStart,
                                              meal: card.meal,
                                            ),
                                        onAddIngredients: storesAsync.when(
                                          data: (List<PantryStore> stores) =>
                                              stores.isEmpty
                                              ? null
                                              : () =>
                                                    _showStorePickerForIngredients(
                                                      context,
                                                      ref,
                                                      orgId: orgId,
                                                      stores: stores,
                                                      weekStart: weekStart,
                                                      meal: card.meal,
                                                    ),
                                          loading: () => null,
                                          error: (_, _) => null,
                                        ),
                                      );
                                    },
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
      },
    );
  }
}

class _PlannedMealCardModel {
  const _PlannedMealCardModel({required this.entry, required this.meal});

  final PantryMealPlanEntry entry;
  final PantryMeal meal;
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.teal : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 86,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSm,
              vertical: AppConstants.spacingSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  DateFormat('E').format(day),
                  style: AppTextStyles.label.copyWith(
                    color: selected ? AppColors.white : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d').format(day),
                  style: AppTextStyles.cardTitle.copyWith(
                    color: selected ? AppColors.white : AppColors.navy,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.white.withValues(alpha: 0.22)
                        : AppColors.midGray,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.label.copyWith(
                      color: selected ? AppColors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetBar extends StatelessWidget {
  const _BudgetBar({
    required this.dayTotal,
    required this.weekTotal,
    required this.dayLabel,
  });

  final double dayTotal;
  final double weekTotal;
  final String dayLabel;

  static final NumberFormat _currency = NumberFormat.currency(symbol: r'$');

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.tealLight,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _BudgetTile(
                label: '$dayLabel total',
                value: _currency.format(dayTotal),
              ),
            ),
            Container(width: 1, height: 38, color: AppColors.border),
            Expanded(
              child: _BudgetTile(
                label: 'Week total',
                value: _currency.format(weekTotal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.cardTitle.copyWith(fontSize: 20)),
        ],
      ),
    );
  }
}

class _MealSlotSection extends StatelessWidget {
  const _MealSlotSection({
    required this.slot,
    required this.cards,
    required this.onAddMeal,
    required this.cardBuilder,
  });

  final MealSlot slot;
  final List<_PlannedMealCardModel> cards;
  final VoidCallback onAddMeal;
  final Widget Function(_PlannedMealCardModel card) cardBuilder;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(slot.label, style: AppTextStyles.cardTitle),
                const Spacer(),
                IconButton(
                  onPressed: onAddMeal,
                  tooltip: 'Add ${slot.label} meal',
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (cards.isEmpty)
              _EmptySlotRow(slot: slot, onAddMeal: onAddMeal)
            else
              Column(
                children: <Widget>[
                  for (
                    int index = 0;
                    index < cards.length;
                    index++
                  ) ...<Widget>[
                    if (index > 0)
                      const SizedBox(height: AppConstants.spacingMd),
                    cardBuilder(cards[index]),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptySlotRow extends StatelessWidget {
  const _EmptySlotRow({required this.slot, required this.onAddMeal});

  final MealSlot slot;
  final VoidCallback onAddMeal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        color: AppColors.lightGray,
      ),
      child: Row(
        children: <Widget>[
          Text(
            'Nothing planned',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onAddMeal,
            icon: const Icon(Icons.add, size: 18),
            label: Text('Add ${slot.label}'),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.model,
    required this.onRemove,
    required this.onAddIngredients,
    required this.onEditMeal,
    required this.onDeleteMealFromLibrary,
  });

  final _PlannedMealCardModel model;
  final VoidCallback onRemove;
  final VoidCallback? onAddIngredients;
  final VoidCallback onEditMeal;
  final VoidCallback onDeleteMealFromLibrary;

  static final NumberFormat _currency = NumberFormat.currency(symbol: r'$');

  @override
  Widget build(BuildContext context) {
    final PantryMeal meal = model.meal;
    final double total = _mealTotal(meal);

    return Card(
      margin: EdgeInsets.zero,
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
                      GestureDetector(
                        onTap: onEditMeal,
                        child: Text(
                          meal.name,
                          style: AppTextStyles.cardTitle.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.border,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Wrap(
                        spacing: AppConstants.spacingSm,
                        runSpacing: AppConstants.spacingXs,
                        children: <Widget>[
                          _InfoPill(
                            label: meal.source == 'url' ? 'URL' : 'Manual',
                            icon: meal.source == 'url'
                                ? Icons.link
                                : Icons.edit_note,
                          ),
                          _InfoPill(
                            label: _currency.format(total),
                            icon: Icons.wallet_outlined,
                          ),
                          if (meal.costPerServing != null)
                            _InfoPill(
                              label:
                                  '${_currency.format(meal.costPerServing)}/srv',
                              icon: Icons.attach_money_outlined,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Edit meal',
                      onPressed: onEditMeal,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Meal options',
                      onSelected: (String value) {
                        if (value == 'delete-library') {
                          onDeleteMealFromLibrary();
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          const <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'delete-library',
                              child: Text('Delete from library'),
                            ),
                          ],
                    ),
                    IconButton(
                      tooltip: 'Remove from day',
                      onPressed: onRemove,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
            if (meal.ingredients.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppConstants.spacingSm),
              Wrap(
                spacing: AppConstants.spacingSm,
                runSpacing: AppConstants.spacingSm,
                children: <Widget>[
                  ...meal.ingredients.take(5).map((String ingredient) {
                    return Chip(
                      label: Text(ingredient),
                      visualDensity: VisualDensity.compact,
                    );
                  }),
                  if (meal.ingredients.length > 5)
                    Chip(
                      label: Text('+${meal.ingredients.length - 5} more'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppConstants.spacingSm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddIngredients,
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Add ingredients to list'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}

void _shiftWeek(WidgetRef ref, int dayDelta) {
  final DateTime weekStart = ref.read(_weekStartProvider);
  final DateTime activeDay = ref.read(_activeDayProvider);
  final int weekdayOffset = _normalizeDate(
    activeDay,
  ).difference(_normalizeDate(weekStart)).inDays.clamp(0, 6);
  final DateTime nextWeekStart = _normalizeDate(
    weekStart.add(Duration(days: dayDelta)),
  );
  ref.read(_weekStartProvider.notifier).state = nextWeekStart;
  ref.read(_activeDayProvider.notifier).state = nextWeekStart.add(
    Duration(days: weekdayOffset),
  );
}

Future<void> _removeFromPlan(
  BuildContext context,
  WidgetRef ref, {
  required String orgId,
  required DateTime weekStart,
  required String entryId,
}) async {
  try {
    await ref.read(pantryMealPlanServiceProvider).removeFromPlan(entryId);
    ref.invalidate(pantryMealPlanProvider(orgId, weekStart));
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Unable to remove meal: $error')));
  }
}

Future<void> _confirmDeleteMealFromLibrary(
  BuildContext context,
  WidgetRef ref, {
  required String orgId,
  required DateTime weekStart,
  required PantryMeal meal,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Delete meal from library?'),
        content: Text(
          'Delete ${meal.name} from library? This will remove it from all planned days.',
        ),
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
    ref.invalidate(pantryMealPlanProvider(orgId, weekStart));
  } catch (error) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Unable to delete meal: $error')));
  }
}

Future<void> _openEditMealSheet(
  BuildContext context,
  WidgetRef ref, {
  required String orgId,
  required DateTime weekStart,
  required PantryMeal meal,
}) async {
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Edit Meal', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppConstants.spacingMd),
              MealForm(
                initialName: meal.name,
                initialIngredients: meal.ingredients.join('\n'),
                initialCost: meal.costPerServing?.toString() ?? '',
                initialServings: meal.servings.toString(),
                saveLabel: 'Save Changes',
                onSave: (MealFormDraft draft) async {
                  if (draft.name.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Meal name is required.')),
                    );
                    return;
                  }

                  try {
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
                    ref.invalidate(pantryMealsProvider(orgId));
                    ref.invalidate(pantryMealPlanProvider(orgId, weekStart));
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  } catch (error) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Unable to update meal: $error')),
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

Future<void> _showStorePickerForIngredients(
  BuildContext context,
  WidgetRef ref, {
  required String orgId,
  required List<PantryStore> stores,
  required DateTime weekStart,
  required PantryMeal meal,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Add Ingredients To List', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppConstants.spacingSm),
              ...stores.map((PantryStore store) {
                return ListTile(
                  leading: const Icon(Icons.storefront_outlined),
                  title: Text(store.name),
                  onTap: () async {
                    for (final String ingredient in meal.ingredients) {
                      await ref
                          .read(pantryItemServiceProvider)
                          .createItem(
                            orgId: orgId,
                            storeId: store.id,
                            name: ingredient,
                            category: categorizePantryItem(ingredient),
                          );
                    }
                    ref.invalidate(pantryItemsProvider(orgId, store.id));
                    ref.invalidate(pantryMealPlanProvider(orgId, weekStart));
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Added ${meal.ingredients.length} ingredients to ${store.name}.',
                          ),
                        ),
                      );
                    }
                  },
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _openAddMealSheet(
  BuildContext context,
  WidgetRef ref, {
  required String orgId,
  required DateTime activeDay,
  required DateTime weekStart,
  required List<PantryMeal> meals,
  required MealSlot slot,
}) async {
  ref.read(_librarySearchProvider.notifier).state = '';

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final String libraryQuery = ref.watch(_librarySearchProvider);
          final String query = libraryQuery.trim().toLowerCase();
          final List<PantryMeal> filteredMeals = meals
              .where((PantryMeal meal) {
                if (query.isEmpty) {
                  return true;
                }
                return meal.name.toLowerCase().contains(query);
              })
              .toList(growable: false);

          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingMd,
              AppConstants.spacingLg,
              MediaQuery.viewInsetsOf(context).bottom + AppConstants.spacingLg,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Add ${slot.label} Meal',
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    'Choose a recipe from your library.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  _LibraryMealPicker(
                    meals: filteredMeals,
                    onQueryChanged: (String value) {
                      ref.read(_librarySearchProvider.notifier).state = value;
                    },
                    onSelectMeal: (PantryMeal meal) async {
                      await ref
                          .read(pantryMealPlanServiceProvider)
                          .addToPlan(
                            orgId,
                            meal.id,
                            activeDay,
                            mealSlot: slot.value,
                          );
                      ref.invalidate(pantryMealPlanProvider(orgId, weekStart));
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      if (context.mounted) {
                        context.go(AppRoutes.pantryCookbook);
                      }
                    },
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Go to Cookbook to add a new recipe'),
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

class _LibraryMealPicker extends StatelessWidget {
  const _LibraryMealPicker({
    required this.meals,
    required this.onQueryChanged,
    required this.onSelectMeal,
  });

  final List<PantryMeal> meals;
  final ValueChanged<String> onQueryChanged;
  final Future<void> Function(PantryMeal meal) onSelectMeal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search meal library',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: meals.isEmpty
              ? const Center(child: Text('No meals found.'))
              : ListView.separated(
                  itemCount: meals.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final PantryMeal meal = meals[index];
                    return ListTile(
                      title: Text(meal.name),
                      subtitle: Text(
                        '${meal.ingredients.length} ingredients',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      onTap: () => onSelectMeal(meal),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

double _mealTotal(PantryMeal meal) {
  if (meal.costPerServing == null) {
    return 0;
  }
  return meal.costPerServing! * meal.servings;
}

DateTime _normalizeDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _startOfWeek(DateTime date) {
  final DateTime normalized = _normalizeDate(date);
  return normalized.subtract(Duration(days: normalized.weekday - 1));
}

bool _isWithinWeek(DateTime date, DateTime weekStart) {
  final DateTime normalizedDate = _normalizeDate(date);
  final DateTime normalizedStart = _normalizeDate(weekStart);
  final DateTime normalizedEnd = normalizedStart.add(const Duration(days: 7));
  return !normalizedDate.isBefore(normalizedStart) &&
      normalizedDate.isBefore(normalizedEnd);
}
