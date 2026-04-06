// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PantryItem {

 String get id;@JsonKey(name: 'org_id') String get orgId;@JsonKey(name: 'store_id') String get storeId; String get name; double get qty; String? get unit; String get category; bool get checked;@JsonKey(name: 'is_stocked') bool get isStocked; double? get price;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryItemCopyWith<PantryItem> get copyWith => _$PantryItemCopyWithImpl<PantryItem>(this as PantryItem, _$identity);

  /// Serializes this PantryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.category, category) || other.category == category)&&(identical(other.checked, checked) || other.checked == checked)&&(identical(other.isStocked, isStocked) || other.isStocked == isStocked)&&(identical(other.price, price) || other.price == price)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,storeId,name,qty,unit,category,checked,isStocked,price,createdAt);

@override
String toString() {
  return 'PantryItem(id: $id, orgId: $orgId, storeId: $storeId, name: $name, qty: $qty, unit: $unit, category: $category, checked: $checked, isStocked: $isStocked, price: $price, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PantryItemCopyWith<$Res>  {
  factory $PantryItemCopyWith(PantryItem value, $Res Function(PantryItem) _then) = _$PantryItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'store_id') String storeId, String name, double qty, String? unit, String category, bool checked,@JsonKey(name: 'is_stocked') bool isStocked, double? price,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$PantryItemCopyWithImpl<$Res>
    implements $PantryItemCopyWith<$Res> {
  _$PantryItemCopyWithImpl(this._self, this._then);

  final PantryItem _self;
  final $Res Function(PantryItem) _then;

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? storeId = null,Object? name = null,Object? qty = null,Object? unit = freezed,Object? category = null,Object? checked = null,Object? isStocked = null,Object? price = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as double,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,checked: null == checked ? _self.checked : checked // ignore: cast_nullable_to_non_nullable
as bool,isStocked: null == isStocked ? _self.isStocked : isStocked // ignore: cast_nullable_to_non_nullable
as bool,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryItem].
extension PantryItemPatterns on PantryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryItem value)  $default,){
final _that = this;
switch (_that) {
case _PantryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryItem value)?  $default,){
final _that = this;
switch (_that) {
case _PantryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'store_id')  String storeId,  String name,  double qty,  String? unit,  String category,  bool checked, @JsonKey(name: 'is_stocked')  bool isStocked,  double? price, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryItem() when $default != null:
return $default(_that.id,_that.orgId,_that.storeId,_that.name,_that.qty,_that.unit,_that.category,_that.checked,_that.isStocked,_that.price,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'store_id')  String storeId,  String name,  double qty,  String? unit,  String category,  bool checked, @JsonKey(name: 'is_stocked')  bool isStocked,  double? price, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PantryItem():
return $default(_that.id,_that.orgId,_that.storeId,_that.name,_that.qty,_that.unit,_that.category,_that.checked,_that.isStocked,_that.price,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'store_id')  String storeId,  String name,  double qty,  String? unit,  String category,  bool checked, @JsonKey(name: 'is_stocked')  bool isStocked,  double? price, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PantryItem() when $default != null:
return $default(_that.id,_that.orgId,_that.storeId,_that.name,_that.qty,_that.unit,_that.category,_that.checked,_that.isStocked,_that.price,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PantryItem implements PantryItem {
  const _PantryItem({required this.id, @JsonKey(name: 'org_id') required this.orgId, @JsonKey(name: 'store_id') required this.storeId, required this.name, required this.qty, this.unit, required this.category, required this.checked, @JsonKey(name: 'is_stocked') required this.isStocked, this.price, @JsonKey(name: 'created_at') required this.createdAt});
  factory _PantryItem.fromJson(Map<String, dynamic> json) => _$PantryItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'org_id') final  String orgId;
@override@JsonKey(name: 'store_id') final  String storeId;
@override final  String name;
@override final  double qty;
@override final  String? unit;
@override final  String category;
@override final  bool checked;
@override@JsonKey(name: 'is_stocked') final  bool isStocked;
@override final  double? price;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryItemCopyWith<_PantryItem> get copyWith => __$PantryItemCopyWithImpl<_PantryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PantryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.category, category) || other.category == category)&&(identical(other.checked, checked) || other.checked == checked)&&(identical(other.isStocked, isStocked) || other.isStocked == isStocked)&&(identical(other.price, price) || other.price == price)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,storeId,name,qty,unit,category,checked,isStocked,price,createdAt);

@override
String toString() {
  return 'PantryItem(id: $id, orgId: $orgId, storeId: $storeId, name: $name, qty: $qty, unit: $unit, category: $category, checked: $checked, isStocked: $isStocked, price: $price, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PantryItemCopyWith<$Res> implements $PantryItemCopyWith<$Res> {
  factory _$PantryItemCopyWith(_PantryItem value, $Res Function(_PantryItem) _then) = __$PantryItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'store_id') String storeId, String name, double qty, String? unit, String category, bool checked,@JsonKey(name: 'is_stocked') bool isStocked, double? price,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$PantryItemCopyWithImpl<$Res>
    implements _$PantryItemCopyWith<$Res> {
  __$PantryItemCopyWithImpl(this._self, this._then);

  final _PantryItem _self;
  final $Res Function(_PantryItem) _then;

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? storeId = null,Object? name = null,Object? qty = null,Object? unit = freezed,Object? category = null,Object? checked = null,Object? isStocked = null,Object? price = freezed,Object? createdAt = null,}) {
  return _then(_PantryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as double,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,checked: null == checked ? _self.checked : checked // ignore: cast_nullable_to_non_nullable
as bool,isStocked: null == isStocked ? _self.isStocked : isStocked // ignore: cast_nullable_to_non_nullable
as bool,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
