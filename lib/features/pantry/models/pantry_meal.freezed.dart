// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_meal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PantryMeal {

 String get id;@JsonKey(name: 'org_id') String get orgId; String get name; List<String> get ingredients;@JsonKey(name: 'cost_per_serving') double? get costPerServing; int get servings; String get source; String? get url;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of PantryMeal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryMealCopyWith<PantryMeal> get copyWith => _$PantryMealCopyWithImpl<PantryMeal>(this as PantryMeal, _$identity);

  /// Serializes this PantryMeal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryMeal&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.ingredients, ingredients)&&(identical(other.costPerServing, costPerServing) || other.costPerServing == costPerServing)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.source, source) || other.source == source)&&(identical(other.url, url) || other.url == url)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,name,const DeepCollectionEquality().hash(ingredients),costPerServing,servings,source,url,createdAt);

@override
String toString() {
  return 'PantryMeal(id: $id, orgId: $orgId, name: $name, ingredients: $ingredients, costPerServing: $costPerServing, servings: $servings, source: $source, url: $url, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PantryMealCopyWith<$Res>  {
  factory $PantryMealCopyWith(PantryMeal value, $Res Function(PantryMeal) _then) = _$PantryMealCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId, String name, List<String> ingredients,@JsonKey(name: 'cost_per_serving') double? costPerServing, int servings, String source, String? url,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$PantryMealCopyWithImpl<$Res>
    implements $PantryMealCopyWith<$Res> {
  _$PantryMealCopyWithImpl(this._self, this._then);

  final PantryMeal _self;
  final $Res Function(PantryMeal) _then;

/// Create a copy of PantryMeal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? name = null,Object? ingredients = null,Object? costPerServing = freezed,Object? servings = null,Object? source = null,Object? url = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,costPerServing: freezed == costPerServing ? _self.costPerServing : costPerServing // ignore: cast_nullable_to_non_nullable
as double?,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryMeal].
extension PantryMealPatterns on PantryMeal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryMeal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryMeal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryMeal value)  $default,){
final _that = this;
switch (_that) {
case _PantryMeal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryMeal value)?  $default,){
final _that = this;
switch (_that) {
case _PantryMeal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId,  String name,  List<String> ingredients, @JsonKey(name: 'cost_per_serving')  double? costPerServing,  int servings,  String source,  String? url, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryMeal() when $default != null:
return $default(_that.id,_that.orgId,_that.name,_that.ingredients,_that.costPerServing,_that.servings,_that.source,_that.url,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId,  String name,  List<String> ingredients, @JsonKey(name: 'cost_per_serving')  double? costPerServing,  int servings,  String source,  String? url, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PantryMeal():
return $default(_that.id,_that.orgId,_that.name,_that.ingredients,_that.costPerServing,_that.servings,_that.source,_that.url,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'org_id')  String orgId,  String name,  List<String> ingredients, @JsonKey(name: 'cost_per_serving')  double? costPerServing,  int servings,  String source,  String? url, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PantryMeal() when $default != null:
return $default(_that.id,_that.orgId,_that.name,_that.ingredients,_that.costPerServing,_that.servings,_that.source,_that.url,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PantryMeal implements PantryMeal {
  const _PantryMeal({required this.id, @JsonKey(name: 'org_id') required this.orgId, required this.name, required final  List<String> ingredients, @JsonKey(name: 'cost_per_serving') this.costPerServing, required this.servings, required this.source, this.url, @JsonKey(name: 'created_at') required this.createdAt}): _ingredients = ingredients;
  factory _PantryMeal.fromJson(Map<String, dynamic> json) => _$PantryMealFromJson(json);

@override final  String id;
@override@JsonKey(name: 'org_id') final  String orgId;
@override final  String name;
 final  List<String> _ingredients;
@override List<String> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

@override@JsonKey(name: 'cost_per_serving') final  double? costPerServing;
@override final  int servings;
@override final  String source;
@override final  String? url;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of PantryMeal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryMealCopyWith<_PantryMeal> get copyWith => __$PantryMealCopyWithImpl<_PantryMeal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PantryMealToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryMeal&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients)&&(identical(other.costPerServing, costPerServing) || other.costPerServing == costPerServing)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.source, source) || other.source == source)&&(identical(other.url, url) || other.url == url)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,name,const DeepCollectionEquality().hash(_ingredients),costPerServing,servings,source,url,createdAt);

@override
String toString() {
  return 'PantryMeal(id: $id, orgId: $orgId, name: $name, ingredients: $ingredients, costPerServing: $costPerServing, servings: $servings, source: $source, url: $url, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PantryMealCopyWith<$Res> implements $PantryMealCopyWith<$Res> {
  factory _$PantryMealCopyWith(_PantryMeal value, $Res Function(_PantryMeal) _then) = __$PantryMealCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId, String name, List<String> ingredients,@JsonKey(name: 'cost_per_serving') double? costPerServing, int servings, String source, String? url,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$PantryMealCopyWithImpl<$Res>
    implements _$PantryMealCopyWith<$Res> {
  __$PantryMealCopyWithImpl(this._self, this._then);

  final _PantryMeal _self;
  final $Res Function(_PantryMeal) _then;

/// Create a copy of PantryMeal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? name = null,Object? ingredients = null,Object? costPerServing = freezed,Object? servings = null,Object? source = null,Object? url = freezed,Object? createdAt = null,}) {
  return _then(_PantryMeal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,costPerServing: freezed == costPerServing ? _self.costPerServing : costPerServing // ignore: cast_nullable_to_non_nullable
as double?,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
