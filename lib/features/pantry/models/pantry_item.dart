// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pantry_item.freezed.dart';
part 'pantry_item.g.dart';

@freezed
abstract class PantryItem with _$PantryItem {
  const factory PantryItem({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'store_id') required String storeId,
    required String name,
    required double qty,
    String? unit,
    required String category,
    required bool checked,
    @JsonKey(name: 'is_stocked') required bool isStocked,
    double? price,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PantryItem;

  factory PantryItem.fromJson(Map<String, dynamic> json) =>
      _$PantryItemFromJson(json);
}
