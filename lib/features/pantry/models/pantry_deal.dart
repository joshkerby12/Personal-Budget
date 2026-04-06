// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pantry_deal.freezed.dart';
part 'pantry_deal.g.dart';

@freezed
abstract class PantryDeal with _$PantryDeal {
  const factory PantryDeal({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'store_name') required String storeName,
    @JsonKey(name: 'item_name') required String itemName,
    required String category,
    @JsonKey(name: 'sale_price') required double salePrice,
    @JsonKey(name: 'original_price') double? originalPrice,
    String? unit,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PantryDeal;

  factory PantryDeal.fromJson(Map<String, dynamic> json) =>
      _$PantryDealFromJson(json);
}
