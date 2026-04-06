// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pantry_store.freezed.dart';
part 'pantry_store.g.dart';

@freezed
abstract class PantryStore with _$PantryStore {
  const factory PantryStore({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    required String name,
    @JsonKey(name: 'sort_order') required int sortOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PantryStore;

  factory PantryStore.fromJson(Map<String, dynamic> json) =>
      _$PantryStoreFromJson(json);
}
