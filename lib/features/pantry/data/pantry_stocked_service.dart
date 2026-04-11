import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pantry_stocked_item.dart';

class PantryStockedService {
  const PantryStockedService(this._client);

  final SupabaseClient _client;

  Future<List<PantryStockedItem>> fetchStocked(String orgId) async {
    final List<dynamic> rows = await _client
        .from('pantry_stocked')
        .select()
        .eq('org_id', orgId)
        .order('name', ascending: true);

    return rows
        .cast<Map<String, dynamic>>()
        .map(PantryStockedItem.fromJson)
        .toList(growable: false);
  }

  Future<PantryStockedItem> upsertStocked(
    String orgId,
    String name,
    bool isActive, {
    String? category,
  }) async {
    final String normalizedName = name.trim().toLowerCase();
    if (normalizedName.isEmpty) {
      throw ArgumentError('Stocked item name cannot be empty.');
    }

    final Map<String, dynamic> row = await _client
        .from('pantry_stocked')
        .upsert(<String, dynamic>{
          'org_id': orgId,
          'name': normalizedName,
          'is_active': isActive,
        }, onConflict: 'org_id,name')
        .select()
        .single();

    return PantryStockedItem.fromJson(row);
  }

  Future<void> deleteStocked(String stockedId) async {
    await _client.from('pantry_stocked').delete().eq('id', stockedId);
  }
}
