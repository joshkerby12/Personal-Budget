// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionFilter {

 int? get year; int? get month; String? get category; bool? get bizOnly;
/// Create a copy of TransactionFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionFilterCopyWith<TransactionFilter> get copyWith => _$TransactionFilterCopyWithImpl<TransactionFilter>(this as TransactionFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionFilter&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.category, category) || other.category == category)&&(identical(other.bizOnly, bizOnly) || other.bizOnly == bizOnly));
}


@override
int get hashCode => Object.hash(runtimeType,year,month,category,bizOnly);

@override
String toString() {
  return 'TransactionFilter(year: $year, month: $month, category: $category, bizOnly: $bizOnly)';
}


}

/// @nodoc
abstract mixin class $TransactionFilterCopyWith<$Res>  {
  factory $TransactionFilterCopyWith(TransactionFilter value, $Res Function(TransactionFilter) _then) = _$TransactionFilterCopyWithImpl;
@useResult
$Res call({
 int? year, int? month, String? category, bool? bizOnly
});




}
/// @nodoc
class _$TransactionFilterCopyWithImpl<$Res>
    implements $TransactionFilterCopyWith<$Res> {
  _$TransactionFilterCopyWithImpl(this._self, this._then);

  final TransactionFilter _self;
  final $Res Function(TransactionFilter) _then;

/// Create a copy of TransactionFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = freezed,Object? month = freezed,Object? category = freezed,Object? bizOnly = freezed,}) {
  return _then(_self.copyWith(
year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,bizOnly: freezed == bizOnly ? _self.bizOnly : bizOnly // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionFilter].
extension TransactionFilterPatterns on TransactionFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionFilter value)  $default,){
final _that = this;
switch (_that) {
case _TransactionFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionFilter value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? year,  int? month,  String? category,  bool? bizOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionFilter() when $default != null:
return $default(_that.year,_that.month,_that.category,_that.bizOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? year,  int? month,  String? category,  bool? bizOnly)  $default,) {final _that = this;
switch (_that) {
case _TransactionFilter():
return $default(_that.year,_that.month,_that.category,_that.bizOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? year,  int? month,  String? category,  bool? bizOnly)?  $default,) {final _that = this;
switch (_that) {
case _TransactionFilter() when $default != null:
return $default(_that.year,_that.month,_that.category,_that.bizOnly);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionFilter implements TransactionFilter {
  const _TransactionFilter({this.year, this.month, this.category, this.bizOnly});
  

@override final  int? year;
@override final  int? month;
@override final  String? category;
@override final  bool? bizOnly;

/// Create a copy of TransactionFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionFilterCopyWith<_TransactionFilter> get copyWith => __$TransactionFilterCopyWithImpl<_TransactionFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionFilter&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.category, category) || other.category == category)&&(identical(other.bizOnly, bizOnly) || other.bizOnly == bizOnly));
}


@override
int get hashCode => Object.hash(runtimeType,year,month,category,bizOnly);

@override
String toString() {
  return 'TransactionFilter(year: $year, month: $month, category: $category, bizOnly: $bizOnly)';
}


}

/// @nodoc
abstract mixin class _$TransactionFilterCopyWith<$Res> implements $TransactionFilterCopyWith<$Res> {
  factory _$TransactionFilterCopyWith(_TransactionFilter value, $Res Function(_TransactionFilter) _then) = __$TransactionFilterCopyWithImpl;
@override @useResult
$Res call({
 int? year, int? month, String? category, bool? bizOnly
});




}
/// @nodoc
class __$TransactionFilterCopyWithImpl<$Res>
    implements _$TransactionFilterCopyWith<$Res> {
  __$TransactionFilterCopyWithImpl(this._self, this._then);

  final _TransactionFilter _self;
  final $Res Function(_TransactionFilter) _then;

/// Create a copy of TransactionFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = freezed,Object? month = freezed,Object? category = freezed,Object? bizOnly = freezed,}) {
  return _then(_TransactionFilter(
year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,month: freezed == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,bizOnly: freezed == bizOnly ? _self.bizOnly : bizOnly // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
