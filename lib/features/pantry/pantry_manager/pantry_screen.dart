import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/current_org_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_view.dart';
import '../helpers/pantry_taxonomy.dart';
import '../models/pantry_stocked_item.dart';
import '../presentation/providers/pantry_providers.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final TextEditingController _customItemController = TextEditingController();
  String _selectedCategory = 'other';

  @override
  void dispose() {
    _customItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<String?> orgIdAsync = ref.watch(currentOrgIdProvider);

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) =>
          const Center(child: ErrorView(message: 'Unable to load pantry.')),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        final AsyncValue<List<PantryStockedItem>> stockedAsync = ref.watch(
          pantryStockedProvider(orgId),
        );

        return stockedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) =>
              const Center(child: ErrorView(message: 'Unable to load pantry.')),
          data: (List<PantryStockedItem> stockedItems) {
            final Map<String, PantryStockedItem> stockedByName =
                <String, PantryStockedItem>{
                  for (final PantryStockedItem item in stockedItems)
                    item.name: item,
                };
            final Set<String> commonSet = kCommonPantryItems
                .map(normalizePantryName)
                .toSet();
            final int activeCount = stockedItems
                .where((PantryStockedItem item) => item.isActive)
                .length;
            final List<_PantryChipItem> allItems = <_PantryChipItem>[
              ...kCommonPantryItems.map((String name) {
                final String normalizedName = normalizePantryName(name);
                final PantryStockedItem? stockedItem =
                    stockedByName[normalizedName];
                return _PantryChipItem(
                  name: normalizedName,
                  isActive: stockedItem?.isActive ?? false,
                  isCustom: false,
                  stockedId: stockedItem?.id,
                );
              }),
              ...stockedItems
                  .where((PantryStockedItem item) {
                    return !commonSet.contains(item.name);
                  })
                  .map((PantryStockedItem item) {
                    return _PantryChipItem(
                      name: item.name,
                      isActive: item.isActive,
                      isCustom: true,
                      stockedId: item.id,
                    );
                  }),
            ];
            final Map<String, List<_PantryChipItem>> groupedItems =
                _groupByCategory(allItems);

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
                        Text('Pantry', style: AppTextStyles.pageTitle),
                        const SizedBox(height: AppConstants.spacingMd),
                        Card(
                          color: AppColors.teal,
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppConstants.spacingLg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '$activeCount items stocked',
                                  style: AppTextStyles.pageTitle.copyWith(
                                    color: AppColors.white,
                                    fontSize: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingLg),
                        Text(
                          'Add custom pantry item',
                          style: AppTextStyles.cardTitle,
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _customItemController,
                                onChanged: _onCustomItemNameChanged,
                                decoration: const InputDecoration(
                                  hintText: 'Add custom pantry item',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _addCustomItem(orgId),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingSm),
                            ElevatedButton(
                              onPressed: () => _addCustomItem(orgId),
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: kPantryCategoryOrder
                              .map((String key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(pantryCategoryLabel(key)),
                                );
                              })
                              .toList(growable: false),
                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: AppConstants.spacingLg),
                        Expanded(
                          child: ListView(
                            children: kPantryCategoryOrder
                                .where(
                                  (String category) =>
                                      groupedItems[category]?.isNotEmpty ??
                                      false,
                                )
                                .map((String category) {
                                  final List<_PantryChipItem> items =
                                      groupedItems[category]!;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppConstants.spacingLg,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${pantryCategoryEmoji(category)} ${pantryCategoryLabel(category)}',
                                          style: AppTextStyles.cardTitle,
                                        ),
                                        const SizedBox(
                                          height: AppConstants.spacingSm,
                                        ),
                                        Wrap(
                                          spacing: AppConstants.spacingSm,
                                          runSpacing: AppConstants.spacingSm,
                                          children: items
                                              .map((item) {
                                                return _PantryItemChip(
                                                  item: item,
                                                  onToggle: () =>
                                                      _toggleCommonItem(
                                                        orgId: orgId,
                                                        name: item.name,
                                                        currentActive:
                                                            item.isActive,
                                                      ),
                                                  onDelete: item.isCustom
                                                      ? () => _deleteCustomItem(
                                                          orgId: orgId,
                                                          stockedId:
                                                              item.stockedId!,
                                                        )
                                                      : null,
                                                );
                                              })
                                              .toList(growable: false),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                                .toList(growable: false),
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

  Future<void> _addCustomItem(String orgId) async {
    final String name = _customItemController.text.trim();
    if (name.isEmpty) {
      return;
    }

    try {
      await ref
          .read(pantryStockedServiceProvider)
          .upsertStocked(orgId, name, true, category: _selectedCategory);
      _customItemController.clear();
      setState(() {
        _selectedCategory = 'other';
      });
      ref.invalidate(pantryStockedProvider(orgId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to add custom item: $error')),
      );
    }
  }

  Future<void> _deleteCustomItem({
    required String orgId,
    required String stockedId,
  }) async {
    try {
      await ref.read(pantryStockedServiceProvider).deleteStocked(stockedId);
      ref.invalidate(pantryStockedProvider(orgId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to remove item: $error')));
    }
  }

  Future<void> _toggleCommonItem({
    required String orgId,
    required String name,
    required bool currentActive,
  }) async {
    try {
      await ref
          .read(pantryStockedServiceProvider)
          .upsertStocked(orgId, name, !currentActive);
      ref.invalidate(pantryStockedProvider(orgId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update item: $error')));
    }
  }

  void _onCustomItemNameChanged(String value) {
    final String suggestedCategory = value.trim().isEmpty
        ? 'other'
        : categorizePantryItem(value);
    if (!kPantryCategoryOrder.contains(suggestedCategory)) {
      return;
    }

    if (_selectedCategory == suggestedCategory) {
      return;
    }

    setState(() {
      _selectedCategory = suggestedCategory;
    });
  }

  Map<String, List<_PantryChipItem>> _groupByCategory(
    List<_PantryChipItem> items,
  ) {
    final Map<String, List<_PantryChipItem>> grouped =
        <String, List<_PantryChipItem>>{};
    for (final _PantryChipItem item in items) {
      final String category = categorizePantryItem(item.name);
      grouped.putIfAbsent(category, () => <_PantryChipItem>[]).add(item);
    }

    for (final List<_PantryChipItem> bucket in grouped.values) {
      bucket.sort((_PantryChipItem a, _PantryChipItem b) {
        return a.name.compareTo(b.name);
      });
    }

    return grouped;
  }
}

class _PantryChipItem {
  const _PantryChipItem({
    required this.name,
    required this.isActive,
    required this.isCustom,
    required this.stockedId,
  });

  final String name;
  final bool isActive;
  final bool isCustom;
  final String? stockedId;
}

class _PantryItemChip extends StatelessWidget {
  const _PantryItemChip({
    required this.item,
    required this.onToggle,
    this.onDelete,
  });

  final _PantryChipItem item;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final bool isActive = item.isActive;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isActive ? AppColors.greenFill : AppColors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? AppColors.green : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isActive) ...<Widget>[
                const Icon(Icons.check, size: 12, color: AppColors.green),
                const SizedBox(width: 4),
              ],
              Text(
                item.name,
                style: AppTextStyles.body.copyWith(
                  color: isActive ? AppColors.green : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (onDelete != null) ...<Widget>[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.close, size: 12),
                  color: isActive ? AppColors.green : AppColors.textMuted,
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding: EdgeInsets.zero,
                  splashRadius: 12,
                  tooltip: 'Remove',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
