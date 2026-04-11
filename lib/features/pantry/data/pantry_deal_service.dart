import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pantry_deal.dart';

class PantryDealService {
  const PantryDealService(this._client);

  final SupabaseClient _client;

  Future<List<PantryDeal>> fetchDeals(String orgId) async {
    final List<dynamic> rows = await _client
        .from('pantry_deals')
        .select()
        .eq('org_id', orgId)
        .order('expires_at', ascending: true)
        .order('created_at', ascending: false);

    return rows
        .cast<Map<String, dynamic>>()
        .map(PantryDeal.fromJson)
        .toList(growable: false);
  }

  Future<void> seedSampleDeals(String orgId) async {
    final List<dynamic> existing = await _client
        .from('pantry_deals')
        .select('id')
        .eq('org_id', orgId)
        .limit(1);

    if (existing.isNotEmpty) {
      return;
    }

    final DateTime today = DateTime.now();
    await _client.from('pantry_deals').insert(<Map<String, dynamic>>[
      <String, dynamic>{
        'org_id': orgId,
        'store_name': 'Kroger',
        'item_name': 'Chicken Breast',
        'category': 'meat',
        'sale_price': 3.99,
        'original_price': 6.99,
        'unit': 'lb',
        'expires_at': _dateOnly(today.add(const Duration(days: 7))),
      },
      <String, dynamic>{
        'org_id': orgId,
        'store_name': 'Whole Foods',
        'item_name': 'Salmon Fillet',
        'category': 'meat',
        'sale_price': 9.99,
        'original_price': 14.99,
        'unit': 'lb',
        'expires_at': _dateOnly(today.add(const Duration(days: 3))),
      },
      <String, dynamic>{
        'org_id': orgId,
        'store_name': "Trader Joe's",
        'item_name': 'Avocados',
        'category': 'produce',
        'sale_price': 0.79,
        'original_price': 1.49,
        'unit': 'each',
        'expires_at': _dateOnly(today.add(const Duration(days: 7))),
      },
      <String, dynamic>{
        'org_id': orgId,
        'store_name': 'Kroger',
        'item_name': 'Greek Yogurt',
        'category': 'dairy',
        'sale_price': 3.29,
        'original_price': 5.49,
        'unit': '32oz',
        'expires_at': _dateOnly(today.add(const Duration(days: 4))),
      },
      <String, dynamic>{
        'org_id': orgId,
        'store_name': 'Kroger',
        'item_name': 'Pasta',
        'category': 'pantry',
        'sale_price': 1.19,
        'original_price': 2.49,
        'unit': 'box',
        'expires_at': _dateOnly(today.add(const Duration(days: 7))),
      },
      <String, dynamic>{
        'org_id': orgId,
        'store_name': 'Whole Foods',
        'item_name': 'Broccoli',
        'category': 'produce',
        'sale_price': 1.49,
        'original_price': 2.99,
        'unit': 'head',
        'expires_at': _dateOnly(today.add(const Duration(days: 5))),
      },
      <String, dynamic>{
        'org_id': orgId,
        'store_name': 'Costco',
        'item_name': 'Cheddar Cheese',
        'category': 'dairy',
        'sale_price': 7.99,
        'original_price': 12.99,
        'unit': '2lb',
        'expires_at': _dateOnly(today.add(const Duration(days: 7))),
      },
      <String, dynamic>{
        'org_id': orgId,
        'store_name': 'Kroger',
        'item_name': 'Eggs (18ct)',
        'category': 'dairy',
        'sale_price': 3.49,
        'original_price': 5.99,
        'unit': 'carton',
        'expires_at': _dateOnly(today.add(const Duration(days: 7))),
      },
      <String, dynamic>{
        'org_id': orgId,
        'store_name': 'Costco',
        'item_name': 'Olive Oil',
        'category': 'pantry',
        'sale_price': 10.49,
        'original_price': 14.99,
        'unit': '2L',
        'expires_at': _dateOnly(today.add(const Duration(days: 10))),
      },
      <String, dynamic>{
        'org_id': orgId,
        'store_name': "Trader Joe's",
        'item_name': 'Blueberries',
        'category': 'produce',
        'sale_price': 2.29,
        'original_price': 3.99,
        'unit': 'pint',
        'expires_at': _dateOnly(today.add(const Duration(days: 4))),
      },
    ]);
  }
}

String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
