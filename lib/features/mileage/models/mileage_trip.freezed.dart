// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mileage_trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MileageTrip {

 String get id;@JsonKey(name: 'org_id') String get orgId;@JsonKey(name: 'created_by') String get createdBy; DateTime get date; String get purpose;@JsonKey(name: 'from_address') String get fromAddress;@JsonKey(name: 'to_address') String get toAddress;@JsonKey(name: 'one_way_miles') double get oneWayMiles;@JsonKey(name: 'is_round_trip') bool get isRoundTrip;@JsonKey(name: 'biz_pct') double get bizPct; String get category;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of MileageTrip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MileageTripCopyWith<MileageTrip> get copyWith => _$MileageTripCopyWithImpl<MileageTrip>(this as MileageTrip, _$identity);

  /// Serializes this MileageTrip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MileageTrip&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.date, date) || other.date == date)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.fromAddress, fromAddress) || other.fromAddress == fromAddress)&&(identical(other.toAddress, toAddress) || other.toAddress == toAddress)&&(identical(other.oneWayMiles, oneWayMiles) || other.oneWayMiles == oneWayMiles)&&(identical(other.isRoundTrip, isRoundTrip) || other.isRoundTrip == isRoundTrip)&&(identical(other.bizPct, bizPct) || other.bizPct == bizPct)&&(identical(other.category, category) || other.category == category)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,createdBy,date,purpose,fromAddress,toAddress,oneWayMiles,isRoundTrip,bizPct,category,createdAt);

@override
String toString() {
  return 'MileageTrip(id: $id, orgId: $orgId, createdBy: $createdBy, date: $date, purpose: $purpose, fromAddress: $fromAddress, toAddress: $toAddress, oneWayMiles: $oneWayMiles, isRoundTrip: $isRoundTrip, bizPct: $bizPct, category: $category, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MileageTripCopyWith<$Res>  {
  factory $MileageTripCopyWith(MileageTrip value, $Res Function(MileageTrip) _then) = _$MileageTripCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'created_by') String createdBy, DateTime date, String purpose,@JsonKey(name: 'from_address') String fromAddress,@JsonKey(name: 'to_address') String toAddress,@JsonKey(name: 'one_way_miles') double oneWayMiles,@JsonKey(name: 'is_round_trip') bool isRoundTrip,@JsonKey(name: 'biz_pct') double bizPct, String category,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$MileageTripCopyWithImpl<$Res>
    implements $MileageTripCopyWith<$Res> {
  _$MileageTripCopyWithImpl(this._self, this._then);

  final MileageTrip _self;
  final $Res Function(MileageTrip) _then;

/// Create a copy of MileageTrip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? createdBy = null,Object? date = null,Object? purpose = null,Object? fromAddress = null,Object? toAddress = null,Object? oneWayMiles = null,Object? isRoundTrip = null,Object? bizPct = null,Object? category = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,fromAddress: null == fromAddress ? _self.fromAddress : fromAddress // ignore: cast_nullable_to_non_nullable
as String,toAddress: null == toAddress ? _self.toAddress : toAddress // ignore: cast_nullable_to_non_nullable
as String,oneWayMiles: null == oneWayMiles ? _self.oneWayMiles : oneWayMiles // ignore: cast_nullable_to_non_nullable
as double,isRoundTrip: null == isRoundTrip ? _self.isRoundTrip : isRoundTrip // ignore: cast_nullable_to_non_nullable
as bool,bizPct: null == bizPct ? _self.bizPct : bizPct // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MileageTrip].
extension MileageTripPatterns on MileageTrip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MileageTrip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MileageTrip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MileageTrip value)  $default,){
final _that = this;
switch (_that) {
case _MileageTrip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MileageTrip value)?  $default,){
final _that = this;
switch (_that) {
case _MileageTrip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'created_by')  String createdBy,  DateTime date,  String purpose, @JsonKey(name: 'from_address')  String fromAddress, @JsonKey(name: 'to_address')  String toAddress, @JsonKey(name: 'one_way_miles')  double oneWayMiles, @JsonKey(name: 'is_round_trip')  bool isRoundTrip, @JsonKey(name: 'biz_pct')  double bizPct,  String category, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MileageTrip() when $default != null:
return $default(_that.id,_that.orgId,_that.createdBy,_that.date,_that.purpose,_that.fromAddress,_that.toAddress,_that.oneWayMiles,_that.isRoundTrip,_that.bizPct,_that.category,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'created_by')  String createdBy,  DateTime date,  String purpose, @JsonKey(name: 'from_address')  String fromAddress, @JsonKey(name: 'to_address')  String toAddress, @JsonKey(name: 'one_way_miles')  double oneWayMiles, @JsonKey(name: 'is_round_trip')  bool isRoundTrip, @JsonKey(name: 'biz_pct')  double bizPct,  String category, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MileageTrip():
return $default(_that.id,_that.orgId,_that.createdBy,_that.date,_that.purpose,_that.fromAddress,_that.toAddress,_that.oneWayMiles,_that.isRoundTrip,_that.bizPct,_that.category,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'created_by')  String createdBy,  DateTime date,  String purpose, @JsonKey(name: 'from_address')  String fromAddress, @JsonKey(name: 'to_address')  String toAddress, @JsonKey(name: 'one_way_miles')  double oneWayMiles, @JsonKey(name: 'is_round_trip')  bool isRoundTrip, @JsonKey(name: 'biz_pct')  double bizPct,  String category, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MileageTrip() when $default != null:
return $default(_that.id,_that.orgId,_that.createdBy,_that.date,_that.purpose,_that.fromAddress,_that.toAddress,_that.oneWayMiles,_that.isRoundTrip,_that.bizPct,_that.category,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MileageTrip implements MileageTrip {
  const _MileageTrip({required this.id, @JsonKey(name: 'org_id') required this.orgId, @JsonKey(name: 'created_by') required this.createdBy, required this.date, required this.purpose, @JsonKey(name: 'from_address') required this.fromAddress, @JsonKey(name: 'to_address') required this.toAddress, @JsonKey(name: 'one_way_miles') required this.oneWayMiles, @JsonKey(name: 'is_round_trip') required this.isRoundTrip, @JsonKey(name: 'biz_pct') required this.bizPct, required this.category, @JsonKey(name: 'created_at') required this.createdAt});
  factory _MileageTrip.fromJson(Map<String, dynamic> json) => _$MileageTripFromJson(json);

@override final  String id;
@override@JsonKey(name: 'org_id') final  String orgId;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override final  DateTime date;
@override final  String purpose;
@override@JsonKey(name: 'from_address') final  String fromAddress;
@override@JsonKey(name: 'to_address') final  String toAddress;
@override@JsonKey(name: 'one_way_miles') final  double oneWayMiles;
@override@JsonKey(name: 'is_round_trip') final  bool isRoundTrip;
@override@JsonKey(name: 'biz_pct') final  double bizPct;
@override final  String category;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of MileageTrip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MileageTripCopyWith<_MileageTrip> get copyWith => __$MileageTripCopyWithImpl<_MileageTrip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MileageTripToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MileageTrip&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.date, date) || other.date == date)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.fromAddress, fromAddress) || other.fromAddress == fromAddress)&&(identical(other.toAddress, toAddress) || other.toAddress == toAddress)&&(identical(other.oneWayMiles, oneWayMiles) || other.oneWayMiles == oneWayMiles)&&(identical(other.isRoundTrip, isRoundTrip) || other.isRoundTrip == isRoundTrip)&&(identical(other.bizPct, bizPct) || other.bizPct == bizPct)&&(identical(other.category, category) || other.category == category)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,createdBy,date,purpose,fromAddress,toAddress,oneWayMiles,isRoundTrip,bizPct,category,createdAt);

@override
String toString() {
  return 'MileageTrip(id: $id, orgId: $orgId, createdBy: $createdBy, date: $date, purpose: $purpose, fromAddress: $fromAddress, toAddress: $toAddress, oneWayMiles: $oneWayMiles, isRoundTrip: $isRoundTrip, bizPct: $bizPct, category: $category, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MileageTripCopyWith<$Res> implements $MileageTripCopyWith<$Res> {
  factory _$MileageTripCopyWith(_MileageTrip value, $Res Function(_MileageTrip) _then) = __$MileageTripCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'created_by') String createdBy, DateTime date, String purpose,@JsonKey(name: 'from_address') String fromAddress,@JsonKey(name: 'to_address') String toAddress,@JsonKey(name: 'one_way_miles') double oneWayMiles,@JsonKey(name: 'is_round_trip') bool isRoundTrip,@JsonKey(name: 'biz_pct') double bizPct, String category,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$MileageTripCopyWithImpl<$Res>
    implements _$MileageTripCopyWith<$Res> {
  __$MileageTripCopyWithImpl(this._self, this._then);

  final _MileageTrip _self;
  final $Res Function(_MileageTrip) _then;

/// Create a copy of MileageTrip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? createdBy = null,Object? date = null,Object? purpose = null,Object? fromAddress = null,Object? toAddress = null,Object? oneWayMiles = null,Object? isRoundTrip = null,Object? bizPct = null,Object? category = null,Object? createdAt = null,}) {
  return _then(_MileageTrip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,fromAddress: null == fromAddress ? _self.fromAddress : fromAddress // ignore: cast_nullable_to_non_nullable
as String,toAddress: null == toAddress ? _self.toAddress : toAddress // ignore: cast_nullable_to_non_nullable
as String,oneWayMiles: null == oneWayMiles ? _self.oneWayMiles : oneWayMiles // ignore: cast_nullable_to_non_nullable
as double,isRoundTrip: null == isRoundTrip ? _self.isRoundTrip : isRoundTrip // ignore: cast_nullable_to_non_nullable
as bool,bizPct: null == bizPct ? _self.bizPct : bizPct // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
