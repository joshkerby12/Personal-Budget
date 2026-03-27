// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Transaction {

 String get id;@JsonKey(name: 'org_id') String get orgId;@JsonKey(name: 'created_by') String get createdBy; DateTime get date; double get amount; String get merchant; String? get description; String get category; String get subcategory;@JsonKey(name: 'biz_pct') double get bizPct;@JsonKey(name: 'is_split') bool get isSplit;@JsonKey(name: 'receipt_id') String? get receiptId; String? get notes;@JsonKey(name: 'no_miles') bool get noMiles;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.date, date) || other.date == date)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.bizPct, bizPct) || other.bizPct == bizPct)&&(identical(other.isSplit, isSplit) || other.isSplit == isSplit)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.noMiles, noMiles) || other.noMiles == noMiles)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,createdBy,date,amount,merchant,description,category,subcategory,bizPct,isSplit,receiptId,notes,noMiles,createdAt);

@override
String toString() {
  return 'Transaction(id: $id, orgId: $orgId, createdBy: $createdBy, date: $date, amount: $amount, merchant: $merchant, description: $description, category: $category, subcategory: $subcategory, bizPct: $bizPct, isSplit: $isSplit, receiptId: $receiptId, notes: $notes, noMiles: $noMiles, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'created_by') String createdBy, DateTime date, double amount, String merchant, String? description, String category, String subcategory,@JsonKey(name: 'biz_pct') double bizPct,@JsonKey(name: 'is_split') bool isSplit,@JsonKey(name: 'receipt_id') String? receiptId, String? notes,@JsonKey(name: 'no_miles') bool noMiles,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orgId = null,Object? createdBy = null,Object? date = null,Object? amount = null,Object? merchant = null,Object? description = freezed,Object? category = null,Object? subcategory = null,Object? bizPct = null,Object? isSplit = null,Object? receiptId = freezed,Object? notes = freezed,Object? noMiles = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,merchant: null == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: null == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String,bizPct: null == bizPct ? _self.bizPct : bizPct // ignore: cast_nullable_to_non_nullable
as double,isSplit: null == isSplit ? _self.isSplit : isSplit // ignore: cast_nullable_to_non_nullable
as bool,receiptId: freezed == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,noMiles: null == noMiles ? _self.noMiles : noMiles // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'created_by')  String createdBy,  DateTime date,  double amount,  String merchant,  String? description,  String category,  String subcategory, @JsonKey(name: 'biz_pct')  double bizPct, @JsonKey(name: 'is_split')  bool isSplit, @JsonKey(name: 'receipt_id')  String? receiptId,  String? notes, @JsonKey(name: 'no_miles')  bool noMiles, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.orgId,_that.createdBy,_that.date,_that.amount,_that.merchant,_that.description,_that.category,_that.subcategory,_that.bizPct,_that.isSplit,_that.receiptId,_that.notes,_that.noMiles,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'created_by')  String createdBy,  DateTime date,  double amount,  String merchant,  String? description,  String category,  String subcategory, @JsonKey(name: 'biz_pct')  double bizPct, @JsonKey(name: 'is_split')  bool isSplit, @JsonKey(name: 'receipt_id')  String? receiptId,  String? notes, @JsonKey(name: 'no_miles')  bool noMiles, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.orgId,_that.createdBy,_that.date,_that.amount,_that.merchant,_that.description,_that.category,_that.subcategory,_that.bizPct,_that.isSplit,_that.receiptId,_that.notes,_that.noMiles,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'org_id')  String orgId, @JsonKey(name: 'created_by')  String createdBy,  DateTime date,  double amount,  String merchant,  String? description,  String category,  String subcategory, @JsonKey(name: 'biz_pct')  double bizPct, @JsonKey(name: 'is_split')  bool isSplit, @JsonKey(name: 'receipt_id')  String? receiptId,  String? notes, @JsonKey(name: 'no_miles')  bool noMiles, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.orgId,_that.createdBy,_that.date,_that.amount,_that.merchant,_that.description,_that.category,_that.subcategory,_that.bizPct,_that.isSplit,_that.receiptId,_that.notes,_that.noMiles,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transaction implements Transaction {
  const _Transaction({required this.id, @JsonKey(name: 'org_id') required this.orgId, @JsonKey(name: 'created_by') required this.createdBy, required this.date, required this.amount, required this.merchant, this.description, required this.category, required this.subcategory, @JsonKey(name: 'biz_pct') required this.bizPct, @JsonKey(name: 'is_split') required this.isSplit, @JsonKey(name: 'receipt_id') this.receiptId, this.notes, @JsonKey(name: 'no_miles') this.noMiles = false, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'org_id') final  String orgId;
@override@JsonKey(name: 'created_by') final  String createdBy;
@override final  DateTime date;
@override final  double amount;
@override final  String merchant;
@override final  String? description;
@override final  String category;
@override final  String subcategory;
@override@JsonKey(name: 'biz_pct') final  double bizPct;
@override@JsonKey(name: 'is_split') final  bool isSplit;
@override@JsonKey(name: 'receipt_id') final  String? receiptId;
@override final  String? notes;
@override@JsonKey(name: 'no_miles') final  bool noMiles;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.date, date) || other.date == date)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.bizPct, bizPct) || other.bizPct == bizPct)&&(identical(other.isSplit, isSplit) || other.isSplit == isSplit)&&(identical(other.receiptId, receiptId) || other.receiptId == receiptId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.noMiles, noMiles) || other.noMiles == noMiles)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orgId,createdBy,date,amount,merchant,description,category,subcategory,bizPct,isSplit,receiptId,notes,noMiles,createdAt);

@override
String toString() {
  return 'Transaction(id: $id, orgId: $orgId, createdBy: $createdBy, date: $date, amount: $amount, merchant: $merchant, description: $description, category: $category, subcategory: $subcategory, bizPct: $bizPct, isSplit: $isSplit, receiptId: $receiptId, notes: $notes, noMiles: $noMiles, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'org_id') String orgId,@JsonKey(name: 'created_by') String createdBy, DateTime date, double amount, String merchant, String? description, String category, String subcategory,@JsonKey(name: 'biz_pct') double bizPct,@JsonKey(name: 'is_split') bool isSplit,@JsonKey(name: 'receipt_id') String? receiptId, String? notes,@JsonKey(name: 'no_miles') bool noMiles,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orgId = null,Object? createdBy = null,Object? date = null,Object? amount = null,Object? merchant = null,Object? description = freezed,Object? category = null,Object? subcategory = null,Object? bizPct = null,Object? isSplit = null,Object? receiptId = freezed,Object? notes = freezed,Object? noMiles = null,Object? createdAt = null,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,merchant: null == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: null == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String,bizPct: null == bizPct ? _self.bizPct : bizPct // ignore: cast_nullable_to_non_nullable
as double,isSplit: null == isSplit ? _self.isSplit : isSplit // ignore: cast_nullable_to_non_nullable
as bool,receiptId: freezed == receiptId ? _self.receiptId : receiptId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,noMiles: null == noMiles ? _self.noMiles : noMiles // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
