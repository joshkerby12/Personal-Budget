// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReceiptFilter {

 DateTime? get startDate; DateTime? get endDate; String? get searchText; bool? get linkedOnly; bool? get unlinkedOnly;
/// Create a copy of ReceiptFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptFilterCopyWith<ReceiptFilter> get copyWith => _$ReceiptFilterCopyWithImpl<ReceiptFilter>(this as ReceiptFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.linkedOnly, linkedOnly) || other.linkedOnly == linkedOnly)&&(identical(other.unlinkedOnly, unlinkedOnly) || other.unlinkedOnly == unlinkedOnly));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,searchText,linkedOnly,unlinkedOnly);

@override
String toString() {
  return 'ReceiptFilter(startDate: $startDate, endDate: $endDate, searchText: $searchText, linkedOnly: $linkedOnly, unlinkedOnly: $unlinkedOnly)';
}


}

/// @nodoc
abstract mixin class $ReceiptFilterCopyWith<$Res>  {
  factory $ReceiptFilterCopyWith(ReceiptFilter value, $Res Function(ReceiptFilter) _then) = _$ReceiptFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, String? searchText, bool? linkedOnly, bool? unlinkedOnly
});




}
/// @nodoc
class _$ReceiptFilterCopyWithImpl<$Res>
    implements $ReceiptFilterCopyWith<$Res> {
  _$ReceiptFilterCopyWithImpl(this._self, this._then);

  final ReceiptFilter _self;
  final $Res Function(ReceiptFilter) _then;

/// Create a copy of ReceiptFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? searchText = freezed,Object? linkedOnly = freezed,Object? unlinkedOnly = freezed,}) {
  return _then(_self.copyWith(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,searchText: freezed == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String?,linkedOnly: freezed == linkedOnly ? _self.linkedOnly : linkedOnly // ignore: cast_nullable_to_non_nullable
as bool?,unlinkedOnly: freezed == unlinkedOnly ? _self.unlinkedOnly : unlinkedOnly // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiptFilter].
extension ReceiptFilterPatterns on ReceiptFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiptFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiptFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiptFilter value)  $default,){
final _that = this;
switch (_that) {
case _ReceiptFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiptFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiptFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  String? searchText,  bool? linkedOnly,  bool? unlinkedOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiptFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.searchText,_that.linkedOnly,_that.unlinkedOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  String? searchText,  bool? linkedOnly,  bool? unlinkedOnly)  $default,) {final _that = this;
switch (_that) {
case _ReceiptFilter():
return $default(_that.startDate,_that.endDate,_that.searchText,_that.linkedOnly,_that.unlinkedOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? startDate,  DateTime? endDate,  String? searchText,  bool? linkedOnly,  bool? unlinkedOnly)?  $default,) {final _that = this;
switch (_that) {
case _ReceiptFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.searchText,_that.linkedOnly,_that.unlinkedOnly);case _:
  return null;

}
}

}

/// @nodoc


class _ReceiptFilter implements ReceiptFilter {
  const _ReceiptFilter({this.startDate, this.endDate, this.searchText, this.linkedOnly, this.unlinkedOnly});
  

@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override final  String? searchText;
@override final  bool? linkedOnly;
@override final  bool? unlinkedOnly;

/// Create a copy of ReceiptFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptFilterCopyWith<_ReceiptFilter> get copyWith => __$ReceiptFilterCopyWithImpl<_ReceiptFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiptFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.linkedOnly, linkedOnly) || other.linkedOnly == linkedOnly)&&(identical(other.unlinkedOnly, unlinkedOnly) || other.unlinkedOnly == unlinkedOnly));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,searchText,linkedOnly,unlinkedOnly);

@override
String toString() {
  return 'ReceiptFilter(startDate: $startDate, endDate: $endDate, searchText: $searchText, linkedOnly: $linkedOnly, unlinkedOnly: $unlinkedOnly)';
}


}

/// @nodoc
abstract mixin class _$ReceiptFilterCopyWith<$Res> implements $ReceiptFilterCopyWith<$Res> {
  factory _$ReceiptFilterCopyWith(_ReceiptFilter value, $Res Function(_ReceiptFilter) _then) = __$ReceiptFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? startDate, DateTime? endDate, String? searchText, bool? linkedOnly, bool? unlinkedOnly
});




}
/// @nodoc
class __$ReceiptFilterCopyWithImpl<$Res>
    implements _$ReceiptFilterCopyWith<$Res> {
  __$ReceiptFilterCopyWithImpl(this._self, this._then);

  final _ReceiptFilter _self;
  final $Res Function(_ReceiptFilter) _then;

/// Create a copy of ReceiptFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? searchText = freezed,Object? linkedOnly = freezed,Object? unlinkedOnly = freezed,}) {
  return _then(_ReceiptFilter(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,searchText: freezed == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String?,linkedOnly: freezed == linkedOnly ? _self.linkedOnly : linkedOnly // ignore: cast_nullable_to_non_nullable
as bool?,unlinkedOnly: freezed == unlinkedOnly ? _self.unlinkedOnly : unlinkedOnly // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
