import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pantry_item.dart';

class PantryItemService {
  const PantryItemService(this._client);

  final SupabaseClient _client;

  Future<List<PantryItem>> fetchItems(String orgId, String storeId) async {
    final List<dynamic> rows = await _client
        .from('pantry_items')
        .select()
        .eq('org_id', orgId)
        .eq('store_id', storeId)
        .order('checked', ascending: true)
        .order('created_at', ascending: true);

    return rows
        .cast<Map<String, dynamic>>()
        .map(PantryItem.fromJson)
        .toList(growable: false);
  }

  Future<PantryItem> createItem({
    required String orgId,
    required String storeId,
    required String name,
    double qty = 1,
    String? unit,
    String category = 'Other',
    bool checked = false,
    bool isStocked = false,
    double? price,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Item name cannot be empty.');
    }

    final Map<String, dynamic> created = await _client
        .from('pantry_items')
        .insert(<String, dynamic>{
          'org_id': orgId,
          'store_id': storeId,
          'name': trimmedName,
          'qty': qty,
          'unit': unit?.trim().isEmpty == true ? null : unit?.trim(),
          'category': category,
          'checked': checked,
          'is_stocked': isStocked,
          'price': price,
        })
        .select()
        .single();

    return PantryItem.fromJson(created);
  }

  Future<void> updateItem(PantryItem item) async {
    await _client
        .from('pantry_items')
        .update(<String, dynamic>{
          'name': item.name.trim(),
          'qty': item.qty,
          'unit': item.unit?.trim().isEmpty == true ? null : item.unit?.trim(),
          'category': item.category,
          'checked': item.checked,
          'is_stocked': item.isStocked,
          'price': item.price,
        })
        .eq('id', item.id);
  }

  Future<void> deleteItem(String itemId) async {
    await _client.from('pantry_items').delete().eq('id', itemId);
  }

  Future<void> checkItem(String itemId, bool checked) async {
    await _client
        .from('pantry_items')
        .update(<String, dynamic>{'checked': checked})
        .eq('id', itemId);
  }

  Future<void> clearChecked(String orgId, String storeId) async {
    await _client
        .from('pantry_items')
        .delete()
        .eq('org_id', orgId)
        .eq('store_id', storeId)
        .eq('checked', true);
  }
}
