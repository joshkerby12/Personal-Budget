// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'parent_category') required String parentCategory,
    required String subcategory,
    @JsonKey(name: 'sort_order') required int sortOrder,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
