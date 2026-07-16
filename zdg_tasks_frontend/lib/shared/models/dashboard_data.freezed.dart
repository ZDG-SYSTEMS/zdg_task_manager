// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardCounts {

 int get total; int get pending; int get inProgress; int get assigned; int get overdue;
/// Create a copy of DashboardCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardCountsCopyWith<DashboardCounts> get copyWith => _$DashboardCountsCopyWithImpl<DashboardCounts>(this as DashboardCounts, _$identity);

  /// Serializes this DashboardCounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardCounts&&(identical(other.total, total) || other.total == total)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.assigned, assigned) || other.assigned == assigned)&&(identical(other.overdue, overdue) || other.overdue == overdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,pending,inProgress,assigned,overdue);

@override
String toString() {
  return 'DashboardCounts(total: $total, pending: $pending, inProgress: $inProgress, assigned: $assigned, overdue: $overdue)';
}


}

/// @nodoc
abstract mixin class $DashboardCountsCopyWith<$Res>  {
  factory $DashboardCountsCopyWith(DashboardCounts value, $Res Function(DashboardCounts) _then) = _$DashboardCountsCopyWithImpl;
@useResult
$Res call({
 int total, int pending, int inProgress, int assigned, int overdue
});




}
/// @nodoc
class _$DashboardCountsCopyWithImpl<$Res>
    implements $DashboardCountsCopyWith<$Res> {
  _$DashboardCountsCopyWithImpl(this._self, this._then);

  final DashboardCounts _self;
  final $Res Function(DashboardCounts) _then;

/// Create a copy of DashboardCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? pending = null,Object? inProgress = null,Object? assigned = null,Object? overdue = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,assigned: null == assigned ? _self.assigned : assigned // ignore: cast_nullable_to_non_nullable
as int,overdue: null == overdue ? _self.overdue : overdue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardCounts].
extension DashboardCountsPatterns on DashboardCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardCounts value)  $default,){
final _that = this;
switch (_that) {
case _DashboardCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardCounts value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int pending,  int inProgress,  int assigned,  int overdue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardCounts() when $default != null:
return $default(_that.total,_that.pending,_that.inProgress,_that.assigned,_that.overdue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int pending,  int inProgress,  int assigned,  int overdue)  $default,) {final _that = this;
switch (_that) {
case _DashboardCounts():
return $default(_that.total,_that.pending,_that.inProgress,_that.assigned,_that.overdue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int pending,  int inProgress,  int assigned,  int overdue)?  $default,) {final _that = this;
switch (_that) {
case _DashboardCounts() when $default != null:
return $default(_that.total,_that.pending,_that.inProgress,_that.assigned,_that.overdue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardCounts implements DashboardCounts {
  const _DashboardCounts({this.total = 0, this.pending = 0, this.inProgress = 0, this.assigned = 0, this.overdue = 0});
  factory _DashboardCounts.fromJson(Map<String, dynamic> json) => _$DashboardCountsFromJson(json);

@override@JsonKey() final  int total;
@override@JsonKey() final  int pending;
@override@JsonKey() final  int inProgress;
@override@JsonKey() final  int assigned;
@override@JsonKey() final  int overdue;

/// Create a copy of DashboardCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardCountsCopyWith<_DashboardCounts> get copyWith => __$DashboardCountsCopyWithImpl<_DashboardCounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardCountsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardCounts&&(identical(other.total, total) || other.total == total)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.assigned, assigned) || other.assigned == assigned)&&(identical(other.overdue, overdue) || other.overdue == overdue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,pending,inProgress,assigned,overdue);

@override
String toString() {
  return 'DashboardCounts(total: $total, pending: $pending, inProgress: $inProgress, assigned: $assigned, overdue: $overdue)';
}


}

/// @nodoc
abstract mixin class _$DashboardCountsCopyWith<$Res> implements $DashboardCountsCopyWith<$Res> {
  factory _$DashboardCountsCopyWith(_DashboardCounts value, $Res Function(_DashboardCounts) _then) = __$DashboardCountsCopyWithImpl;
@override @useResult
$Res call({
 int total, int pending, int inProgress, int assigned, int overdue
});




}
/// @nodoc
class __$DashboardCountsCopyWithImpl<$Res>
    implements _$DashboardCountsCopyWith<$Res> {
  __$DashboardCountsCopyWithImpl(this._self, this._then);

  final _DashboardCounts _self;
  final $Res Function(_DashboardCounts) _then;

/// Create a copy of DashboardCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? pending = null,Object? inProgress = null,Object? assigned = null,Object? overdue = null,}) {
  return _then(_DashboardCounts(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,assigned: null == assigned ? _self.assigned : assigned // ignore: cast_nullable_to_non_nullable
as int,overdue: null == overdue ? _self.overdue : overdue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MonthlyPoint {

 String get month; int? get requests; int? get requestedTotal; int? get fundedCount; int? get fundedTotal;
/// Create a copy of MonthlyPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyPointCopyWith<MonthlyPoint> get copyWith => _$MonthlyPointCopyWithImpl<MonthlyPoint>(this as MonthlyPoint, _$identity);

  /// Serializes this MonthlyPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyPoint&&(identical(other.month, month) || other.month == month)&&(identical(other.requests, requests) || other.requests == requests)&&(identical(other.requestedTotal, requestedTotal) || other.requestedTotal == requestedTotal)&&(identical(other.fundedCount, fundedCount) || other.fundedCount == fundedCount)&&(identical(other.fundedTotal, fundedTotal) || other.fundedTotal == fundedTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,requests,requestedTotal,fundedCount,fundedTotal);

@override
String toString() {
  return 'MonthlyPoint(month: $month, requests: $requests, requestedTotal: $requestedTotal, fundedCount: $fundedCount, fundedTotal: $fundedTotal)';
}


}

/// @nodoc
abstract mixin class $MonthlyPointCopyWith<$Res>  {
  factory $MonthlyPointCopyWith(MonthlyPoint value, $Res Function(MonthlyPoint) _then) = _$MonthlyPointCopyWithImpl;
@useResult
$Res call({
 String month, int? requests, int? requestedTotal, int? fundedCount, int? fundedTotal
});




}
/// @nodoc
class _$MonthlyPointCopyWithImpl<$Res>
    implements $MonthlyPointCopyWith<$Res> {
  _$MonthlyPointCopyWithImpl(this._self, this._then);

  final MonthlyPoint _self;
  final $Res Function(MonthlyPoint) _then;

/// Create a copy of MonthlyPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? requests = freezed,Object? requestedTotal = freezed,Object? fundedCount = freezed,Object? fundedTotal = freezed,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,requests: freezed == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as int?,requestedTotal: freezed == requestedTotal ? _self.requestedTotal : requestedTotal // ignore: cast_nullable_to_non_nullable
as int?,fundedCount: freezed == fundedCount ? _self.fundedCount : fundedCount // ignore: cast_nullable_to_non_nullable
as int?,fundedTotal: freezed == fundedTotal ? _self.fundedTotal : fundedTotal // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyPoint].
extension MonthlyPointPatterns on MonthlyPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyPoint value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyPoint value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String month,  int? requests,  int? requestedTotal,  int? fundedCount,  int? fundedTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyPoint() when $default != null:
return $default(_that.month,_that.requests,_that.requestedTotal,_that.fundedCount,_that.fundedTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String month,  int? requests,  int? requestedTotal,  int? fundedCount,  int? fundedTotal)  $default,) {final _that = this;
switch (_that) {
case _MonthlyPoint():
return $default(_that.month,_that.requests,_that.requestedTotal,_that.fundedCount,_that.fundedTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String month,  int? requests,  int? requestedTotal,  int? fundedCount,  int? fundedTotal)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyPoint() when $default != null:
return $default(_that.month,_that.requests,_that.requestedTotal,_that.fundedCount,_that.fundedTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyPoint implements MonthlyPoint {
  const _MonthlyPoint({required this.month, this.requests, this.requestedTotal, this.fundedCount, this.fundedTotal});
  factory _MonthlyPoint.fromJson(Map<String, dynamic> json) => _$MonthlyPointFromJson(json);

@override final  String month;
@override final  int? requests;
@override final  int? requestedTotal;
@override final  int? fundedCount;
@override final  int? fundedTotal;

/// Create a copy of MonthlyPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyPointCopyWith<_MonthlyPoint> get copyWith => __$MonthlyPointCopyWithImpl<_MonthlyPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyPoint&&(identical(other.month, month) || other.month == month)&&(identical(other.requests, requests) || other.requests == requests)&&(identical(other.requestedTotal, requestedTotal) || other.requestedTotal == requestedTotal)&&(identical(other.fundedCount, fundedCount) || other.fundedCount == fundedCount)&&(identical(other.fundedTotal, fundedTotal) || other.fundedTotal == fundedTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,requests,requestedTotal,fundedCount,fundedTotal);

@override
String toString() {
  return 'MonthlyPoint(month: $month, requests: $requests, requestedTotal: $requestedTotal, fundedCount: $fundedCount, fundedTotal: $fundedTotal)';
}


}

/// @nodoc
abstract mixin class _$MonthlyPointCopyWith<$Res> implements $MonthlyPointCopyWith<$Res> {
  factory _$MonthlyPointCopyWith(_MonthlyPoint value, $Res Function(_MonthlyPoint) _then) = __$MonthlyPointCopyWithImpl;
@override @useResult
$Res call({
 String month, int? requests, int? requestedTotal, int? fundedCount, int? fundedTotal
});




}
/// @nodoc
class __$MonthlyPointCopyWithImpl<$Res>
    implements _$MonthlyPointCopyWith<$Res> {
  __$MonthlyPointCopyWithImpl(this._self, this._then);

  final _MonthlyPoint _self;
  final $Res Function(_MonthlyPoint) _then;

/// Create a copy of MonthlyPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? requests = freezed,Object? requestedTotal = freezed,Object? fundedCount = freezed,Object? fundedTotal = freezed,}) {
  return _then(_MonthlyPoint(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,requests: freezed == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as int?,requestedTotal: freezed == requestedTotal ? _self.requestedTotal : requestedTotal // ignore: cast_nullable_to_non_nullable
as int?,fundedCount: freezed == fundedCount ? _self.fundedCount : fundedCount // ignore: cast_nullable_to_non_nullable
as int?,fundedTotal: freezed == fundedTotal ? _self.fundedTotal : fundedTotal // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$DashboardData {

 DashboardCounts get counts;@JsonKey(fromJson: _statusMap) Map<String, int> get byStatus; List<MonthlyPoint> get monthlyRequests; List<MonthlyPoint> get monthlyFunded; List<BudgetPosition> get budgets;
/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardDataCopyWith<DashboardData> get copyWith => _$DashboardDataCopyWithImpl<DashboardData>(this as DashboardData, _$identity);

  /// Serializes this DashboardData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardData&&(identical(other.counts, counts) || other.counts == counts)&&const DeepCollectionEquality().equals(other.byStatus, byStatus)&&const DeepCollectionEquality().equals(other.monthlyRequests, monthlyRequests)&&const DeepCollectionEquality().equals(other.monthlyFunded, monthlyFunded)&&const DeepCollectionEquality().equals(other.budgets, budgets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,counts,const DeepCollectionEquality().hash(byStatus),const DeepCollectionEquality().hash(monthlyRequests),const DeepCollectionEquality().hash(monthlyFunded),const DeepCollectionEquality().hash(budgets));

@override
String toString() {
  return 'DashboardData(counts: $counts, byStatus: $byStatus, monthlyRequests: $monthlyRequests, monthlyFunded: $monthlyFunded, budgets: $budgets)';
}


}

/// @nodoc
abstract mixin class $DashboardDataCopyWith<$Res>  {
  factory $DashboardDataCopyWith(DashboardData value, $Res Function(DashboardData) _then) = _$DashboardDataCopyWithImpl;
@useResult
$Res call({
 DashboardCounts counts,@JsonKey(fromJson: _statusMap) Map<String, int> byStatus, List<MonthlyPoint> monthlyRequests, List<MonthlyPoint> monthlyFunded, List<BudgetPosition> budgets
});


$DashboardCountsCopyWith<$Res> get counts;

}
/// @nodoc
class _$DashboardDataCopyWithImpl<$Res>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._self, this._then);

  final DashboardData _self;
  final $Res Function(DashboardData) _then;

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? counts = null,Object? byStatus = null,Object? monthlyRequests = null,Object? monthlyFunded = null,Object? budgets = null,}) {
  return _then(_self.copyWith(
counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as DashboardCounts,byStatus: null == byStatus ? _self.byStatus : byStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>,monthlyRequests: null == monthlyRequests ? _self.monthlyRequests : monthlyRequests // ignore: cast_nullable_to_non_nullable
as List<MonthlyPoint>,monthlyFunded: null == monthlyFunded ? _self.monthlyFunded : monthlyFunded // ignore: cast_nullable_to_non_nullable
as List<MonthlyPoint>,budgets: null == budgets ? _self.budgets : budgets // ignore: cast_nullable_to_non_nullable
as List<BudgetPosition>,
  ));
}
/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardCountsCopyWith<$Res> get counts {
  
  return $DashboardCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardData].
extension DashboardDataPatterns on DashboardData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardData value)  $default,){
final _that = this;
switch (_that) {
case _DashboardData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardData value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DashboardCounts counts, @JsonKey(fromJson: _statusMap)  Map<String, int> byStatus,  List<MonthlyPoint> monthlyRequests,  List<MonthlyPoint> monthlyFunded,  List<BudgetPosition> budgets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that.counts,_that.byStatus,_that.monthlyRequests,_that.monthlyFunded,_that.budgets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DashboardCounts counts, @JsonKey(fromJson: _statusMap)  Map<String, int> byStatus,  List<MonthlyPoint> monthlyRequests,  List<MonthlyPoint> monthlyFunded,  List<BudgetPosition> budgets)  $default,) {final _that = this;
switch (_that) {
case _DashboardData():
return $default(_that.counts,_that.byStatus,_that.monthlyRequests,_that.monthlyFunded,_that.budgets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DashboardCounts counts, @JsonKey(fromJson: _statusMap)  Map<String, int> byStatus,  List<MonthlyPoint> monthlyRequests,  List<MonthlyPoint> monthlyFunded,  List<BudgetPosition> budgets)?  $default,) {final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that.counts,_that.byStatus,_that.monthlyRequests,_that.monthlyFunded,_that.budgets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardData implements DashboardData {
  const _DashboardData({required this.counts, @JsonKey(fromJson: _statusMap) final  Map<String, int> byStatus = const {}, final  List<MonthlyPoint> monthlyRequests = const [], final  List<MonthlyPoint> monthlyFunded = const [], final  List<BudgetPosition> budgets = const []}): _byStatus = byStatus,_monthlyRequests = monthlyRequests,_monthlyFunded = monthlyFunded,_budgets = budgets;
  factory _DashboardData.fromJson(Map<String, dynamic> json) => _$DashboardDataFromJson(json);

@override final  DashboardCounts counts;
 final  Map<String, int> _byStatus;
@override@JsonKey(fromJson: _statusMap) Map<String, int> get byStatus {
  if (_byStatus is EqualUnmodifiableMapView) return _byStatus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byStatus);
}

 final  List<MonthlyPoint> _monthlyRequests;
@override@JsonKey() List<MonthlyPoint> get monthlyRequests {
  if (_monthlyRequests is EqualUnmodifiableListView) return _monthlyRequests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthlyRequests);
}

 final  List<MonthlyPoint> _monthlyFunded;
@override@JsonKey() List<MonthlyPoint> get monthlyFunded {
  if (_monthlyFunded is EqualUnmodifiableListView) return _monthlyFunded;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthlyFunded);
}

 final  List<BudgetPosition> _budgets;
@override@JsonKey() List<BudgetPosition> get budgets {
  if (_budgets is EqualUnmodifiableListView) return _budgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_budgets);
}


/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardDataCopyWith<_DashboardData> get copyWith => __$DashboardDataCopyWithImpl<_DashboardData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardData&&(identical(other.counts, counts) || other.counts == counts)&&const DeepCollectionEquality().equals(other._byStatus, _byStatus)&&const DeepCollectionEquality().equals(other._monthlyRequests, _monthlyRequests)&&const DeepCollectionEquality().equals(other._monthlyFunded, _monthlyFunded)&&const DeepCollectionEquality().equals(other._budgets, _budgets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,counts,const DeepCollectionEquality().hash(_byStatus),const DeepCollectionEquality().hash(_monthlyRequests),const DeepCollectionEquality().hash(_monthlyFunded),const DeepCollectionEquality().hash(_budgets));

@override
String toString() {
  return 'DashboardData(counts: $counts, byStatus: $byStatus, monthlyRequests: $monthlyRequests, monthlyFunded: $monthlyFunded, budgets: $budgets)';
}


}

/// @nodoc
abstract mixin class _$DashboardDataCopyWith<$Res> implements $DashboardDataCopyWith<$Res> {
  factory _$DashboardDataCopyWith(_DashboardData value, $Res Function(_DashboardData) _then) = __$DashboardDataCopyWithImpl;
@override @useResult
$Res call({
 DashboardCounts counts,@JsonKey(fromJson: _statusMap) Map<String, int> byStatus, List<MonthlyPoint> monthlyRequests, List<MonthlyPoint> monthlyFunded, List<BudgetPosition> budgets
});


@override $DashboardCountsCopyWith<$Res> get counts;

}
/// @nodoc
class __$DashboardDataCopyWithImpl<$Res>
    implements _$DashboardDataCopyWith<$Res> {
  __$DashboardDataCopyWithImpl(this._self, this._then);

  final _DashboardData _self;
  final $Res Function(_DashboardData) _then;

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? counts = null,Object? byStatus = null,Object? monthlyRequests = null,Object? monthlyFunded = null,Object? budgets = null,}) {
  return _then(_DashboardData(
counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as DashboardCounts,byStatus: null == byStatus ? _self._byStatus : byStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>,monthlyRequests: null == monthlyRequests ? _self._monthlyRequests : monthlyRequests // ignore: cast_nullable_to_non_nullable
as List<MonthlyPoint>,monthlyFunded: null == monthlyFunded ? _self._monthlyFunded : monthlyFunded // ignore: cast_nullable_to_non_nullable
as List<MonthlyPoint>,budgets: null == budgets ? _self._budgets : budgets // ignore: cast_nullable_to_non_nullable
as List<BudgetPosition>,
  ));
}

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardCountsCopyWith<$Res> get counts {
  
  return $DashboardCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}
}

// dart format on
