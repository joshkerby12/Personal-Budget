// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_split.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionSplit {

 String get id;@JsonKey(name: 'transaction_id') String get transactionId;@JsonKey(name: 'org_id') String get orgId; String get category; String get subcategory; double get amount;@JsonKey(name: 'biz_pct') double get bizPct;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of TransactionSplit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionSplitCopyWith<TransactionSplit> get copyWith => _$TransactionSplitCopyWithImpl<TransactionSplit>(this as TransactionSplit, _$identity);

  /// Serializes this TransactionSplit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionSplit&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.bizPct, bizPct) || other.bizPct == bizPct)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionId,orgId,category,subcategory,amount,bizPct,createdAt);

@override
String toString() {
  return 'TransactionSplit(id: $id, transactionId: $transactionId, orgId: $orgId, category: $category, subcategory: $subcategory, amount: $amount, bizPct: $bizPct, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TransactionSplitCopyWith<$Res>  {
  factory $TransactionSplitCopyWith(TransactionSplit value, $Res Function(TransactionSplit) _then) = _$TransactionSplitCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'transaction_id') String transactionId,@JsonKey(name: 'org_id') String orgId, String category, String subcategory, double amount,@JsonKey(name: 'biz_pct') double bizPct,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$TransactionSplitCopyWithImpl<$Res>
    implements $TransactionSplitCopyWith<$Res> {
  _$TransactionSplitCopyWithImpl(this._self, this._then);

  final TransactionSplit _self;
  final $Res Function(TransactionSplit) _then;

/// Create a copy of TransactionSplit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? transactionId = null,Object? orgId = null,Object? category = null,Object? subcategory = null,Object? amount = null,Object? bizPct = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: null == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,bizPct: null == bizPct ? _self.bizPct : bizPct // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionSplit].
extension TransactionSplitPatterns on TransactionSplit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionSplit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionSplit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionSplit value)  $default,){
final _that = this;
switch (_that) {
case _TransactionSplit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionSplit value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionSplit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'transaction_id')  String transactionId, @JsonKey(name: 'org_id')  String orgId,  String category,  String subcategory,  double amount, @JsonKey(name: 'biz_pct')  double bizPct, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionSplit() when $default != null:
return $default(_that.id,_that.transactionId,_that.orgId,_that.category,_that.subcategory,_that.amount,_that.bizPct,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'transaction_id')  String transactionId, @JsonKey(name: 'org_id')  String orgId,  String category,  String subcategory,  double amount, @JsonKey(name: 'biz_pct')  double bizPct, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TransactionSplit():
return $default(_that.id,_that.transactionId,_that.orgId,_that.category,_that.subcategory,_that.amount,_that.bizPct,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'transaction_id')  String transactionId, @JsonKey(name: 'org_id')  String orgId,  String category,  String subcategory,  double amount, @JsonKey(name: 'biz_pct')  double bizPct, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TransactionSplit() when $default != null:
return $default(_that.id,_that.transactionId,_that.orgId,_that.category,_that.subcategory,_that.amount,_that.bizPct,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionSplit implements TransactionSplit {
  const _TransactionSplit({required this.id, @JsonKey(name: 'transaction_id') required this.transactionId, @JsonKey(name: 'org_id') required this.orgId, required this.category, required this.subcategory, required this.amount, @JsonKey(name: 'biz_pct') this.bizPct = 0.0, @JsonKey(name: 'created_at') required this.createdAt});
  factory _TransactionSplit.fromJson(Map<String, dynamic> json) => _$TransactionSplitFromJson(json);

@override final  String id;
@override@JsonKey(name: 'transaction_id') final  String transactionId;
@override@JsonKey(name: 'org_id') final  String orgId;
@override final  String category;
@override final  String subcategory;
@override final  double amount;
@override@JsonKey(name: 'biz_pct') final  double bizPct;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of TransactionSplit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionSplitCopyWith<_TransactionSplit> get copyWith => __$TransactionSplitCopyWithImpl<_TransactionSplit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionSplitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionSplit&&(identical(other.id, id) || other.id == id)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.orgId, orgId) || other.orgId == orgId)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.bizPct, bizPct) || other.bizPct == bizPct)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,transactionId,orgId,category,subcategory,amount,bizPct,createdAt);

@override
String toString() {
  return 'TransactionSplit(id: $id, transactionId: $transactionId, orgId: $orgId, category: $category, subcategory: $subcategory, amount: $amount, bizPct: $bizPct, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionSplitCopyWith<$Res> implements $TransactionSplitCopyWith<$Res> {
  factory _$TransactionSplitCopyWith(_TransactionSplit value, $Res Function(_TransactionSplit) _then) = __$TransactionSplitCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'transaction_id') String transactionId,@JsonKey(name: 'org_id') String orgId, String category, String subcategory, double amount,@JsonKey(name: 'biz_pct') double bizPct,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$TransactionSplitCopyWithImpl<$Res>
    implements _$TransactionSplitCopyWith<$Res> {
  __$TransactionSplitCopyWithImpl(this._self, this._then);

  final _TransactionSplit _self;
  final $Res Function(_TransactionSplit) _then;

/// Create a copy of TransactionSplit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? transactionId = null,Object? orgId = null,Object? category = null,Object? subcategory = null,Object? amount = null,Object? bizPct = null,Object? createdAt = null,}) {
  return _then(_TransactionSplit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,orgId: null == orgId ? _self.orgId : orgId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: null == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,bizPct: null == bizPct ? _self.bizPct : bizPct // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
