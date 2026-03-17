// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Receipt {

 String get id;@JsonKey(name: 'org_id') String get orgId;@JsonKey(name: 'transaction_id') String? get transactionId; String get filename;@JsonKey(name: 'storage_path') String get storagePath;@JsonKey(name: 'mime_type') String get mimeType;@JsonKey(name: 'size_bytes') int get sizeBytes;@JsonKey(name: 'uploaded_by') String get uploadedBy;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptCopyWith<Receipt> get copyWith => _$ReceiptCopyWithImpl<Receipt>(this as Receipt, _$identity);

  /// Serializes this Receipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Receipt&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,transactionId,filename,storagePath,mimeType,sizeBytes,uploadedBy,createdAt);

@override
String toString() {
  return 'Receipt(id: $id, orgId: $orgId, transactionId: $transactionId, filename: $filename, storagePath: $storagePath, mimeType: $mimeType, sizeBytes: $sizeBytes, uploadedBy: $uploadedBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ReceiptCopyWith<$Res>  {
  factory $ReceiptCopyWith(Receipt value, $Res Function(Receipt) _then) = _$ReceiptCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'transaction_id') String? transactionId, String filename,@JsonKey(name: 'storage_path') String storagePath,@JsonKey(name: 'mime_type') String mimeType,@JsonKey(name: 'size_bytes') int sizeBytes,@JsonKey(name: 'uploaded_by') String uploadedBy,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$ReceiptCopyWithImpl<$Res>
    implements $ReceiptCopyWith<$Res> {
  _$ReceiptCopyWithImpl(this._self, this._then);

  final Receipt _self;
  final $Res Function(Receipt) _then;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? transactionId = freezed,Object? filename = null,Object? storagePath = null,Object? mimeType = null,Object? sizeBytes = null,Object? uploadedBy = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Receipt].
extension ReceiptPatterns on Receipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Receipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Receipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Receipt value)  $default,){
final _that = this;
switch (_that) {
case _Receipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Receipt value)?  $default,){
final _that = this;
switch (_that) {
case _Receipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'transaction_id')  String? transactionId,  String filename, @JsonKey(name: 'storage_path')  String storagePath, @JsonKey(name: 'mime_type')  String mimeType, @JsonKey(name: 'size_bytes')  int sizeBytes, @JsonKey(name: 'uploaded_by')  String uploadedBy, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.orgId,_that.transactionId,_that.filename,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.uploadedBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'transaction_id')  String? transactionId,  String filename, @JsonKey(name: 'storage_path')  String storagePath, @JsonKey(name: 'mime_type')  String mimeType, @JsonKey(name: 'size_bytes')  int sizeBytes, @JsonKey(name: 'uploaded_by')  String uploadedBy, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Receipt():
return $default(_that.id,_that.orgId,_that.transactionId,_that.filename,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.uploadedBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'transaction_id')  String? transactionId,  String filename, @JsonKey(name: 'storage_path')  String storagePath, @JsonKey(name: 'mime_type')  String mimeType, @JsonKey(name: 'size_bytes')  int sizeBytes, @JsonKey(name: 'uploaded_by')  String uploadedBy, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Receipt() when $default != null:
return $default(_that.id,_that.orgId,_that.transactionId,_that.filename,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.uploadedBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Receipt implements Receipt {
  const _Receipt({required this.id, @JsonKey(name: 'org_id') required this.orgId, @JsonKey(name: 'transaction_id') this.transactionId, required this.filename, @JsonKey(name: 'storage_path') required this.storagePath, @JsonKey(name: 'mime_type') required this.mimeType, @JsonKey(name: 'size_bytes') required this.sizeBytes, @JsonKey(name: 'uploaded_by') required this.uploadedBy, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);

@override final  String id;
@override@JsonKey(name: 'org_id') final  String orgId;
@override@JsonKey(name: 'transaction_id') final  String? transactionId;
@override final  String filename;
@override@JsonKey(name: 'storage_path') final  String storagePath;
@override@JsonKey(name: 'mime_type') final  String mimeType;
@override@JsonKey(name: 'size_bytes') final  int sizeBytes;
@override@JsonKey(name: 'uploaded_by') final  String uploadedBy;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptCopyWith<_Receipt> get copyWith => __$ReceiptCopyWithImpl<_Receipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Receipt&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,transactionId,filename,storagePath,mimeType,sizeBytes,uploadedBy,createdAt);

@override
String toString() {
  return 'Receipt(id: $id, orgId: $orgId, transactionId: $transactionId, filename: $filename, storagePath: $storagePath, mimeType: $mimeType, sizeBytes: $sizeBytes, uploadedBy: $uploadedBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReceiptCopyWith<$Res> implements $ReceiptCopyWith<$Res> {
  factory _$ReceiptCopyWith(_Receipt value, $Res Function(_Receipt) _then) = __$ReceiptCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'transaction_id') String? transactionId, String filename,@JsonKey(name: 'storage_path') String storagePath,@JsonKey(name: 'mime_type') String mimeType,@JsonKey(name: 'size_bytes') int sizeBytes,@JsonKey(name: 'uploaded_by') String uploadedBy,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$ReceiptCopyWithImpl<$Res>
    implements _$ReceiptCopyWith<$Res> {
  __$ReceiptCopyWithImpl(this._self, this._then);

  final _Receipt _self;
  final $Res Function(_Receipt) _then;

/// Create a copy of Receipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? transactionId = freezed,Object? filename = null,Object? storagePath = null,Object? mimeType = null,Object? sizeBytes = null,Object? uploadedBy = null,Object? createdAt = null,}) {
  return _then(_Receipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
