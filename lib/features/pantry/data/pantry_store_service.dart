import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pantry_store.dart';

class PantryStoreService {
  const PantryStoreService(this._client);

  final SupabaseClient _client;

  Future<List<PantryStore>> fetchStores(String orgId) async {
    final List<dynamic> rows = await _client
        .from('pantry_stores')
        .select()
        .eq('org_id', orgId)
        .order('sort_order', ascending: true)
        .order('created_at', ascending: true);

    return rows
        .cast<Map<String, dynamic>>()
        .map(PantryStore.fromJson)
        .toList(growable: false);
  }

  Future<PantryStore> createStore(String orgId, String name) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Store name cannot be empty.');
    }

    final List<dynamic> rows = await _client
        .from('pantry_stores')
        .select('sort_order')
        .eq('org_id', orgId)
        .order('sort_order', ascending: false)
        .limit(1);

    final int highestSortOrder = rows.isEmpty
        ? -1
        : ((rows.first as Map<String, dynamic>)['sort_order'] as num?)
                  ?.toInt() ??
              -1;
    final int nextSortOrder = highestSortOrder + 1;

    final Map<String, dynamic> created = await _client
        .from('pantry_stores')
        .insert(<String, dynamic>{
          'org_id': orgId,
          'name': trimmedName,
          'sort_order': nextSortOrder,
        })
        .select()
        .single();

    return PantryStore.fromJson(created);
  }

  Future<void> deleteStore(String storeId) async {
    await _client.from('pantry_stores').delete().eq('id', storeId);
  }
}
