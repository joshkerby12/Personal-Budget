// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teller_enrollment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TellerEnrollment {

 String get id;@JsonKey(name: 'org_id') String get orgId;@JsonKey(name: 'profile_id') String get profileId;@JsonKey(name: 'teller_enrollment_id') String get tellerEnrollmentId;@JsonKey(name: 'institution_name') String get institutionName;@JsonKey(name: 'account_name') String get accountName;@JsonKey(name: 'account_last_four') String? get accountLastFour;@JsonKey(name: 'account_type') String get accountType;@JsonKey(name: 'account_subtype') String? get accountSubtype;@JsonKey(name: 'last_synced_at') DateTime? get lastSyncedAt;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of TellerEnrollment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TellerEnrollmentCopyWith<TellerEnrollment> get copyWith => _$TellerEnrollmentCopyWithImpl<TellerEnrollment>(this as TellerEnrollment, _$identity);

  /// Serializes this TellerEnrollment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TellerEnrollment&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.tellerEnrollmentId, tellerEnrollmentId) || other.tellerEnrollmentId == tellerEnrollmentId)&&(identical(other.institutionName, institutionName) || other.institutionName == institutionName)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountLastFour, accountLastFour) || other.accountLastFour == accountLastFour)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.accountSubtype, accountSubtype) || other.accountSubtype == accountSubtype)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,profileId,tellerEnrollmentId,institutionName,accountName,accountLastFour,accountType,accountSubtype,lastSyncedAt,isActive,createdAt);

@override
String toString() {
  return 'TellerEnrollment(id: $id, orgId: $orgId, profileId: $profileId, tellerEnrollmentId: $tellerEnrollmentId, institutionName: $institutionName, accountName: $accountName, accountLastFour: $accountLastFour, accountType: $accountType, accountSubtype: $accountSubtype, lastSyncedAt: $lastSyncedAt, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TellerEnrollmentCopyWith<$Res>  {
  factory $TellerEnrollmentCopyWith(TellerEnrollment value, $Res Function(TellerEnrollment) _then) = _$TellerEnrollmentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'profile_id') String profileId,@JsonKey(name: 'teller_enrollment_id') String tellerEnrollmentId,@JsonKey(name: 'institution_name') String institutionName,@JsonKey(name: 'account_name') String accountName,@JsonKey(name: 'account_last_four') String? accountLastFour,@JsonKey(name: 'account_type') String accountType,@JsonKey(name: 'account_subtype') String? accountSubtype,@JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$TellerEnrollmentCopyWithImpl<$Res>
    implements $TellerEnrollmentCopyWith<$Res> {
  _$TellerEnrollmentCopyWithImpl(this._self, this._then);

  final TellerEnrollment _self;
  final $Res Function(TellerEnrollment) _then;

/// Create a copy of TellerEnrollment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? profileId = null,Object? tellerEnrollmentId = null,Object? institutionName = null,Object? accountName = null,Object? accountLastFour = freezed,Object? accountType = null,Object? accountSubtype = freezed,Object? lastSyncedAt = freezed,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,tellerEnrollmentId: null == tellerEnrollmentId ? _self.tellerEnrollmentId : tellerEnrollmentId // ignore: cast_nullable_to_non_nullable
as String,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,accountLastFour: freezed == accountLastFour ? _self.accountLastFour : accountLastFour // ignore: cast_nullable_to_non_nullable
as String?,accountType: null == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as String,accountSubtype: freezed == accountSubtype ? _self.accountSubtype : accountSubtype // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TellerEnrollment].
extension TellerEnrollmentPatterns on TellerEnrollment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TellerEnrollment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TellerEnrollment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TellerEnrollment value)  $default,){
final _that = this;
switch (_that) {
case _TellerEnrollment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TellerEnrollment value)?  $default,){
final _that = this;
switch (_that) {
case _TellerEnrollment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'teller_enrollment_id')  String tellerEnrollmentId, @JsonKey(name: 'institution_name')  String institutionName, @JsonKey(name: 'account_name')  String accountName, @JsonKey(name: 'account_last_four')  String? accountLastFour, @JsonKey(name: 'account_type')  String accountType, @JsonKey(name: 'account_subtype')  String? accountSubtype, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TellerEnrollment() when $default != null:
return $default(_that.id,_that.orgId,_that.profileId,_that.tellerEnrollmentId,_that.institutionName,_that.accountName,_that.accountLastFour,_that.accountType,_that.accountSubtype,_that.lastSyncedAt,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'teller_enrollment_id')  String tellerEnrollmentId, @JsonKey(name: 'institution_name')  String institutionName, @JsonKey(name: 'account_name')  String accountName, @JsonKey(name: 'account_last_four')  String? accountLastFour, @JsonKey(name: 'account_type')  String accountType, @JsonKey(name: 'account_subtype')  String? accountSubtype, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TellerEnrollment():
return $default(_that.id,_that.orgId,_that.profileId,_that.tellerEnrollmentId,_that.institutionName,_that.accountName,_that.accountLastFour,_that.accountType,_that.accountSubtype,_that.lastSyncedAt,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'teller_enrollment_id')  String tellerEnrollmentId, @JsonKey(name: 'institution_name')  String institutionName, @JsonKey(name: 'account_name')  String accountName, @JsonKey(name: 'account_last_four')  String? accountLastFour, @JsonKey(name: 'account_type')  String accountType, @JsonKey(name: 'account_subtype')  String? accountSubtype, @JsonKey(name: 'last_synced_at')  DateTime? lastSyncedAt, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TellerEnrollment() when $default != null:
return $default(_that.id,_that.orgId,_that.profileId,_that.tellerEnrollmentId,_that.institutionName,_that.accountName,_that.accountLastFour,_that.accountType,_that.accountSubtype,_that.lastSyncedAt,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TellerEnrollment implements TellerEnrollment {
  const _TellerEnrollment({required this.id, @JsonKey(name: 'org_id') required this.orgId, @JsonKey(name: 'profile_id') required this.profileId, @JsonKey(name: 'teller_enrollment_id') required this.tellerEnrollmentId, @JsonKey(name: 'institution_name') required this.institutionName, @JsonKey(name: 'account_name') required this.accountName, @JsonKey(name: 'account_last_four') this.accountLastFour, @JsonKey(name: 'account_type') required this.accountType, @JsonKey(name: 'account_subtype') this.accountSubtype, @JsonKey(name: 'last_synced_at') this.lastSyncedAt, @JsonKey(name: 'is_active') required this.isActive, @JsonKey(name: 'created_at') required this.createdAt});
  factory _TellerEnrollment.fromJson(Map<String, dynamic> json) => _$TellerEnrollmentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'org_id') final  String orgId;
@override@JsonKey(name: 'profile_id') final  String profileId;
@override@JsonKey(name: 'teller_enrollment_id') final  String tellerEnrollmentId;
@override@JsonKey(name: 'institution_name') final  String institutionName;
@override@JsonKey(name: 'account_name') final  String accountName;
@override@JsonKey(name: 'account_last_four') final  String? accountLastFour;
@override@JsonKey(name: 'account_type') final  String accountType;
@override@JsonKey(name: 'account_subtype') final  String? accountSubtype;
@override@JsonKey(name: 'last_synced_at') final  DateTime? lastSyncedAt;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of TellerEnrollment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TellerEnrollmentCopyWith<_TellerEnrollment> get copyWith => __$TellerEnrollmentCopyWithImpl<_TellerEnrollment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TellerEnrollmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TellerEnrollment&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.tellerEnrollmentId, tellerEnrollmentId) || other.tellerEnrollmentId == tellerEnrollmentId)&&(identical(other.institutionName, institutionName) || other.institutionName == institutionName)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountLastFour, accountLastFour) || other.accountLastFour == accountLastFour)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.accountSubtype, accountSubtype) || other.accountSubtype == accountSubtype)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,profileId,tellerEnrollmentId,institutionName,accountName,accountLastFour,accountType,accountSubtype,lastSyncedAt,isActive,createdAt);

@override
String toString() {
  return 'TellerEnrollment(id: $id, orgId: $orgId, profileId: $profileId, tellerEnrollmentId: $tellerEnrollmentId, institutionName: $institutionName, accountName: $accountName, accountLastFour: $accountLastFour, accountType: $accountType, accountSubtype: $accountSubtype, lastSyncedAt: $lastSyncedAt, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TellerEnrollmentCopyWith<$Res> implements $TellerEnrollmentCopyWith<$Res> {
  factory _$TellerEnrollmentCopyWith(_TellerEnrollment value, $Res Function(_TellerEnrollment) _then) = __$TellerEnrollmentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'profile_id') String profileId,@JsonKey(name: 'teller_enrollment_id') String tellerEnrollmentId,@JsonKey(name: 'institution_name') String institutionName,@JsonKey(name: 'account_name') String accountName,@JsonKey(name: 'account_last_four') String? accountLastFour,@JsonKey(name: 'account_type') String accountType,@JsonKey(name: 'account_subtype') String? accountSubtype,@JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$TellerEnrollmentCopyWithImpl<$Res>
    implements _$TellerEnrollmentCopyWith<$Res> {
  __$TellerEnrollmentCopyWithImpl(this._self, this._then);

  final _TellerEnrollment _self;
  final $Res Function(_TellerEnrollment) _then;

/// Create a copy of TellerEnrollment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? profileId = null,Object? tellerEnrollmentId = null,Object? institutionName = null,Object? accountName = null,Object? accountLastFour = freezed,Object? accountType = null,Object? accountSubtype = freezed,Object? lastSyncedAt = freezed,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_TellerEnrollment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,tellerEnrollmentId: null == tellerEnrollmentId ? _self.tellerEnrollmentId : tellerEnrollmentId // ignore: cast_nullable_to_non_nullable
as String,institutionName: null == institutionName ? _self.institutionName : institutionName // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,accountLastFour: freezed == accountLastFour ? _self.accountLastFour : accountLastFour // ignore: cast_nullable_to_non_nullable
as String?,accountType: null == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as String,accountSubtype: freezed == accountSubtype ? _self.accountSubtype : accountSubtype // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
