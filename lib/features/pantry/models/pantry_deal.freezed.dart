// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_deal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PantryDeal {

 String get id;@JsonKey(name: 'org_id') String get orgId;@JsonKey(name: 'store_name') String get storeName;@JsonKey(name: 'item_name') String get itemName; String get category;@JsonKey(name: 'sale_price') double get salePrice;@JsonKey(name: 'original_price') double? get originalPrice; String? get unit;@JsonKey(name: 'expires_at') DateTime? get expiresAt;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of PantryDeal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryDealCopyWith<PantryDeal> get copyWith => _$PantryDealCopyWithImpl<PantryDeal>(this as PantryDeal, _$identity);

  /// Serializes this PantryDeal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryDeal&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.category, category) || other.category == category)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,storeName,itemName,category,salePrice,originalPrice,unit,expiresAt,createdAt);

@override
String toString() {
  return 'PantryDeal(id: $id, orgId: $orgId, storeName: $storeName, itemName: $itemName, category: $category, salePrice: $salePrice, originalPrice: $originalPrice, unit: $unit, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PantryDealCopyWith<$Res>  {
  factory $PantryDealCopyWith(PantryDeal value, $Res Function(PantryDeal) _then) = _$PantryDealCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'store_name') String storeName,@JsonKey(name: 'item_name') String itemName, String category,@JsonKey(name: 'sale_price') double salePrice,@JsonKey(name: 'original_price') double? originalPrice, String? unit,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$PantryDealCopyWithImpl<$Res>
    implements $PantryDealCopyWith<$Res> {
  _$PantryDealCopyWithImpl(this._self, this._then);

  final PantryDeal _self;
  final $Res Function(PantryDeal) _then;

/// Create a copy of PantryDeal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? storeName = null,Object? itemName = null,Object? category = null,Object? salePrice = null,Object? originalPrice = freezed,Object? unit = freezed,Object? expiresAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as double,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryDeal].
extension PantryDealPatterns on PantryDeal {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryDeal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryDeal() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryDeal value)  $default,){
final _that = this;
switch (_that) {
case _PantryDeal():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryDeal value)?  $default,){
final _that = this;
switch (_that) {
case _PantryDeal() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'store_name')  String storeName, @JsonKey(name: 'item_name')  String itemName,  String category, @JsonKey(name: 'sale_price')  double salePrice, @JsonKey(name: 'original_price')  double? originalPrice,  String? unit, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryDeal() when $default != null:
return $default(_that.id,_that.orgId,_that.storeName,_that.itemName,_that.category,_that.salePrice,_that.originalPrice,_that.unit,_that.expiresAt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'store_name')  String storeName, @JsonKey(name: 'item_name')  String itemName,  String category, @JsonKey(name: 'sale_price')  double salePrice, @JsonKey(name: 'original_price')  double? originalPrice,  String? unit, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PantryDeal():
return $default(_that.id,_that.orgId,_that.storeName,_that.itemName,_that.category,_that.salePrice,_that.originalPrice,_that.unit,_that.expiresAt,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'store_name')  String storeName, @JsonKey(name: 'item_name')  String itemName,  String category, @JsonKey(name: 'sale_price')  double salePrice, @JsonKey(name: 'original_price')  double? originalPrice,  String? unit, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PantryDeal() when $default != null:
return $default(_that.id,_that.orgId,_that.storeName,_that.itemName,_that.category,_that.salePrice,_that.originalPrice,_that.unit,_that.expiresAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PantryDeal implements PantryDeal {
  const _PantryDeal({required this.id, @JsonKey(name: 'org_id') required this.orgId, @JsonKey(name: 'store_name') required this.storeName, @JsonKey(name: 'item_name') required this.itemName, required this.category, @JsonKey(name: 'sale_price') required this.salePrice, @JsonKey(name: 'original_price') this.originalPrice, this.unit, @JsonKey(name: 'expires_at') this.expiresAt, @JsonKey(name: 'created_at') required this.createdAt});
  factory _PantryDeal.fromJson(Map<String, dynamic> json) => _$PantryDealFromJson(json);

@override final  String id;
@override@JsonKey(name: 'org_id') final  String orgId;
@override@JsonKey(name: 'store_name') final  String storeName;
@override@JsonKey(name: 'item_name') final  String itemName;
@override final  String category;
@override@JsonKey(name: 'sale_price') final  double salePrice;
@override@JsonKey(name: 'original_price') final  double? originalPrice;
@override final  String? unit;
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of PantryDeal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryDealCopyWith<_PantryDeal> get copyWith => __$PantryDealCopyWithImpl<_PantryDeal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PantryDealToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryDeal&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.category, category) || other.category == category)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,storeName,itemName,category,salePrice,originalPrice,unit,expiresAt,createdAt);

@override
String toString() {
  return 'PantryDeal(id: $id, orgId: $orgId, storeName: $storeName, itemName: $itemName, category: $category, salePrice: $salePrice, originalPrice: $originalPrice, unit: $unit, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PantryDealCopyWith<$Res> implements $PantryDealCopyWith<$Res> {
  factory _$PantryDealCopyWith(_PantryDeal value, $Res Function(_PantryDeal) _then) = __$PantryDealCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'store_name') String storeName,@JsonKey(name: 'item_name') String itemName, String category,@JsonKey(name: 'sale_price') double salePrice,@JsonKey(name: 'original_price') double? originalPrice, String? unit,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$PantryDealCopyWithImpl<$Res>
    implements _$PantryDealCopyWith<$Res> {
  __$PantryDealCopyWithImpl(this._self, this._then);

  final _PantryDeal _self;
  final $Res Function(_PantryDeal) _then;

/// Create a copy of PantryDeal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? storeName = null,Object? itemName = null,Object? category = null,Object? salePrice = null,Object? originalPrice = freezed,Object? unit = freezed,Object? expiresAt = freezed,Object? createdAt = null,}) {
  return _then(_PantryDeal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as double,originalPrice: freezed == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
