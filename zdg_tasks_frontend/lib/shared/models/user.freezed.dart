// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 int get id; String get code; String get name; String get email; int get companyId; Company? get company; String get department; String? get branch; String get position; Role? get role; UserStatus get status;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.company, company) || other.company == company)&&(identical(other.department, department) || other.department == department)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.position, position) || other.position == position)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,email,companyId,company,department,branch,position,role,status);

@override
String toString() {
  return 'User(id: $id, code: $code, name: $name, email: $email, companyId: $companyId, company: $company, department: $department, branch: $branch, position: $position, role: $role, status: $status)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name, String email, int companyId, Company? company, String department, String? branch, String position, Role? role, UserStatus status
});


$CompanyCopyWith<$Res>? get company;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? email = null,Object? companyId = null,Object? company = freezed,Object? department = null,Object? branch = freezed,Object? position = null,Object? role = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as int,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,department: null == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,
  ));
}
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res>? get company {
    if (_self.company == null) {
    return null;
  }

  return $CompanyCopyWith<$Res>(_self.company!, (value) {
    return _then(_self.copyWith(company: value));
  });
}
}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name,  String email,  int companyId,  Company? company,  String department,  String? branch,  String position,  Role? role,  UserStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.email,_that.companyId,_that.company,_that.department,_that.branch,_that.position,_that.role,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name,  String email,  int companyId,  Company? company,  String department,  String? branch,  String position,  Role? role,  UserStatus status)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.code,_that.name,_that.email,_that.companyId,_that.company,_that.department,_that.branch,_that.position,_that.role,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name,  String email,  int companyId,  Company? company,  String department,  String? branch,  String position,  Role? role,  UserStatus status)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.email,_that.companyId,_that.company,_that.department,_that.branch,_that.position,_that.role,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, required this.code, required this.name, required this.email, required this.companyId, this.company, required this.department, this.branch, required this.position, this.role, required this.status});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override final  String email;
@override final  int companyId;
@override final  Company? company;
@override final  String department;
@override final  String? branch;
@override final  String position;
@override final  Role? role;
@override final  UserStatus status;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.company, company) || other.company == company)&&(identical(other.department, department) || other.department == department)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.position, position) || other.position == position)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,email,companyId,company,department,branch,position,role,status);

@override
String toString() {
  return 'User(id: $id, code: $code, name: $name, email: $email, companyId: $companyId, company: $company, department: $department, branch: $branch, position: $position, role: $role, status: $status)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name, String email, int companyId, Company? company, String department, String? branch, String position, Role? role, UserStatus status
});


@override $CompanyCopyWith<$Res>? get company;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? email = null,Object? companyId = null,Object? company = freezed,Object? department = null,Object? branch = freezed,Object? position = null,Object? role = freezed,Object? status = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as int,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,department: null == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,
  ));
}

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompanyCopyWith<$Res>? get company {
    if (_self.company == null) {
    return null;
  }

  return $CompanyCopyWith<$Res>(_self.company!, (value) {
    return _then(_self.copyWith(company: value));
  });
}
}

// dart format on
