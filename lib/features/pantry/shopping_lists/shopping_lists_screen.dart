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
import '../data/pantry_item_service.dart';
import '../helpers/pantry_taxonomy.dart';
import '../models/pantry_item.dart';
import '../models/pantry_stocked_item.dart';
import '../models/pantry_store.dart';
import '../presentation/providers/pantry_providers.dart';

final AutoDisposeStateProvider<String?> _activeStoreIdProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);

class ShoppingListsScreen extends ConsumerStatefulWidget {
  const ShoppingListsScreen({super.key});

  @override
  ConsumerState<ShoppingListsScreen> createState() =>
      _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends ConsumerState<ShoppingListsScreen> {
  final TextEditingController _itemController = TextEditingController();
  final FocusNode _itemFocusNode = FocusNode();

  @override
  void dispose() {
    _itemController.dispose();
    _itemFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<String?> orgIdAsync = ref.watch(currentOrgIdProvider);

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => const Center(
        child: ErrorView(message: 'Unable to load shopping lists.'),
      ),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        final AsyncValue<List<PantryStore>> storesAsync = ref.watch(
          pantryStoresProvider(orgId),
        );

        return storesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => const Center(
            child: ErrorView(message: 'Unable to load stores right now.'),
          ),
          data: (List<PantryStore> stores) {
            if (stores.isEmpty) {
              return _EmptyStoresState(
                onAddStore: () => _showAddStoreSheet(context, orgId),
              );
            }

            final PantryStore? activeStore = _resolveActiveStore(stores);
            if (activeStore == null) {
              return const Center(
                child: ErrorView(message: 'Unable to load a store list.'),
              );
            }

            final AsyncValue<List<PantryItem>> itemsAsync = ref.watch(
              pantryItemsProvider(orgId, activeStore.id),
            );
            final AsyncValue<List<PantryStockedItem>> stockedAsync = ref.watch(
              pantryStockedProvider(orgId),
            );

            return itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stackTrace) => const Center(
                child: ErrorView(
                  message: 'Unable to load list items right now.',
                ),
              ),
              data: (List<PantryItem> items) {
                final Set<String> activeStocked =
                    stockedAsync.valueOrNull
                        ?.where((PantryStockedItem item) => item.isActive)
                        .map((PantryStockedItem item) => item.name)
                        .toSet() ??
                    <String>{};
                final int checkedCount = items
                    .where((PantryItem item) => item.checked)
                    .length;
                final bool anyChecked = checkedCount > 0;
                final double progress = items.isEmpty
                    ? 0
                    : checkedCount / items.length;

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
                                Text(
                                  'Shopping Lists',
                                  style: AppTextStyles.pageTitle,
                                ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.go(AppRoutes.pantryDeals),
                                  icon: const Icon(
                                    Icons.local_offer_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Deals'),
                                ),
                                const SizedBox(width: AppConstants.spacingSm),
                                TextButton.icon(
                                  onPressed: () => _showStockedQuickAddSheet(
                                    context,
                                    orgId: orgId,
                                    activeStoreId: activeStore.id,
                                    stockedNames: activeStocked.toList()
                                      ..sort(),
                                  ),
                                  icon: const Icon(Icons.inventory_2_outlined),
                                  label: const Text('Stocked'),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingMd),
                            SizedBox(
                              height: 44,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  ...stores.map((PantryStore store) {
                                    final int count =
                                        ref
                                            .watch(
                                              pantryItemsProvider(
                                                orgId,
                                                store.id,
                                              ),
                                            )
                                            .valueOrNull
                                            ?.length ??
                                        0;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: AppConstants.spacingSm,
                                      ),
                                      child: _StorePill(
                                        label: store.name,
                                        count: count,
                                        selected: store.id == activeStore.id,
                                        onTap: () {
                                          ref
                                              .read(
                                                _activeStoreIdProvider.notifier,
                                              )
                                              .state = store
                                              .id;
                                        },
                                        onLongPress: () => _confirmDeleteStore(
                                          context,
                                          orgId: orgId,
                                          store: store,
                                        ),
                                      ),
                                    );
                                  }),
                                  _AddStorePill(
                                    onTap: () =>
                                        _showAddStoreSheet(context, orgId),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingSm),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 7,
                                backgroundColor: AppColors.midGray,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.green,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingLg),
                            _AddItemRow(
                              controller: _itemController,
                              focusNode: _itemFocusNode,
                              onSubmit: () => _addItem(
                                orgId: orgId,
                                storeId: activeStore.id,
                                stockedNames: activeStocked,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingSm),
                            if (anyChecked)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () => _clearChecked(
                                    orgId: orgId,
                                    storeId: activeStore.id,
                                  ),
                                  icon: const Icon(Icons.cleaning_services),
                                  label: Text('Clear checked ($checkedCount)'),
                                ),
                              ),
                            const SizedBox(height: AppConstants.spacingSm),
                            Expanded(
                              child: items.isEmpty
                                  ? _EmptyStoreItemsState(
                                      onAddStocked: () =>
                                          _showStockedQuickAddSheet(
                                            context,
                                            orgId: orgId,
                                            activeStoreId: activeStore.id,
                                            stockedNames: activeStocked.toList()
                                              ..sort(),
                                          ),
                                      onFocusAddItem: () =>
                                          _itemFocusNode.requestFocus(),
                                    )
                                  : _GroupedItemsList(
                                      items: items,
                                      onToggleChecked:
                                          (PantryItem item, bool checked) =>
                                              _checkItem(
                                                orgId: orgId,
                                                storeId: activeStore.id,
                                                item: item,
                                                checked: checked,
                                              ),
                                      onDelete: (PantryItem item) =>
                                          _deleteItem(
                                            orgId: orgId,
                                            storeId: activeStore.id,
                                            itemId: item.id,
                                          ),
                                      onToggleStocked: (PantryItem item) =>
                                          _toggleStocked(
                                            orgId: orgId,
                                            storeId: activeStore.id,
                                            item: item,
                                          ),
                                      onEditItem: (PantryItem item) =>
                                          _showEditItemSheet(
                                            context,
                                            orgId: orgId,
                                            storeId: activeStore.id,
                                            item: item,
                                          ),
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

  PantryStore? _resolveActiveStore(List<PantryStore> stores) {
    final String? activeStoreId = ref.watch(_activeStoreIdProvider);
    if (activeStoreId == null && stores.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(_activeStoreIdProvider.notifier).state = stores.first.id;
      });
      return stores.first;
    }

    final PantryStore? activeStore = stores.where((PantryStore store) {
      return store.id == activeStoreId;
    }).firstOrNull;

    if (activeStore == null && stores.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(_activeStoreIdProvider.notifier).state = stores.first.id;
      });
      return stores.first;
    }

    return activeStore;
  }

  Future<void> _showAddStoreSheet(BuildContext context, String orgId) async {
    final TextEditingController controller = TextEditingController();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.spacingLg,
            AppConstants.spacingLg,
            AppConstants.spacingLg,
            MediaQuery.viewInsetsOf(sheetContext).bottom +
                AppConstants.spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Add Store', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppConstants.spacingMd),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Store name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) async {
                  await _createStore(
                    sheetContext,
                    orgId: orgId,
                    name: controller.text,
                    messenger: messenger,
                  );
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _createStore(
                      sheetContext,
                      orgId: orgId,
                      name: controller.text,
                      messenger: messenger,
                    );
                  },
                  child: const Text('Add Store'),
                ),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
  }

  Future<void> _createStore(
    BuildContext sheetContext, {
    required String orgId,
    required String name,
    required ScaffoldMessengerState messenger,
  }) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter a store name.')),
      );
      return;
    }

    try {
      final PantryStore created = await ref
          .read(pantryStoreServiceProvider)
          .createStore(orgId, trimmed);
      ref.invalidate(pantryStoresProvider(orgId));
      ref.read(_activeStoreIdProvider.notifier).state = created.id;
      if (sheetContext.mounted) {
        Navigator.of(sheetContext).pop();
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to add store: $error')),
      );
    }
  }

  Future<void> _confirmDeleteStore(
    BuildContext context, {
    required String orgId,
    required PantryStore store,
  }) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete store?'),
          content: Text(
            'Delete ${store.name}? This will remove all items in this list.',
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

    if (!mounted) {
      return;
    }

    try {
      await ref.read(pantryStoreServiceProvider).deleteStore(store.id);
      ref.invalidate(pantryStoresProvider(orgId));
      ref.read(_activeStoreIdProvider.notifier).state = null;
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to delete store: $error')),
      );
    }
  }

  Future<void> _addItem({
    required String orgId,
    required String storeId,
    required Set<String> stockedNames,
    String? seededName,
  }) async {
    final String name = (seededName ?? _itemController.text).trim();
    if (name.isEmpty) {
      return;
    }

    final PantryItemService service = ref.read(pantryItemServiceProvider);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String normalizedName = normalizePantryName(name);
    final bool isStocked = stockedNames.any(normalizedName.contains);

    try {
      await service.createItem(
        orgId: orgId,
        storeId: storeId,
        name: name,
        category: categorizePantryItem(name),
        isStocked: isStocked,
      );
      ref.invalidate(pantryItemsProvider(orgId, storeId));
      if (seededName == null) {
        _itemController.clear();
      }
      _itemFocusNode.requestFocus();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to add item: $error')),
      );
    }
  }

  Future<void> _checkItem({
    required String orgId,
    required String storeId,
    required PantryItem item,
    required bool checked,
  }) async {
    try {
      await ref.read(pantryItemServiceProvider).checkItem(item.id, checked);
      ref.invalidate(pantryItemsProvider(orgId, storeId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update item: $error')));
    }
  }

  Future<void> _toggleStocked({
    required String orgId,
    required String storeId,
    required PantryItem item,
  }) async {
    final bool nextStockedState = !item.isStocked;

    try {
      await ref
          .read(pantryItemServiceProvider)
          .updateItem(item.copyWith(isStocked: nextStockedState));
      await ref
          .read(pantryStockedServiceProvider)
          .upsertStocked(orgId, item.name, nextStockedState);
      ref.invalidate(pantryItemsProvider(orgId, storeId));
      ref.invalidate(pantryStockedProvider(orgId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to toggle stocked state: $error')),
      );
    }
  }

  Future<void> _deleteItem({
    required String orgId,
    required String storeId,
    required String itemId,
  }) async {
    try {
      await ref.read(pantryItemServiceProvider).deleteItem(itemId);
      ref.invalidate(pantryItemsProvider(orgId, storeId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to remove item: $error')));
    }
  }

  Future<void> _clearChecked({
    required String orgId,
    required String storeId,
  }) async {
    try {
      await ref.read(pantryItemServiceProvider).clearChecked(orgId, storeId);
      ref.invalidate(pantryItemsProvider(orgId, storeId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to clear checked items: $error')),
      );
    }
  }

  Future<void> _showEditItemSheet(
    BuildContext context, {
    required String orgId,
    required String storeId,
    required PantryItem item,
  }) async {
    final TextEditingController nameController = TextEditingController(
      text: item.name,
    );
    final TextEditingController qtyController = TextEditingController(
      text: item.qty % 1 == 0
          ? item.qty.toStringAsFixed(0)
          : item.qty.toStringAsFixed(2),
    );
    final TextEditingController unitController = TextEditingController(
      text: item.unit ?? '',
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.spacingLg,
            AppConstants.spacingLg,
            AppConstants.spacingLg,
            MediaQuery.viewInsetsOf(sheetContext).bottom +
                AppConstants.spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Edit Item', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppConstants.spacingMd),
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextField(
                controller: qtyController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Qty',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextField(
                controller: unitController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  hintText: 'lbs, oz, bag',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) async {
                  await _saveItemEdits(
                    sheetContext,
                    orgId: orgId,
                    storeId: storeId,
                    item: item,
                    name: nameController.text,
                    qtyText: qtyController.text,
                    unit: unitController.text,
                    messenger: messenger,
                  );
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),
              ElevatedButton.icon(
                onPressed: () async {
                  await _saveItemEdits(
                    sheetContext,
                    orgId: orgId,
                    storeId: storeId,
                    item: item,
                    name: nameController.text,
                    qtyText: qtyController.text,
                    unit: unitController.text,
                    messenger: messenger,
                  );
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
    qtyController.dispose();
    unitController.dispose();
  }

  Future<void> _saveItemEdits(
    BuildContext sheetContext, {
    required String orgId,
    required String storeId,
    required PantryItem item,
    required String name,
    required String qtyText,
    required String unit,
    required ScaffoldMessengerState messenger,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Item name cannot be empty.')),
      );
      return;
    }

    final double? parsedQty = double.tryParse(qtyText.trim());
    if (parsedQty == null || parsedQty <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Quantity must be greater than 0.')),
      );
      return;
    }

    try {
      await ref
          .read(pantryItemServiceProvider)
          .updateItem(
            item.copyWith(
              name: trimmedName,
              qty: parsedQty,
              unit: unit.trim().isEmpty ? null : unit.trim(),
            ),
          );
      ref.invalidate(pantryItemsProvider(orgId, storeId));
      if (sheetContext.mounted) {
        Navigator.of(sheetContext).pop();
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to update item: $error')),
      );
    }
  }

  Future<void> _showStockedQuickAddSheet(
    BuildContext context, {
    required String orgId,
    required String activeStoreId,
    required List<String> stockedNames,
  }) async {
    if (stockedNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active stocked items yet.')),
      );
      return;
    }

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
                Text('Add from stocked items', style: AppTextStyles.cardTitle),
                const SizedBox(height: AppConstants.spacingMd),
                Wrap(
                  spacing: AppConstants.spacingSm,
                  runSpacing: AppConstants.spacingSm,
                  children: stockedNames
                      .map((String stockedName) {
                        return ActionChip(
                          label: Text(stockedName),
                          avatar: const Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                          ),
                          onPressed: () async {
                            await _addItem(
                              orgId: orgId,
                              storeId: activeStoreId,
                              stockedNames: stockedNames.toSet(),
                              seededName: stockedName,
                            );
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                        );
                      })
                      .toList(growable: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StorePill extends StatelessWidget {
  const _StorePill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.teal : AppColors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: selected ? AppColors.white : AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppConstants.spacingXs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.white.withValues(alpha: 0.2)
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
    );
  }
}

class _AddStorePill extends StatelessWidget {
  const _AddStorePill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add),
      label: const Text('Store'),
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}

class _AddItemRow extends StatelessWidget {
  const _AddItemRow({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Add an item (e.g. chicken breast)',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        ElevatedButton(onPressed: onSubmit, child: const Text('Add')),
      ],
    );
  }
}

class _GroupedItemsList extends StatelessWidget {
  const _GroupedItemsList({
    required this.items,
    required this.onToggleChecked,
    required this.onDelete,
    required this.onToggleStocked,
    required this.onEditItem,
  });

  final List<PantryItem> items;
  final Future<void> Function(PantryItem item, bool checked) onToggleChecked;
  final Future<void> Function(PantryItem item) onDelete;
  final Future<void> Function(PantryItem item) onToggleStocked;
  final Future<void> Function(PantryItem item) onEditItem;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<PantryItem>> groups = <String, List<PantryItem>>{};
    for (final PantryItem item in items) {
      groups.putIfAbsent(item.category, () => <PantryItem>[]).add(item);
    }

    return ListView(
      children: kPantryCategoryOrder
          .where(groups.containsKey)
          .map((String key) {
            final List<PantryItem> groupItems = groups[key]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${pantryCategoryEmoji(key)} ${pantryCategoryLabel(key)}',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      ...groupItems.map((PantryItem item) {
                        return _ItemRow(
                          item: item,
                          onToggleChecked: (bool checked) =>
                              onToggleChecked(item, checked),
                          onDelete: () => onDelete(item),
                          onToggleStocked: () => onToggleStocked(item),
                          onEdit: () => onEditItem(item),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.onToggleChecked,
    required this.onDelete,
    required this.onToggleStocked,
    required this.onEdit,
  });

  final PantryItem item;
  final ValueChanged<bool> onToggleChecked;
  final VoidCallback onDelete;
  final VoidCallback onToggleStocked;
  final VoidCallback onEdit;

  static final NumberFormat _currency = NumberFormat.currency(symbol: r'$');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: item.checked,
            onChanged: (bool? value) => onToggleChecked(value ?? false),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: Text(
                      item.name,
                      style: AppTextStyles.body.copyWith(
                        decoration: item.checked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: item.checked
                            ? AppColors.textMuted
                            : AppColors.text,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: AppConstants.spacingSm,
                  runSpacing: AppConstants.spacingXs,
                  children: <Widget>[
                    if (item.qty > 1)
                      _TinyBadge(
                        icon: Icons.tag_outlined,
                        label: _qtyBadgeLabel(item.qty, item.unit),
                      ),
                    if (item.isStocked)
                      const _TinyBadge(
                        icon: Icons.inventory_2_outlined,
                        label: 'Stocked',
                      ),
                    if (item.price != null)
                      _TinyBadge(
                        icon: Icons.attach_money_outlined,
                        label: _currency.format(item.price),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: item.isStocked ? 'Remove stocked tag' : 'Mark stocked',
            onPressed: onToggleStocked,
            icon: Icon(
              item.isStocked ? Icons.inventory_2 : Icons.inventory_2_outlined,
              color: item.isStocked ? AppColors.green : AppColors.textMuted,
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: onDelete,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

String _qtyBadgeLabel(double qty, String? unit) {
  final String qtyText = qty % 1 == 0 ? qty.toStringAsFixed(0) : '$qty';
  final String unitText = unit?.trim() ?? '';
  return 'x$qtyText $unitText'.trim();
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

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

class _EmptyStoresState extends StatelessWidget {
  const _EmptyStoresState({required this.onAddStore});

  final VoidCallback onAddStore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.storefront_outlined,
              size: 44,
              color: AppColors.navy,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text('No store lists yet.', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Add your first store to start building a shopping list.',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            ElevatedButton.icon(
              onPressed: onAddStore,
              icon: const Icon(Icons.add),
              label: const Text('Add a Store'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStoreItemsState extends StatelessWidget {
  const _EmptyStoreItemsState({
    required this.onAddStocked,
    required this.onFocusAddItem,
  });

  final VoidCallback onAddStocked;
  final VoidCallback onFocusAddItem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.receipt_long_outlined,
              size: 44,
              color: AppColors.navy,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text('This list is empty.', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Add your first item above or quick-add from stocked items.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Wrap(
              spacing: AppConstants.spacingSm,
              runSpacing: AppConstants.spacingSm,
              alignment: WrapAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: onFocusAddItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
                OutlinedButton.icon(
                  onPressed: onAddStocked,
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Stocked Items'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
