// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_meal_plan_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PantryMealPlanEntry {

 String get id;@JsonKey(name: 'org_id') String get orgId;@JsonKey(name: 'meal_id') String get mealId;@JsonKey(name: 'plan_date') DateTime get planDate;@JsonKey(name: 'meal_slot') String get mealSlot;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of PantryMealPlanEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryMealPlanEntryCopyWith<PantryMealPlanEntry> get copyWith => _$PantryMealPlanEntryCopyWithImpl<PantryMealPlanEntry>(this as PantryMealPlanEntry, _$identity);

  /// Serializes this PantryMealPlanEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryMealPlanEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.mealId, mealId) || other.mealId == mealId)&&(identical(other.planDate, planDate) || other.planDate == planDate)&&(identical(other.mealSlot, mealSlot) || other.mealSlot == mealSlot)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,mealId,planDate,mealSlot,createdAt);

@override
String toString() {
  return 'PantryMealPlanEntry(id: $id, orgId: $orgId, mealId: $mealId, planDate: $planDate, mealSlot: $mealSlot, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PantryMealPlanEntryCopyWith<$Res>  {
  factory $PantryMealPlanEntryCopyWith(PantryMealPlanEntry value, $Res Function(PantryMealPlanEntry) _then) = _$PantryMealPlanEntryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'meal_id') String mealId,@JsonKey(name: 'plan_date') DateTime planDate,@JsonKey(name: 'meal_slot') String mealSlot,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$PantryMealPlanEntryCopyWithImpl<$Res>
    implements $PantryMealPlanEntryCopyWith<$Res> {
  _$PantryMealPlanEntryCopyWithImpl(this._self, this._then);

  final PantryMealPlanEntry _self;
  final $Res Function(PantryMealPlanEntry) _then;

/// Create a copy of PantryMealPlanEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? mealId = null,Object? planDate = null,Object? mealSlot = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,mealId: null == mealId ? _self.mealId : mealId // ignore: cast_nullable_to_non_nullable
as String,planDate: null == planDate ? _self.planDate : planDate // ignore: cast_nullable_to_non_nullable
as DateTime,mealSlot: null == mealSlot ? _self.mealSlot : mealSlot // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryMealPlanEntry].
extension PantryMealPlanEntryPatterns on PantryMealPlanEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryMealPlanEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryMealPlanEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryMealPlanEntry value)  $default,){
final _that = this;
switch (_that) {
case _PantryMealPlanEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryMealPlanEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PantryMealPlanEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'meal_id')  String mealId, @JsonKey(name: 'plan_date')  DateTime planDate, @JsonKey(name: 'meal_slot')  String mealSlot, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryMealPlanEntry() when $default != null:
return $default(_that.id,_that.orgId,_that.mealId,_that.planDate,_that.mealSlot,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'meal_id')  String mealId, @JsonKey(name: 'plan_date')  DateTime planDate, @JsonKey(name: 'meal_slot')  String mealSlot, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PantryMealPlanEntry():
return $default(_that.id,_that.orgId,_that.mealId,_that.planDate,_that.mealSlot,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'meal_id')  String mealId, @JsonKey(name: 'plan_date')  DateTime planDate, @JsonKey(name: 'meal_slot')  String mealSlot, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PantryMealPlanEntry() when $default != null:
return $default(_that.id,_that.orgId,_that.mealId,_that.planDate,_that.mealSlot,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PantryMealPlanEntry implements PantryMealPlanEntry {
  const _PantryMealPlanEntry({required this.id, @JsonKey(name: 'org_id') required this.orgId, @JsonKey(name: 'meal_id') required this.mealId, @JsonKey(name: 'plan_date') required this.planDate, @JsonKey(name: 'meal_slot') required this.mealSlot, @JsonKey(name: 'created_at') required this.createdAt});
  factory _PantryMealPlanEntry.fromJson(Map<String, dynamic> json) => _$PantryMealPlanEntryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'org_id') final  String orgId;
@override@JsonKey(name: 'meal_id') final  String mealId;
@override@JsonKey(name: 'plan_date') final  DateTime planDate;
@override@JsonKey(name: 'meal_slot') final  String mealSlot;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of PantryMealPlanEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryMealPlanEntryCopyWith<_PantryMealPlanEntry> get copyWith => __$PantryMealPlanEntryCopyWithImpl<_PantryMealPlanEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PantryMealPlanEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryMealPlanEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.mealId, mealId) || other.mealId == mealId)&&(identical(other.planDate, planDate) || other.planDate == planDate)&&(identical(other.mealSlot, mealSlot) || other.mealSlot == mealSlot)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,mealId,planDate,mealSlot,createdAt);

@override
String toString() {
  return 'PantryMealPlanEntry(id: $id, orgId: $orgId, mealId: $mealId, planDate: $planDate, mealSlot: $mealSlot, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PantryMealPlanEntryCopyWith<$Res> implements $PantryMealPlanEntryCopyWith<$Res> {
  factory _$PantryMealPlanEntryCopyWith(_PantryMealPlanEntry value, $Res Function(_PantryMealPlanEntry) _then) = __$PantryMealPlanEntryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'meal_id') String mealId,@JsonKey(name: 'plan_date') DateTime planDate,@JsonKey(name: 'meal_slot') String mealSlot,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$PantryMealPlanEntryCopyWithImpl<$Res>
    implements _$PantryMealPlanEntryCopyWith<$Res> {
  __$PantryMealPlanEntryCopyWithImpl(this._self, this._then);

  final _PantryMealPlanEntry _self;
  final $Res Function(_PantryMealPlanEntry) _then;

/// Create a copy of PantryMealPlanEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? mealId = null,Object? planDate = null,Object? mealSlot = null,Object? createdAt = null,}) {
  return _then(_PantryMealPlanEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,mealId: null == mealId ? _self.mealId : mealId // ignore: cast_nullable_to_non_nullable
as String,planDate: null == planDate ? _self.planDate : planDate // ignore: cast_nullable_to_non_nullable
as DateTime,mealSlot: null == mealSlot ? _self.mealSlot : mealSlot // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
