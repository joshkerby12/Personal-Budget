// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PantryStore {

 String get id;@JsonKey(name: 'org_id') String get orgId; String get name;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of PantryStore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryStoreCopyWith<PantryStore> get copyWith => _$PantryStoreCopyWithImpl<PantryStore>(this as PantryStore, _$identity);

  /// Serializes this PantryStore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryStore&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.name, name) || other.name == name)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,name,sortOrder,createdAt);

@override
String toString() {
  return 'PantryStore(id: $id, orgId: $orgId, name: $name, sortOrder: $sortOrder, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PantryStoreCopyWith<$Res>  {
  factory $PantryStoreCopyWith(PantryStore value, $Res Function(PantryStore) _then) = _$PantryStoreCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId, String name,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$PantryStoreCopyWithImpl<$Res>
    implements $PantryStoreCopyWith<$Res> {
  _$PantryStoreCopyWithImpl(this._self, this._then);

  final PantryStore _self;
  final $Res Function(PantryStore) _then;

/// Create a copy of PantryStore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? name = null,Object? sortOrder = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryStore].
extension PantryStorePatterns on PantryStore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryStore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryStore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryStore value)  $default,){
final _that = this;
switch (_that) {
case _PantryStore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryStore value)?  $default,){
final _that = this;
switch (_that) {
case _PantryStore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId,  String name, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryStore() when $default != null:
return $default(_that.id,_that.orgId,_that.name,_that.sortOrder,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId,  String name, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PantryStore():
return $default(_that.id,_that.orgId,_that.name,_that.sortOrder,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'org_id')  String orgId,  String name, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PantryStore() when $default != null:
return $default(_that.id,_that.orgId,_that.name,_that.sortOrder,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PantryStore implements PantryStore {
  const _PantryStore({required this.id, @JsonKey(name: 'org_id') required this.orgId, required this.name, @JsonKey(name: 'sort_order') required this.sortOrder, @JsonKey(name: 'created_at') required this.createdAt});
  factory _PantryStore.fromJson(Map<String, dynamic> json) => _$PantryStoreFromJson(json);

@override final  String id;
@override@JsonKey(name: 'org_id') final  String orgId;
@override final  String name;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of PantryStore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryStoreCopyWith<_PantryStore> get copyWith => __$PantryStoreCopyWithImpl<_PantryStore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PantryStoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryStore&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.name, name) || other.name == name)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,name,sortOrder,createdAt);

@override
String toString() {
  return 'PantryStore(id: $id, orgId: $orgId, name: $name, sortOrder: $sortOrder, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PantryStoreCopyWith<$Res> implements $PantryStoreCopyWith<$Res> {
  factory _$PantryStoreCopyWith(_PantryStore value, $Res Function(_PantryStore) _then) = __$PantryStoreCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId, String name,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$PantryStoreCopyWithImpl<$Res>
    implements _$PantryStoreCopyWith<$Res> {
  __$PantryStoreCopyWithImpl(this._self, this._then);

  final _PantryStore _self;
  final $Res Function(_PantryStore) _then;

/// Create a copy of PantryStore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? name = null,Object? sortOrder = null,Object? createdAt = null,}) {
  return _then(_PantryStore(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
