// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_default.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetDefault {

 String get id;@JsonKey(name: 'org_id') String get orgId; String get category; String get subcategory;@JsonKey(name: 'monthly_amount') double get monthlyAmount;@JsonKey(name: 'default_biz_pct') double get defaultBizPct; DateTime? get month;@JsonKey(name: 'sort_order') int get sortOrder;
/// Create a copy of BudgetDefault
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetDefaultCopyWith<BudgetDefault> get copyWith => _$BudgetDefaultCopyWithImpl<BudgetDefault>(this as BudgetDefault, _$identity);

  /// Serializes this BudgetDefault to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetDefault&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.monthlyAmount, monthlyAmount) || other.monthlyAmount == monthlyAmount)&&(identical(other.defaultBizPct, defaultBizPct) || other.defaultBizPct == defaultBizPct)&&(identical(other.month, month) || other.month == month)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,category,subcategory,monthlyAmount,defaultBizPct,month,sortOrder);

@override
String toString() {
  return 'BudgetDefault(id: $id, orgId: $orgId, category: $category, subcategory: $subcategory, monthlyAmount: $monthlyAmount, defaultBizPct: $defaultBizPct, month: $month, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $BudgetDefaultCopyWith<$Res>  {
  factory $BudgetDefaultCopyWith(BudgetDefault value, $Res Function(BudgetDefault) _then) = _$BudgetDefaultCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId, String category, String subcategory,@JsonKey(name: 'monthly_amount') double monthlyAmount,@JsonKey(name: 'default_biz_pct') double defaultBizPct, DateTime? month,@JsonKey(name: 'sort_order') int sortOrder
});




}
/// @nodoc
class _$BudgetDefaultCopyWithImpl<$Res>
    implements $BudgetDefaultCopyWith<$Res> {
  _$BudgetDefaultCopyWithImpl(this._self, this._then);

  final BudgetDefault _self;
  final $Res Function(BudgetDefault) _then;

/// Create a copy of BudgetDefault
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? category = null,Object? subcategory = null,Object? monthlyAmount = null,Object? defaultBizPct = null,Object? month = freezed,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: null == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String,monthlyAmount: null == monthlyAmount ? _self.monthlyAmount : monthlyAmount // ignore: cast_nullable_to_non_nullable
as double,defaultBizPct: null == defaultBizPct ? _self.defaultBizPct : defaultBizPct // ignore: cast_nullable_to_non_nullable
as double,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetDefault].
extension BudgetDefaultPatterns on BudgetDefault {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetDefault value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetDefault() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetDefault value)  $default,){
final _that = this;
switch (_that) {
case _BudgetDefault():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetDefault value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetDefault() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId,  String category,  String subcategory, @JsonKey(name: 'monthly_amount')  double monthlyAmount, @JsonKey(name: 'default_biz_pct')  double defaultBizPct,  DateTime? month, @JsonKey(name: 'sort_order')  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetDefault() when $default != null:
return $default(_that.id,_that.orgId,_that.category,_that.subcategory,_that.monthlyAmount,_that.defaultBizPct,_that.month,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId,  String category,  String subcategory, @JsonKey(name: 'monthly_amount')  double monthlyAmount, @JsonKey(name: 'default_biz_pct')  double defaultBizPct,  DateTime? month, @JsonKey(name: 'sort_order')  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _BudgetDefault():
return $default(_that.id,_that.orgId,_that.category,_that.subcategory,_that.monthlyAmount,_that.defaultBizPct,_that.month,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'org_id')  String orgId,  String category,  String subcategory, @JsonKey(name: 'monthly_amount')  double monthlyAmount, @JsonKey(name: 'default_biz_pct')  double defaultBizPct,  DateTime? month, @JsonKey(name: 'sort_order')  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _BudgetDefault() when $default != null:
return $default(_that.id,_that.orgId,_that.category,_that.subcategory,_that.monthlyAmount,_that.defaultBizPct,_that.month,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetDefault implements BudgetDefault {
  const _BudgetDefault({required this.id, @JsonKey(name: 'org_id') required this.orgId, required this.category, required this.subcategory, @JsonKey(name: 'monthly_amount') required this.monthlyAmount, @JsonKey(name: 'default_biz_pct') required this.defaultBizPct, this.month, @JsonKey(name: 'sort_order') this.sortOrder = 0});
  factory _BudgetDefault.fromJson(Map<String, dynamic> json) => _$BudgetDefaultFromJson(json);

@override final  String id;
@override@JsonKey(name: 'org_id') final  String orgId;
@override final  String category;
@override final  String subcategory;
@override@JsonKey(name: 'monthly_amount') final  double monthlyAmount;
@override@JsonKey(name: 'default_biz_pct') final  double defaultBizPct;
@override final  DateTime? month;
@override@JsonKey(name: 'sort_order') final  int sortOrder;

/// Create a copy of BudgetDefault
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetDefaultCopyWith<_BudgetDefault> get copyWith => __$BudgetDefaultCopyWithImpl<_BudgetDefault>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetDefaultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetDefault&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.monthlyAmount, monthlyAmount) || other.monthlyAmount == monthlyAmount)&&(identical(other.defaultBizPct, defaultBizPct) || other.defaultBizPct == defaultBizPct)&&(identical(other.month, month) || other.month == month)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,category,subcategory,monthlyAmount,defaultBizPct,month,sortOrder);

@override
String toString() {
  return 'BudgetDefault(id: $id, orgId: $orgId, category: $category, subcategory: $subcategory, monthlyAmount: $monthlyAmount, defaultBizPct: $defaultBizPct, month: $month, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$BudgetDefaultCopyWith<$Res> implements $BudgetDefaultCopyWith<$Res> {
  factory _$BudgetDefaultCopyWith(_BudgetDefault value, $Res Function(_BudgetDefault) _then) = __$BudgetDefaultCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId, String category, String subcategory,@JsonKey(name: 'monthly_amount') double monthlyAmount,@JsonKey(name: 'default_biz_pct') double defaultBizPct, DateTime? month,@JsonKey(name: 'sort_order') int sortOrder
});




}
/// @nodoc
class __$BudgetDefaultCopyWithImpl<$Res>
    implements _$BudgetDefaultCopyWith<$Res> {
  __$BudgetDefaultCopyWithImpl(this._self, this._then);

  final _BudgetDefault _self;
  final $Res Function(_BudgetDefault) _then;

/// Create a copy of BudgetDefault
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? category = null,Object? subcategory = null,Object? monthlyAmount = null,Object? defaultBizPct = null,Object? month = freezed,Object? sortOrder = null,}) {
  return _then(_BudgetDefault(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: null == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String,monthlyAmount: null == monthlyAmount ? _self.monthlyAmount : monthlyAmount // ignore: cast_nullable_to_non_nullable
as double,defaultBizPct: null == defaultBizPct ? _self.defaultBizPct : defaultBizPct // ignore: cast_nullable_to_non_nullable
as double,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
