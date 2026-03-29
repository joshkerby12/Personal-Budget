// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'csv_import_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CsvImportLog {

 String get id;@JsonKey(name: 'org_id') String get orgId;@JsonKey(name: 'created_by') String get createdBy; String get institution; String get filename;@JsonKey(name: 'imported_at') DateTime get importedAt;@JsonKey(name: 'transaction_count') int get transactionCount;
/// Create a copy of CsvImportLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CsvImportLogCopyWith<CsvImportLog> get copyWith => _$CsvImportLogCopyWithImpl<CsvImportLog>(this as CsvImportLog, _$identity);

  /// Serializes this CsvImportLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CsvImportLog&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.institution, institution) || other.institution == institution)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,createdBy,institution,filename,importedAt,transactionCount);

@override
String toString() {
  return 'CsvImportLog(id: $id, orgId: $orgId, createdBy: $createdBy, institution: $institution, filename: $filename, importedAt: $importedAt, transactionCount: $transactionCount)';
}


}

/// @nodoc
abstract mixin class $CsvImportLogCopyWith<$Res>  {
  factory $CsvImportLogCopyWith(CsvImportLog value, $Res Function(CsvImportLog) _then) = _$CsvImportLogCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'created_by') String createdBy, String institution, String filename,@JsonKey(name: 'imported_at') DateTime importedAt,@JsonKey(name: 'transaction_count') int transactionCount
});




}
/// @nodoc
class _$CsvImportLogCopyWithImpl<$Res>
    implements $CsvImportLogCopyWith<$Res> {
  _$CsvImportLogCopyWithImpl(this._self, this._then);

  final CsvImportLog _self;
  final $Res Function(CsvImportLog) _then;

/// Create a copy of CsvImportLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? createdBy = null,Object? institution = null,Object? filename = null,Object? importedAt = null,Object? transactionCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,institution: null == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CsvImportLog].
extension CsvImportLogPatterns on CsvImportLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CsvImportLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CsvImportLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CsvImportLog value)  $default,){
final _that = this;
switch (_that) {
case _CsvImportLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CsvImportLog value)?  $default,){
final _that = this;
switch (_that) {
case _CsvImportLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'created_by')  String createdBy,  String institution,  String filename, @JsonKey(name: 'imported_at')  DateTime importedAt, @JsonKey(name: 'transaction_count')  int transactionCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CsvImportLog() when $default != null:
return $default(_that.id,_that.orgId,_that.createdBy,_that.institution,_that.filename,_that.importedAt,_that.transactionCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'created_by')  String createdBy,  String institution,  String filename, @JsonKey(name: 'imported_at')  DateTime importedAt, @JsonKey(name: 'transaction_count')  int transactionCount)  $default,) {final _that = this;
switch (_that) {
case _CsvImportLog():
return $default(_that.id,_that.orgId,_that.createdBy,_that.institution,_that.filename,_that.importedAt,_that.transactionCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'created_by')  String createdBy,  String institution,  String filename, @JsonKey(name: 'imported_at')  DateTime importedAt, @JsonKey(name: 'transaction_count')  int transactionCount)?  $default,) {final _that = this;
switch (_that) {
case _CsvImportLog() when $default != null:
return $default(_that.id,_that.orgId,_that.createdBy,_that.institution,_that.filename,_that.importedAt,_that.transactionCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CsvImportLog implements CsvImportLog {
  const _CsvImportLog({required this.id, @JsonKey(name: 'org_id') required this.orgId, @JsonKey(name: 'created_by') required this.createdBy, required this.institution, required this.filename, @JsonKey(name: 'imported_at') required this.importedAt, @JsonKey(name: 'transaction_count') required this.transactionCount});
  factory _CsvImportLog.fromJson(Map<String, dynamic> json) => _$CsvImportLogFromJson(json);

@override final  String id;
@override@JsonKey(name: 'org_id') final  String orgId;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override final  String institution;
@override final  String filename;
@override@JsonKey(name: 'imported_at') final  DateTime importedAt;
@override@JsonKey(name: 'transaction_count') final  int transactionCount;

/// Create a copy of CsvImportLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CsvImportLogCopyWith<_CsvImportLog> get copyWith => __$CsvImportLogCopyWithImpl<_CsvImportLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CsvImportLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CsvImportLog&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.institution, institution) || other.institution == institution)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,createdBy,institution,filename,importedAt,transactionCount);

@override
String toString() {
  return 'CsvImportLog(id: $id, orgId: $orgId, createdBy: $createdBy, institution: $institution, filename: $filename, importedAt: $importedAt, transactionCount: $transactionCount)';
}


}

/// @nodoc
abstract mixin class _$CsvImportLogCopyWith<$Res> implements $CsvImportLogCopyWith<$Res> {
  factory _$CsvImportLogCopyWith(_CsvImportLog value, $Res Function(_CsvImportLog) _then) = __$CsvImportLogCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'created_by') String createdBy, String institution, String filename,@JsonKey(name: 'imported_at') DateTime importedAt,@JsonKey(name: 'transaction_count') int transactionCount
});




}
/// @nodoc
class __$CsvImportLogCopyWithImpl<$Res>
    implements _$CsvImportLogCopyWith<$Res> {
  __$CsvImportLogCopyWithImpl(this._self, this._then);

  final _CsvImportLog _self;
  final $Res Function(_CsvImportLog) _then;

/// Create a copy of CsvImportLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? createdBy = null,Object? institution = null,Object? filename = null,Object? importedAt = null,Object? transactionCount = null,}) {
  return _then(_CsvImportLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,institution: null == institution ? _self.institution : institution // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
