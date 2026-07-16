// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_position.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetPosition {

 int get id; Company get company; String get department; String? get periodType; String get periodStart; String get periodEnd; int get amount; int get fundedToDate; int get remaining;
/// Create a copy of BudgetPosition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetPositionCopyWith<BudgetPosition> get copyWith => _$BudgetPositionCopyWithImpl<BudgetPosition>(this as BudgetPosition, _$identity);

  /// Serializes this BudgetPosition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetPosition&&(identical(other.id, id) || other.id == id)&&(identical(other.company, company) || other.company == company)&&(identical(other.department, department) || other.department == department)&&(identical(other.periodType, periodType) || other.periodType == periodType)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.fundedToDate, fundedToDate) || other.fundedToDate == fundedToDate)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,company,department,periodType,periodStart,periodEnd,amount,fundedToDate,remaining);

@override
String toString() {
  return 'BudgetPosition(id: $id, company: $company, department: $department, periodType: $periodType, periodStart: $periodStart, periodEnd: $periodEnd, amount: $amount, fundedToDate: $fundedToDate, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class $BudgetPositionCopyWith<$Res>  {
  factory $BudgetPositionCopyWith(BudgetPosition value, $Res Function(BudgetPosition) _then) = _$BudgetPositionCopyWithImpl;
@useResult
$Res call({
 int id, Company company, String department, String? periodType, String periodStart, String periodEnd, int amount, int fundedToDate, int remaining
});


$CompanyCopyWith<$Res> get company;

}
/// @nodoc
class _$BudgetPositionCopyWithImpl<$Res>
    implements $BudgetPositionCopyWith<$Res> {
  _$BudgetPositionCopyWithImpl(this._self, this._then);

  final BudgetPosition _self;
  final $Res Function(BudgetPosition) _then;

/// Create a copy of BudgetPosition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? company = null,Object? department = null,Object? periodType = freezed,Object? periodStart = null,Object? periodEnd = null,Object? amount = null,Object? fundedToDate = null,Object? remaining = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company,department: null == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String,periodType: freezed == periodType ? _self.periodType : periodType // ignore: cast_nullable_to_non_nullable
as String?,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as String,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,fundedToDate: null == fundedToDate ? _self.fundedToDate : fundedToDate // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of BudgetPosition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res> get company {
  
  return $CompanyCopyWith<$Res>(_self.company, (value) {
    return _then(_self.copyWith(company: value));
  });
}
}


/// Adds pattern-matching-related methods to [BudgetPosition].
extension BudgetPositionPatterns on BudgetPosition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetPosition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetPosition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetPosition value)  $default,){
final _that = this;
switch (_that) {
case _BudgetPosition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetPosition value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetPosition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  Company company,  String department,  String? periodType,  String periodStart,  String periodEnd,  int amount,  int fundedToDate,  int remaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetPosition() when $default != null:
return $default(_that.id,_that.company,_that.department,_that.periodType,_that.periodStart,_that.periodEnd,_that.amount,_that.fundedToDate,_that.remaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  Company company,  String department,  String? periodType,  String periodStart,  String periodEnd,  int amount,  int fundedToDate,  int remaining)  $default,) {final _that = this;
switch (_that) {
case _BudgetPosition():
return $default(_that.id,_that.company,_that.department,_that.periodType,_that.periodStart,_that.periodEnd,_that.amount,_that.fundedToDate,_that.remaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  Company company,  String department,  String? periodType,  String periodStart,  String periodEnd,  int amount,  int fundedToDate,  int remaining)?  $default,) {final _that = this;
switch (_that) {
case _BudgetPosition() when $default != null:
return $default(_that.id,_that.company,_that.department,_that.periodType,_that.periodStart,_that.periodEnd,_that.amount,_that.fundedToDate,_that.remaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetPosition implements BudgetPosition {
  const _BudgetPosition({required this.id, required this.company, required this.department, this.periodType, required this.periodStart, required this.periodEnd, required this.amount, required this.fundedToDate, required this.remaining});
  factory _BudgetPosition.fromJson(Map<String, dynamic> json) => _$BudgetPositionFromJson(json);

@override final  int id;
@override final  Company company;
@override final  String department;
@override final  String? periodType;
@override final  String periodStart;
@override final  String periodEnd;
@override final  int amount;
@override final  int fundedToDate;
@override final  int remaining;

/// Create a copy of BudgetPosition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetPositionCopyWith<_BudgetPosition> get copyWith => __$BudgetPositionCopyWithImpl<_BudgetPosition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetPositionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetPosition&&(identical(other.id, id) || other.id == id)&&(identical(other.company, company) || other.company == company)&&(identical(other.department, department) || other.department == department)&&(identical(other.periodType, periodType) || other.periodType == periodType)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.fundedToDate, fundedToDate) || other.fundedToDate == fundedToDate)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,company,department,periodType,periodStart,periodEnd,amount,fundedToDate,remaining);

@override
String toString() {
  return 'BudgetPosition(id: $id, company: $company, department: $department, periodType: $periodType, periodStart: $periodStart, periodEnd: $periodEnd, amount: $amount, fundedToDate: $fundedToDate, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class _$BudgetPositionCopyWith<$Res> implements $BudgetPositionCopyWith<$Res> {
  factory _$BudgetPositionCopyWith(_BudgetPosition value, $Res Function(_BudgetPosition) _then) = __$BudgetPositionCopyWithImpl;
@override @useResult
$Res call({
 int id, Company company, String department, String? periodType, String periodStart, String periodEnd, int amount, int fundedToDate, int remaining
});


@override $CompanyCopyWith<$Res> get company;

}
/// @nodoc
class __$BudgetPositionCopyWithImpl<$Res>
    implements _$BudgetPositionCopyWith<$Res> {
  __$BudgetPositionCopyWithImpl(this._self, this._then);

  final _BudgetPosition _self;
  final $Res Function(_BudgetPosition) _then;

/// Create a copy of BudgetPosition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? company = null,Object? department = null,Object? periodType = freezed,Object? periodStart = null,Object? periodEnd = null,Object? amount = null,Object? fundedToDate = null,Object? remaining = null,}) {
  return _then(_BudgetPosition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,company: null == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company,department: null == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String,periodType: freezed == periodType ? _self.periodType : periodType // ignore: cast_nullable_to_non_nullable
as String?,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as String,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,fundedToDate: null == fundedToDate ? _self.fundedToDate : fundedToDate // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of BudgetPosition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res> get company {
  
  return $CompanyCopyWith<$Res>(_self.company, (value) {
    return _then(_self.copyWith(company: value));
  });
}
}

// dart format on
