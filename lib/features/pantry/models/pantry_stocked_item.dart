// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pantry_stocked_item.freezed.dart';
part 'pantry_stocked_item.g.dart';

@freezed
abstract class PantryStockedItem with _$PantryStockedItem {
  const factory PantryStockedItem({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    required String name,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PantryStockedItem;

  factory PantryStockedItem.fromJson(Map<String, dynamic> json) =>
      _$PantryStockedItemFromJson(json);
}
