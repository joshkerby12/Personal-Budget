import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/category_service.dart';
import '../../models/category.dart';

part 'categories_provider.g.dart';

@Riverpod(keepAlive: true)
CategoryService categoryService(Ref ref) {
  return CategoryService(ref.watch(supabaseClientProvider));
}

@riverpod
Future<List<Category>> categories(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final String? userId = client.auth.currentUser?.id;
  if (userId == null) {
    return <Category>[];
  }

  final Map<String, dynamic>? member = await client
      .from('org_members')
      .select('org_id')
      .eq('profile_id', userId)
      .order('created_at', ascending: false)
      .limit(1)
      .maybeSingle();

  final String? orgId = member?['org_id'] as String?;
  if (orgId == null) {
    return <Category>[];
  }

  return ref.read(categoryServiceProvider).fetchCategories(orgId);
}
