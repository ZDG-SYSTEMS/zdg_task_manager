// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationTask {

 int get id; String get title;
/// Create a copy of NotificationTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationTaskCopyWith<NotificationTask> get copyWith => _$NotificationTaskCopyWithImpl<NotificationTask>(this as NotificationTask, _$identity);

  /// Serializes this NotificationTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'NotificationTask(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class $NotificationTaskCopyWith<$Res>  {
  factory $NotificationTaskCopyWith(NotificationTask value, $Res Function(NotificationTask) _then) = _$NotificationTaskCopyWithImpl;
@useResult
$Res call({
 int id, String title
});




}
/// @nodoc
class _$NotificationTaskCopyWithImpl<$Res>
    implements $NotificationTaskCopyWith<$Res> {
  _$NotificationTaskCopyWithImpl(this._self, this._then);

  final NotificationTask _self;
  final $Res Function(NotificationTask) _then;

/// Create a copy of NotificationTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationTask].
extension NotificationTaskPatterns on NotificationTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationTask value)  $default,){
final _that = this;
switch (_that) {
case _NotificationTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationTask value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationTask() when $default != null:
return $default(_that.id,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title)  $default,) {final _that = this;
switch (_that) {
case _NotificationTask():
return $default(_that.id,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title)?  $default,) {final _that = this;
switch (_that) {
case _NotificationTask() when $default != null:
return $default(_that.id,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationTask implements NotificationTask {
  const _NotificationTask({required this.id, required this.title});
  factory _NotificationTask.fromJson(Map<String, dynamic> json) => _$NotificationTaskFromJson(json);

@override final  int id;
@override final  String title;

/// Create a copy of NotificationTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationTaskCopyWith<_NotificationTask> get copyWith => __$NotificationTaskCopyWithImpl<_NotificationTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title);

@override
String toString() {
  return 'NotificationTask(id: $id, title: $title)';
}


}

/// @nodoc
abstract mixin class _$NotificationTaskCopyWith<$Res> implements $NotificationTaskCopyWith<$Res> {
  factory _$NotificationTaskCopyWith(_NotificationTask value, $Res Function(_NotificationTask) _then) = __$NotificationTaskCopyWithImpl;
@override @useResult
$Res call({
 int id, String title
});




}
/// @nodoc
class __$NotificationTaskCopyWithImpl<$Res>
    implements _$NotificationTaskCopyWith<$Res> {
  __$NotificationTaskCopyWithImpl(this._self, this._then);

  final _NotificationTask _self;
  final $Res Function(_NotificationTask) _then;

/// Create a copy of NotificationTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,}) {
  return _then(_NotificationTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AppNotification {

 int get id; int? get taskId; String get event; List<String> get channelsSent; DateTime? get readAt; DateTime? get createdAt; NotificationTask? get task;
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<AppNotification> get copyWith => _$AppNotificationCopyWithImpl<AppNotification>(this as AppNotification, _$identity);

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.event, event) || other.event == event)&&const DeepCollectionEquality().equals(other.channelsSent, channelsSent)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.task, task) || other.task == task));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,taskId,event,const DeepCollectionEquality().hash(channelsSent),readAt,createdAt,task);

@override
String toString() {
  return 'AppNotification(id: $id, taskId: $taskId, event: $event, channelsSent: $channelsSent, readAt: $readAt, createdAt: $createdAt, task: $task)';
}


}

/// @nodoc
abstract mixin class $AppNotificationCopyWith<$Res>  {
  factory $AppNotificationCopyWith(AppNotification value, $Res Function(AppNotification) _then) = _$AppNotificationCopyWithImpl;
@useResult
$Res call({
 int id, int? taskId, String event, List<String> channelsSent, DateTime? readAt, DateTime? createdAt, NotificationTask? task
});


$NotificationTaskCopyWith<$Res>? get task;

}
/// @nodoc
class _$AppNotificationCopyWithImpl<$Res>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._self, this._then);

  final AppNotification _self;
  final $Res Function(AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = freezed,Object? event = null,Object? channelsSent = null,Object? readAt = freezed,Object? createdAt = freezed,Object? task = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String,channelsSent: null == channelsSent ? _self.channelsSent : channelsSent // ignore: cast_nullable_to_non_nullable
as List<String>,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,task: freezed == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as NotificationTask?,
  ));
}
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationTaskCopyWith<$Res>? get task {
    if (_self.task == null) {
    return null;
  }

  return $NotificationTaskCopyWith<$Res>(_self.task!, (value) {
    return _then(_self.copyWith(task: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppNotification].
extension AppNotificationPatterns on AppNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppNotification value)  $default,){
final _that = this;
switch (_that) {
case _AppNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppNotification value)?  $default,){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? taskId,  String event,  List<String> channelsSent,  DateTime? readAt,  DateTime? createdAt,  NotificationTask? task)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.taskId,_that.event,_that.channelsSent,_that.readAt,_that.createdAt,_that.task);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? taskId,  String event,  List<String> channelsSent,  DateTime? readAt,  DateTime? createdAt,  NotificationTask? task)  $default,) {final _that = this;
switch (_that) {
case _AppNotification():
return $default(_that.id,_that.taskId,_that.event,_that.channelsSent,_that.readAt,_that.createdAt,_that.task);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? taskId,  String event,  List<String> channelsSent,  DateTime? readAt,  DateTime? createdAt,  NotificationTask? task)?  $default,) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.taskId,_that.event,_that.channelsSent,_that.readAt,_that.createdAt,_that.task);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppNotification implements AppNotification {
  const _AppNotification({required this.id, this.taskId, required this.event, required final  List<String> channelsSent, this.readAt, this.createdAt, this.task}): _channelsSent = channelsSent;
  factory _AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

@override final  int id;
@override final  int? taskId;
@override final  String event;
 final  List<String> _channelsSent;
@override List<String> get channelsSent {
  if (_channelsSent is EqualUnmodifiableListView) return _channelsSent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_channelsSent);
}

@override final  DateTime? readAt;
@override final  DateTime? createdAt;
@override final  NotificationTask? task;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotificationCopyWith<_AppNotification> get copyWith => __$AppNotificationCopyWithImpl<_AppNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.event, event) || other.event == event)&&const DeepCollectionEquality().equals(other._channelsSent, _channelsSent)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.task, task) || other.task == task));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,taskId,event,const DeepCollectionEquality().hash(_channelsSent),readAt,createdAt,task);

@override
String toString() {
  return 'AppNotification(id: $id, taskId: $taskId, event: $event, channelsSent: $channelsSent, readAt: $readAt, createdAt: $createdAt, task: $task)';
}


}

/// @nodoc
abstract mixin class _$AppNotificationCopyWith<$Res> implements $AppNotificationCopyWith<$Res> {
  factory _$AppNotificationCopyWith(_AppNotification value, $Res Function(_AppNotification) _then) = __$AppNotificationCopyWithImpl;
@override @useResult
$Res call({
 int id, int? taskId, String event, List<String> channelsSent, DateTime? readAt, DateTime? createdAt, NotificationTask? task
});


@override $NotificationTaskCopyWith<$Res>? get task;

}
/// @nodoc
class __$AppNotificationCopyWithImpl<$Res>
    implements _$AppNotificationCopyWith<$Res> {
  __$AppNotificationCopyWithImpl(this._self, this._then);

  final _AppNotification _self;
  final $Res Function(_AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = freezed,Object? event = null,Object? channelsSent = null,Object? readAt = freezed,Object? createdAt = freezed,Object? task = freezed,}) {
  return _then(_AppNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as int?,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String,channelsSent: null == channelsSent ? _self._channelsSent : channelsSent // ignore: cast_nullable_to_non_nullable
as List<String>,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,task: freezed == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as NotificationTask?,
  ));
}

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationTaskCopyWith<$Res>? get task {
    if (_self.task == null) {
    return null;
  }

  return $NotificationTaskCopyWith<$Res>(_self.task!, (value) {
    return _then(_self.copyWith(task: value));
  });
}
}

// dart format on
