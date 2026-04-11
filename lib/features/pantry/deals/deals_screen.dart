import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/current_org_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_view.dart';
import '../helpers/pantry_taxonomy.dart';
import '../models/pantry_deal.dart';
import '../models/pantry_store.dart';
import '../presentation/providers/pantry_providers.dart';

final AutoDisposeStateProvider<String?> _searchedLocationProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);
final AutoDisposeStateProvider<String> _activeCategoryProvider =
    StateProvider.autoDispose<String>((Ref ref) => 'all');
final AutoDisposeStateProvider<Set<String>> _addedDealsProvider =
    StateProvider.autoDispose<Set<String>>((Ref ref) => <String>{});
final AutoDisposeStateProvider<bool> _attemptedSeedProvider =
    StateProvider.autoDispose<bool>((Ref ref) => false);

class DealsScreen extends ConsumerStatefulWidget {
  const DealsScreen({super.key});

  @override
  ConsumerState<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends ConsumerState<DealsScreen> {
  final TextEditingController _locationController = TextEditingController();

  static final NumberFormat _currency = NumberFormat.currency(symbol: r'$');

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<String?> orgIdAsync = ref.watch(currentOrgIdProvider);

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) =>
          const Center(child: ErrorView(message: 'Unable to load deals.')),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        final AsyncValue<List<PantryDeal>> dealsAsync = ref.watch(
          pantryDealsProvider(orgId),
        );
        final AsyncValue<List<PantryStore>> storesAsync = ref.watch(
          pantryStoresProvider(orgId),
        );
        final String? searchedLocation = ref.watch(_searchedLocationProvider);
        final String activeCategory = ref.watch(_activeCategoryProvider);
        final Set<String> addedDeals = ref.watch(_addedDealsProvider);
        final bool attemptedSeed = ref.watch(_attemptedSeedProvider);

        return dealsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) =>
              const Center(child: ErrorView(message: 'Unable to load deals.')),
          data: (List<PantryDeal> deals) {
            if (deals.isEmpty && !attemptedSeed) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                ref.read(_attemptedSeedProvider.notifier).state = true;
                await ref
                    .read(pantryDealServiceProvider)
                    .seedSampleDeals(orgId);
                ref.invalidate(pantryDealsProvider(orgId));
              });
            }

            final List<String> sortedCategories =
                deals.map((PantryDeal deal) => deal.category).toSet().toList()
                  ..sort();
            final List<String> categoryOptions = <String>[
              'all',
              ...sortedCategories,
            ];
            final List<PantryDeal> filteredDeals = activeCategory == 'all'
                ? deals
                : deals
                      .where(
                        (PantryDeal deal) => deal.category == activeCategory,
                      )
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
                        Text('Deals & Stores', style: AppTextStyles.pageTitle),
                        const SizedBox(height: AppConstants.spacingMd),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _locationController,
                                decoration: const InputDecoration(
                                  hintText: 'City or zip for local deals...',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _submitLocation(),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingSm),
                            ElevatedButton(
                              onPressed: _submitLocation,
                              child: const Text('Search'),
                            ),
                          ],
                        ),
                        if (searchedLocation != null &&
                            searchedLocation.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: AppConstants.spacingSm),
                          Container(
                            padding: const EdgeInsets.all(
                              AppConstants.spacingMd,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tealLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.location_on_outlined),
                                const SizedBox(width: AppConstants.spacingSm),
                                Expanded(
                                  child: Text(
                                    'Deals near ${searchedLocation.trim()}',
                                    style: AppTextStyles.cardTitle.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppConstants.spacingMd),
                        Text('Nearby stores', style: AppTextStyles.cardTitle),
                        const SizedBox(height: AppConstants.spacingSm),
                        _NearbyStoresGrid(deals: deals),
                        const SizedBox(height: AppConstants.spacingMd),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categoryOptions
                                .map((String category) {
                                  final bool selected =
                                      activeCategory == category;
                                  final String label = category == 'all'
                                      ? 'All'
                                      : pantryCategoryLabel(category);
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppConstants.spacingSm,
                                    ),
                                    child: FilterChip(
                                      selected: selected,
                                      label: Text(label),
                                      onSelected: (_) {
                                        ref
                                                .read(
                                                  _activeCategoryProvider
                                                      .notifier,
                                                )
                                                .state =
                                            category;
                                      },
                                    ),
                                  );
                                })
                                .toList(growable: false),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        Expanded(
                          child: filteredDeals.isEmpty
                              ? const Center(
                                  child: Text('No deals in this category.'),
                                )
                              : ListView.separated(
                                  itemCount: filteredDeals.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const SizedBox(
                                            height: AppConstants.spacingMd,
                                          ),
                                  itemBuilder: (BuildContext context, int index) {
                                    final PantryDeal deal =
                                        filteredDeals[index];
                                    final bool isAdded = addedDeals.contains(
                                      deal.id,
                                    );
                                    final double original =
                                        deal.originalPrice ?? deal.salePrice;
                                    final int savingsPercent = original <= 0
                                        ? 0
                                        : (((original - deal.salePrice) /
                                                      original) *
                                                  100)
                                              .round();

                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                          AppConstants.spacingMd,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                _CategoryLabelChip(
                                                  category: deal.category,
                                                ),
                                                const Spacer(),
                                                if (savingsPercent > 0)
                                                  _SavingsChip(
                                                    label:
                                                        'Save $savingsPercent%',
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: AppConstants.spacingSm,
                                            ),
                                            Text(
                                              deal.itemName,
                                              style: AppTextStyles.cardTitle
                                                  .copyWith(fontSize: 18),
                                            ),
                                            Text(
                                              '@ ${deal.storeName}',
                                              style: AppTextStyles.body
                                                  .copyWith(
                                                    color: AppColors.textMuted,
                                                  ),
                                            ),
                                            const SizedBox(
                                              height: AppConstants.spacingSm,
                                            ),
                                            Wrap(
                                              spacing: AppConstants.spacingSm,
                                              runSpacing:
                                                  AppConstants.spacingXs,
                                              children: <Widget>[
                                                Text(
                                                  _currency.format(
                                                    deal.salePrice,
                                                  ),
                                                  style: AppTextStyles.cardTitle
                                                      .copyWith(
                                                        color: AppColors.green,
                                                        fontSize: 22,
                                                      ),
                                                ),
                                                if (deal.originalPrice != null)
                                                  Text(
                                                    _currency.format(
                                                      deal.originalPrice,
                                                    ),
                                                    style: AppTextStyles.body
                                                        .copyWith(
                                                          color: AppColors
                                                              .textMuted,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                  ),
                                                if (deal.unit != null &&
                                                    deal.unit!.isNotEmpty)
                                                  Text(
                                                    '/${deal.unit}',
                                                    style: AppTextStyles.body
                                                        .copyWith(
                                                          color: AppColors
                                                              .textMuted,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                            if (deal.expiresAt !=
                                                null) ...<Widget>[
                                              const SizedBox(
                                                height: AppConstants.spacingSm,
                                              ),
                                              Text(
                                                'Expires ${DateFormat('MMM d').format(deal.expiresAt!)}',
                                                style: AppTextStyles.label
                                                    .copyWith(
                                                      color: AppColors.red,
                                                    ),
                                              ),
                                            ],
                                            const SizedBox(
                                              height: AppConstants.spacingMd,
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed:
                                                    isAdded ||
                                                        storesAsync
                                                                .valueOrNull ==
                                                            null
                                                    ? null
                                                    : () =>
                                                          _showStorePickerSheet(
                                                            context,
                                                            orgId: orgId,
                                                            deal: deal,
                                                            stores: storesAsync
                                                                .valueOrNull!,
                                                          ),
                                                icon: Icon(
                                                  isAdded
                                                      ? Icons.check
                                                      : Icons
                                                            .add_shopping_cart_outlined,
                                                ),
                                                label: Text(
                                                  isAdded
                                                      ? 'Added'
                                                      : 'Add to list',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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

  void _submitLocation() {
    final String value = _locationController.text.trim();
    if (value.isEmpty) {
      return;
    }
    ref.read(_searchedLocationProvider.notifier).state = value;
  }

  Future<void> _showStorePickerSheet(
    BuildContext context, {
    required String orgId,
    required PantryDeal deal,
    required List<PantryStore> stores,
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
                Text('Add Deal To Store List', style: AppTextStyles.cardTitle),
                const SizedBox(height: AppConstants.spacingSm),
                ...stores.map((PantryStore store) {
                  return ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: Text(store.name),
                    onTap: () async {
                      await ref
                          .read(pantryItemServiceProvider)
                          .createItem(
                            orgId: orgId,
                            storeId: store.id,
                            name: deal.itemName,
                            unit: deal.unit,
                            category: deal.category,
                            price: deal.salePrice,
                          );
                      ref.invalidate(pantryItemsProvider(orgId, store.id));
                      ref.read(_addedDealsProvider.notifier).state = <String>{
                        ...ref.read(_addedDealsProvider),
                        deal.id,
                      };
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
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
}

class _NearbyStoresGrid extends StatelessWidget {
  const _NearbyStoresGrid({required this.deals});

  final List<PantryDeal> deals;

  static const Map<String, ({String type, String distance})> _storeMeta =
      <String, ({String type, String distance})>{
        'Whole Foods': (type: 'Premium', distance: '0.8 mi'),
        'Kroger': (type: 'Grocery', distance: '1.2 mi'),
        "Trader Joe's": (type: 'Specialty', distance: '2.1 mi'),
        'Costco': (type: 'Warehouse', distance: '3.4 mi'),
      };

  @override
  Widget build(BuildContext context) {
    final List<String> storeNames =
        deals.map((PantryDeal deal) => deal.storeName).toSet().toList()..sort();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: storeNames.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.spacingSm,
        mainAxisSpacing: AppConstants.spacingSm,
        childAspectRatio: 3.8,
      ),
      itemBuilder: (BuildContext context, int index) {
        final String name = storeNames[index];
        final ({String type, String distance}) meta =
            _storeMeta[name] ?? (type: 'Grocery', distance: 'Nearby');
        return Card(
          color: AppColors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${meta.type} · ${meta.distance}',
                  style: AppTextStyles.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryLabelChip extends StatelessWidget {
  const _CategoryLabelChip({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${pantryCategoryEmoji(category)} ${pantryCategoryLabel(category)}',
        style: AppTextStyles.label.copyWith(color: AppColors.text),
      ),
    );
  }
}

class _SavingsChip extends StatelessWidget {
  const _SavingsChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.greenFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: AppColors.green),
      ),
    );
  }
}
