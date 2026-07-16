// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserLite {

 int get id; String? get code; String get name; String? get position; String? get branch;
/// Create a copy of UserLite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserLiteCopyWith<UserLite> get copyWith => _$UserLiteCopyWithImpl<UserLite>(this as UserLite, _$identity);

  /// Serializes this UserLite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserLite&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.position, position) || other.position == position)&&(identical(other.branch, branch) || other.branch == branch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,position,branch);

@override
String toString() {
  return 'UserLite(id: $id, code: $code, name: $name, position: $position, branch: $branch)';
}


}

/// @nodoc
abstract mixin class $UserLiteCopyWith<$Res>  {
  factory $UserLiteCopyWith(UserLite value, $Res Function(UserLite) _then) = _$UserLiteCopyWithImpl;
@useResult
$Res call({
 int id, String? code, String name, String? position, String? branch
});




}
/// @nodoc
class _$UserLiteCopyWithImpl<$Res>
    implements $UserLiteCopyWith<$Res> {
  _$UserLiteCopyWithImpl(this._self, this._then);

  final UserLite _self;
  final $Res Function(UserLite) _then;

/// Create a copy of UserLite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = freezed,Object? name = null,Object? position = freezed,Object? branch = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserLite].
extension UserLitePatterns on UserLite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserLite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserLite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserLite value)  $default,){
final _that = this;
switch (_that) {
case _UserLite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserLite value)?  $default,){
final _that = this;
switch (_that) {
case _UserLite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? code,  String name,  String? position,  String? branch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserLite() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.position,_that.branch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? code,  String name,  String? position,  String? branch)  $default,) {final _that = this;
switch (_that) {
case _UserLite():
return $default(_that.id,_that.code,_that.name,_that.position,_that.branch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? code,  String name,  String? position,  String? branch)?  $default,) {final _that = this;
switch (_that) {
case _UserLite() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.position,_that.branch);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserLite implements UserLite {
  const _UserLite({required this.id, this.code, required this.name, this.position, this.branch});
  factory _UserLite.fromJson(Map<String, dynamic> json) => _$UserLiteFromJson(json);

@override final  int id;
@override final  String? code;
@override final  String name;
@override final  String? position;
@override final  String? branch;

/// Create a copy of UserLite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserLiteCopyWith<_UserLite> get copyWith => __$UserLiteCopyWithImpl<_UserLite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserLiteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserLite&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.position, position) || other.position == position)&&(identical(other.branch, branch) || other.branch == branch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,position,branch);

@override
String toString() {
  return 'UserLite(id: $id, code: $code, name: $name, position: $position, branch: $branch)';
}


}

/// @nodoc
abstract mixin class _$UserLiteCopyWith<$Res> implements $UserLiteCopyWith<$Res> {
  factory _$UserLiteCopyWith(_UserLite value, $Res Function(_UserLite) _then) = __$UserLiteCopyWithImpl;
@override @useResult
$Res call({
 int id, String? code, String name, String? position, String? branch
});




}
/// @nodoc
class __$UserLiteCopyWithImpl<$Res>
    implements _$UserLiteCopyWith<$Res> {
  __$UserLiteCopyWithImpl(this._self, this._then);

  final _UserLite _self;
  final $Res Function(_UserLite) _then;

/// Create a copy of UserLite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = freezed,Object? name = null,Object? position = freezed,Object? branch = freezed,}) {
  return _then(_UserLite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Task {

 int get id; TaskType get type; String get title; String? get description; String? get draftReason; TaskStatus get status; Priority? get priority; int? get amountRequested; int? get amountApproved; String? get amountEditReason; String get currency; DateTime? get dueDate; BeneficiaryType? get beneficiaryType; String? get beneficiaryName; bool? get receiptRequired; bool get overdue; bool get viaTechnical; bool get funded; DateTime? get fundedAt; String? get fundedReference; int? get fundedAmount; int? get amountIssued; int? get amountAccounted; int? get balanceReturned; int? get balanceRemaining; DateTime? get receiptDueDate; int? get recipientId; int? get assignedFunderId; int get companyId; int? get createdBy; DateTime? get createdAt; UserLite? get creator; Company? get company; UserLite? get recipient; List<Attachment>? get attachments; List<Receipt>? get receipts;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.draftReason, draftReason) || other.draftReason == draftReason)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.amountRequested, amountRequested) || other.amountRequested == amountRequested)&&(identical(other.amountApproved, amountApproved) || other.amountApproved == amountApproved)&&(identical(other.amountEditReason, amountEditReason) || other.amountEditReason == amountEditReason)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.beneficiaryType, beneficiaryType) || other.beneficiaryType == beneficiaryType)&&(identical(other.beneficiaryName, beneficiaryName) || other.beneficiaryName == beneficiaryName)&&(identical(other.receiptRequired, receiptRequired) || other.receiptRequired == receiptRequired)&&(identical(other.overdue, overdue) || other.overdue == overdue)&&(identical(other.viaTechnical, viaTechnical) || other.viaTechnical == viaTechnical)&&(identical(other.funded, funded) || other.funded == funded)&&(identical(other.fundedAt, fundedAt) || other.fundedAt == fundedAt)&&(identical(other.fundedReference, fundedReference) || other.fundedReference == fundedReference)&&(identical(other.fundedAmount, fundedAmount) || other.fundedAmount == fundedAmount)&&(identical(other.amountIssued, amountIssued) || other.amountIssued == amountIssued)&&(identical(other.amountAccounted, amountAccounted) || other.amountAccounted == amountAccounted)&&(identical(other.balanceReturned, balanceReturned) || other.balanceReturned == balanceReturned)&&(identical(other.balanceRemaining, balanceRemaining) || other.balanceRemaining == balanceRemaining)&&(identical(other.receiptDueDate, receiptDueDate) || other.receiptDueDate == receiptDueDate)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.assignedFunderId, assignedFunderId) || other.assignedFunderId == assignedFunderId)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.company, company) || other.company == company)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&const DeepCollectionEquality().equals(other.receipts, receipts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,title,description,draftReason,status,priority,amountRequested,amountApproved,amountEditReason,currency,dueDate,beneficiaryType,beneficiaryName,receiptRequired,overdue,viaTechnical,funded,fundedAt,fundedReference,fundedAmount,amountIssued,amountAccounted,balanceReturned,balanceRemaining,receiptDueDate,recipientId,assignedFunderId,companyId,createdBy,createdAt,creator,company,recipient,const DeepCollectionEquality().hash(attachments),const DeepCollectionEquality().hash(receipts)]);

@override
String toString() {
  return 'Task(id: $id, type: $type, title: $title, description: $description, draftReason: $draftReason, status: $status, priority: $priority, amountRequested: $amountRequested, amountApproved: $amountApproved, amountEditReason: $amountEditReason, currency: $currency, dueDate: $dueDate, beneficiaryType: $beneficiaryType, beneficiaryName: $beneficiaryName, receiptRequired: $receiptRequired, overdue: $overdue, viaTechnical: $viaTechnical, funded: $funded, fundedAt: $fundedAt, fundedReference: $fundedReference, fundedAmount: $fundedAmount, amountIssued: $amountIssued, amountAccounted: $amountAccounted, balanceReturned: $balanceReturned, balanceRemaining: $balanceRemaining, receiptDueDate: $receiptDueDate, recipientId: $recipientId, assignedFunderId: $assignedFunderId, companyId: $companyId, createdBy: $createdBy, createdAt: $createdAt, creator: $creator, company: $company, recipient: $recipient, attachments: $attachments, receipts: $receipts)';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 int id, TaskType type, String title, String? description, String? draftReason, TaskStatus status, Priority? priority, int? amountRequested, int? amountApproved, String? amountEditReason, String currency, DateTime? dueDate, BeneficiaryType? beneficiaryType, String? beneficiaryName, bool? receiptRequired, bool overdue, bool viaTechnical, bool funded, DateTime? fundedAt, String? fundedReference, int? fundedAmount, int? amountIssued, int? amountAccounted, int? balanceReturned, int? balanceRemaining, DateTime? receiptDueDate, int? recipientId, int? assignedFunderId, int companyId, int? createdBy, DateTime? createdAt, UserLite? creator, Company? company, UserLite? recipient, List<Attachment>? attachments, List<Receipt>? receipts
});


$UserLiteCopyWith<$Res>? get creator;$CompanyCopyWith<$Res>? get company;$UserLiteCopyWith<$Res>? get recipient;

}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = null,Object? description = freezed,Object? draftReason = freezed,Object? status = null,Object? priority = freezed,Object? amountRequested = freezed,Object? amountApproved = freezed,Object? amountEditReason = freezed,Object? currency = null,Object? dueDate = freezed,Object? beneficiaryType = freezed,Object? beneficiaryName = freezed,Object? receiptRequired = freezed,Object? overdue = null,Object? viaTechnical = null,Object? funded = null,Object? fundedAt = freezed,Object? fundedReference = freezed,Object? fundedAmount = freezed,Object? amountIssued = freezed,Object? amountAccounted = freezed,Object? balanceReturned = freezed,Object? balanceRemaining = freezed,Object? receiptDueDate = freezed,Object? recipientId = freezed,Object? assignedFunderId = freezed,Object? companyId = null,Object? createdBy = freezed,Object? createdAt = freezed,Object? creator = freezed,Object? company = freezed,Object? recipient = freezed,Object? attachments = freezed,Object? receipts = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TaskType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,draftReason: freezed == draftReason ? _self.draftReason : draftReason // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,amountRequested: freezed == amountRequested ? _self.amountRequested : amountRequested // ignore: cast_nullable_to_non_nullable
as int?,amountApproved: freezed == amountApproved ? _self.amountApproved : amountApproved // ignore: cast_nullable_to_non_nullable
as int?,amountEditReason: freezed == amountEditReason ? _self.amountEditReason : amountEditReason // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,beneficiaryType: freezed == beneficiaryType ? _self.beneficiaryType : beneficiaryType // ignore: cast_nullable_to_non_nullable
as BeneficiaryType?,beneficiaryName: freezed == beneficiaryName ? _self.beneficiaryName : beneficiaryName // ignore: cast_nullable_to_non_nullable
as String?,receiptRequired: freezed == receiptRequired ? _self.receiptRequired : receiptRequired // ignore: cast_nullable_to_non_nullable
as bool?,overdue: null == overdue ? _self.overdue : overdue // ignore: cast_nullable_to_non_nullable
as bool,viaTechnical: null == viaTechnical ? _self.viaTechnical : viaTechnical // ignore: cast_nullable_to_non_nullable
as bool,funded: null == funded ? _self.funded : funded // ignore: cast_nullable_to_non_nullable
as bool,fundedAt: freezed == fundedAt ? _self.fundedAt : fundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fundedReference: freezed == fundedReference ? _self.fundedReference : fundedReference // ignore: cast_nullable_to_non_nullable
as String?,fundedAmount: freezed == fundedAmount ? _self.fundedAmount : fundedAmount // ignore: cast_nullable_to_non_nullable
as int?,amountIssued: freezed == amountIssued ? _self.amountIssued : amountIssued // ignore: cast_nullable_to_non_nullable
as int?,amountAccounted: freezed == amountAccounted ? _self.amountAccounted : amountAccounted // ignore: cast_nullable_to_non_nullable
as int?,balanceReturned: freezed == balanceReturned ? _self.balanceReturned : balanceReturned // ignore: cast_nullable_to_non_nullable
as int?,balanceRemaining: freezed == balanceRemaining ? _self.balanceRemaining : balanceRemaining // ignore: cast_nullable_to_non_nullable
as int?,receiptDueDate: freezed == receiptDueDate ? _self.receiptDueDate : receiptDueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,recipientId: freezed == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as int?,assignedFunderId: freezed == assignedFunderId ? _self.assignedFunderId : assignedFunderId // ignore: cast_nullable_to_non_nullable
as int?,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as int,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as UserLite?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as UserLite?,attachments: freezed == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>?,receipts: freezed == receipts ? _self.receipts : receipts // ignore: cast_nullable_to_non_nullable
as List<Receipt>?,
  ));
}
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserLiteCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $UserLiteCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of Task
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
}/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserLiteCopyWith<$Res>? get recipient {
    if (_self.recipient == null) {
    return null;
  }

  return $UserLiteCopyWith<$Res>(_self.recipient!, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}
}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  TaskType type,  String title,  String? description,  String? draftReason,  TaskStatus status,  Priority? priority,  int? amountRequested,  int? amountApproved,  String? amountEditReason,  String currency,  DateTime? dueDate,  BeneficiaryType? beneficiaryType,  String? beneficiaryName,  bool? receiptRequired,  bool overdue,  bool viaTechnical,  bool funded,  DateTime? fundedAt,  String? fundedReference,  int? fundedAmount,  int? amountIssued,  int? amountAccounted,  int? balanceReturned,  int? balanceRemaining,  DateTime? receiptDueDate,  int? recipientId,  int? assignedFunderId,  int companyId,  int? createdBy,  DateTime? createdAt,  UserLite? creator,  Company? company,  UserLite? recipient,  List<Attachment>? attachments,  List<Receipt>? receipts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.description,_that.draftReason,_that.status,_that.priority,_that.amountRequested,_that.amountApproved,_that.amountEditReason,_that.currency,_that.dueDate,_that.beneficiaryType,_that.beneficiaryName,_that.receiptRequired,_that.overdue,_that.viaTechnical,_that.funded,_that.fundedAt,_that.fundedReference,_that.fundedAmount,_that.amountIssued,_that.amountAccounted,_that.balanceReturned,_that.balanceRemaining,_that.receiptDueDate,_that.recipientId,_that.assignedFunderId,_that.companyId,_that.createdBy,_that.createdAt,_that.creator,_that.company,_that.recipient,_that.attachments,_that.receipts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  TaskType type,  String title,  String? description,  String? draftReason,  TaskStatus status,  Priority? priority,  int? amountRequested,  int? amountApproved,  String? amountEditReason,  String currency,  DateTime? dueDate,  BeneficiaryType? beneficiaryType,  String? beneficiaryName,  bool? receiptRequired,  bool overdue,  bool viaTechnical,  bool funded,  DateTime? fundedAt,  String? fundedReference,  int? fundedAmount,  int? amountIssued,  int? amountAccounted,  int? balanceReturned,  int? balanceRemaining,  DateTime? receiptDueDate,  int? recipientId,  int? assignedFunderId,  int companyId,  int? createdBy,  DateTime? createdAt,  UserLite? creator,  Company? company,  UserLite? recipient,  List<Attachment>? attachments,  List<Receipt>? receipts)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.type,_that.title,_that.description,_that.draftReason,_that.status,_that.priority,_that.amountRequested,_that.amountApproved,_that.amountEditReason,_that.currency,_that.dueDate,_that.beneficiaryType,_that.beneficiaryName,_that.receiptRequired,_that.overdue,_that.viaTechnical,_that.funded,_that.fundedAt,_that.fundedReference,_that.fundedAmount,_that.amountIssued,_that.amountAccounted,_that.balanceReturned,_that.balanceRemaining,_that.receiptDueDate,_that.recipientId,_that.assignedFunderId,_that.companyId,_that.createdBy,_that.createdAt,_that.creator,_that.company,_that.recipient,_that.attachments,_that.receipts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  TaskType type,  String title,  String? description,  String? draftReason,  TaskStatus status,  Priority? priority,  int? amountRequested,  int? amountApproved,  String? amountEditReason,  String currency,  DateTime? dueDate,  BeneficiaryType? beneficiaryType,  String? beneficiaryName,  bool? receiptRequired,  bool overdue,  bool viaTechnical,  bool funded,  DateTime? fundedAt,  String? fundedReference,  int? fundedAmount,  int? amountIssued,  int? amountAccounted,  int? balanceReturned,  int? balanceRemaining,  DateTime? receiptDueDate,  int? recipientId,  int? assignedFunderId,  int companyId,  int? createdBy,  DateTime? createdAt,  UserLite? creator,  Company? company,  UserLite? recipient,  List<Attachment>? attachments,  List<Receipt>? receipts)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.description,_that.draftReason,_that.status,_that.priority,_that.amountRequested,_that.amountApproved,_that.amountEditReason,_that.currency,_that.dueDate,_that.beneficiaryType,_that.beneficiaryName,_that.receiptRequired,_that.overdue,_that.viaTechnical,_that.funded,_that.fundedAt,_that.fundedReference,_that.fundedAmount,_that.amountIssued,_that.amountAccounted,_that.balanceReturned,_that.balanceRemaining,_that.receiptDueDate,_that.recipientId,_that.assignedFunderId,_that.companyId,_that.createdBy,_that.createdAt,_that.creator,_that.company,_that.recipient,_that.attachments,_that.receipts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Task implements Task {
  const _Task({required this.id, required this.type, required this.title, this.description, this.draftReason, required this.status, this.priority, this.amountRequested, this.amountApproved, this.amountEditReason, this.currency = 'ZMW', this.dueDate, this.beneficiaryType, this.beneficiaryName, this.receiptRequired, this.overdue = false, this.viaTechnical = false, this.funded = false, this.fundedAt, this.fundedReference, this.fundedAmount, this.amountIssued, this.amountAccounted, this.balanceReturned, this.balanceRemaining, this.receiptDueDate, this.recipientId, this.assignedFunderId, required this.companyId, this.createdBy, this.createdAt, this.creator, this.company, this.recipient, final  List<Attachment>? attachments, final  List<Receipt>? receipts}): _attachments = attachments,_receipts = receipts;
  factory _Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

@override final  int id;
@override final  TaskType type;
@override final  String title;
@override final  String? description;
@override final  String? draftReason;
@override final  TaskStatus status;
@override final  Priority? priority;
@override final  int? amountRequested;
@override final  int? amountApproved;
@override final  String? amountEditReason;
@override@JsonKey() final  String currency;
@override final  DateTime? dueDate;
@override final  BeneficiaryType? beneficiaryType;
@override final  String? beneficiaryName;
@override final  bool? receiptRequired;
@override@JsonKey() final  bool overdue;
@override@JsonKey() final  bool viaTechnical;
@override@JsonKey() final  bool funded;
@override final  DateTime? fundedAt;
@override final  String? fundedReference;
@override final  int? fundedAmount;
@override final  int? amountIssued;
@override final  int? amountAccounted;
@override final  int? balanceReturned;
@override final  int? balanceRemaining;
@override final  DateTime? receiptDueDate;
@override final  int? recipientId;
@override final  int? assignedFunderId;
@override final  int companyId;
@override final  int? createdBy;
@override final  DateTime? createdAt;
@override final  UserLite? creator;
@override final  Company? company;
@override final  UserLite? recipient;
 final  List<Attachment>? _attachments;
@override List<Attachment>? get attachments {
  final value = _attachments;
  if (value == null) return null;
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Receipt>? _receipts;
@override List<Receipt>? get receipts {
  final value = _receipts;
  if (value == null) return null;
  if (_receipts is EqualUnmodifiableListView) return _receipts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.draftReason, draftReason) || other.draftReason == draftReason)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.amountRequested, amountRequested) || other.amountRequested == amountRequested)&&(identical(other.amountApproved, amountApproved) || other.amountApproved == amountApproved)&&(identical(other.amountEditReason, amountEditReason) || other.amountEditReason == amountEditReason)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.beneficiaryType, beneficiaryType) || other.beneficiaryType == beneficiaryType)&&(identical(other.beneficiaryName, beneficiaryName) || other.beneficiaryName == beneficiaryName)&&(identical(other.receiptRequired, receiptRequired) || other.receiptRequired == receiptRequired)&&(identical(other.overdue, overdue) || other.overdue == overdue)&&(identical(other.viaTechnical, viaTechnical) || other.viaTechnical == viaTechnical)&&(identical(other.funded, funded) || other.funded == funded)&&(identical(other.fundedAt, fundedAt) || other.fundedAt == fundedAt)&&(identical(other.fundedReference, fundedReference) || other.fundedReference == fundedReference)&&(identical(other.fundedAmount, fundedAmount) || other.fundedAmount == fundedAmount)&&(identical(other.amountIssued, amountIssued) || other.amountIssued == amountIssued)&&(identical(other.amountAccounted, amountAccounted) || other.amountAccounted == amountAccounted)&&(identical(other.balanceReturned, balanceReturned) || other.balanceReturned == balanceReturned)&&(identical(other.balanceRemaining, balanceRemaining) || other.balanceRemaining == balanceRemaining)&&(identical(other.receiptDueDate, receiptDueDate) || other.receiptDueDate == receiptDueDate)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.assignedFunderId, assignedFunderId) || other.assignedFunderId == assignedFunderId)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.company, company) || other.company == company)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&const DeepCollectionEquality().equals(other._receipts, _receipts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,title,description,draftReason,status,priority,amountRequested,amountApproved,amountEditReason,currency,dueDate,beneficiaryType,beneficiaryName,receiptRequired,overdue,viaTechnical,funded,fundedAt,fundedReference,fundedAmount,amountIssued,amountAccounted,balanceReturned,balanceRemaining,receiptDueDate,recipientId,assignedFunderId,companyId,createdBy,createdAt,creator,company,recipient,const DeepCollectionEquality().hash(_attachments),const DeepCollectionEquality().hash(_receipts)]);

@override
String toString() {
  return 'Task(id: $id, type: $type, title: $title, description: $description, draftReason: $draftReason, status: $status, priority: $priority, amountRequested: $amountRequested, amountApproved: $amountApproved, amountEditReason: $amountEditReason, currency: $currency, dueDate: $dueDate, beneficiaryType: $beneficiaryType, beneficiaryName: $beneficiaryName, receiptRequired: $receiptRequired, overdue: $overdue, viaTechnical: $viaTechnical, funded: $funded, fundedAt: $fundedAt, fundedReference: $fundedReference, fundedAmount: $fundedAmount, amountIssued: $amountIssued, amountAccounted: $amountAccounted, balanceReturned: $balanceReturned, balanceRemaining: $balanceRemaining, receiptDueDate: $receiptDueDate, recipientId: $recipientId, assignedFunderId: $assignedFunderId, companyId: $companyId, createdBy: $createdBy, createdAt: $createdAt, creator: $creator, company: $company, recipient: $recipient, attachments: $attachments, receipts: $receipts)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 int id, TaskType type, String title, String? description, String? draftReason, TaskStatus status, Priority? priority, int? amountRequested, int? amountApproved, String? amountEditReason, String currency, DateTime? dueDate, BeneficiaryType? beneficiaryType, String? beneficiaryName, bool? receiptRequired, bool overdue, bool viaTechnical, bool funded, DateTime? fundedAt, String? fundedReference, int? fundedAmount, int? amountIssued, int? amountAccounted, int? balanceReturned, int? balanceRemaining, DateTime? receiptDueDate, int? recipientId, int? assignedFunderId, int companyId, int? createdBy, DateTime? createdAt, UserLite? creator, Company? company, UserLite? recipient, List<Attachment>? attachments, List<Receipt>? receipts
});


@override $UserLiteCopyWith<$Res>? get creator;@override $CompanyCopyWith<$Res>? get company;@override $UserLiteCopyWith<$Res>? get recipient;

}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = null,Object? description = freezed,Object? draftReason = freezed,Object? status = null,Object? priority = freezed,Object? amountRequested = freezed,Object? amountApproved = freezed,Object? amountEditReason = freezed,Object? currency = null,Object? dueDate = freezed,Object? beneficiaryType = freezed,Object? beneficiaryName = freezed,Object? receiptRequired = freezed,Object? overdue = null,Object? viaTechnical = null,Object? funded = null,Object? fundedAt = freezed,Object? fundedReference = freezed,Object? fundedAmount = freezed,Object? amountIssued = freezed,Object? amountAccounted = freezed,Object? balanceReturned = freezed,Object? balanceRemaining = freezed,Object? receiptDueDate = freezed,Object? recipientId = freezed,Object? assignedFunderId = freezed,Object? companyId = null,Object? createdBy = freezed,Object? createdAt = freezed,Object? creator = freezed,Object? company = freezed,Object? recipient = freezed,Object? attachments = freezed,Object? receipts = freezed,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TaskType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,draftReason: freezed == draftReason ? _self.draftReason : draftReason // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,amountRequested: freezed == amountRequested ? _self.amountRequested : amountRequested // ignore: cast_nullable_to_non_nullable
as int?,amountApproved: freezed == amountApproved ? _self.amountApproved : amountApproved // ignore: cast_nullable_to_non_nullable
as int?,amountEditReason: freezed == amountEditReason ? _self.amountEditReason : amountEditReason // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,beneficiaryType: freezed == beneficiaryType ? _self.beneficiaryType : beneficiaryType // ignore: cast_nullable_to_non_nullable
as BeneficiaryType?,beneficiaryName: freezed == beneficiaryName ? _self.beneficiaryName : beneficiaryName // ignore: cast_nullable_to_non_nullable
as String?,receiptRequired: freezed == receiptRequired ? _self.receiptRequired : receiptRequired // ignore: cast_nullable_to_non_nullable
as bool?,overdue: null == overdue ? _self.overdue : overdue // ignore: cast_nullable_to_non_nullable
as bool,viaTechnical: null == viaTechnical ? _self.viaTechnical : viaTechnical // ignore: cast_nullable_to_non_nullable
as bool,funded: null == funded ? _self.funded : funded // ignore: cast_nullable_to_non_nullable
as bool,fundedAt: freezed == fundedAt ? _self.fundedAt : fundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fundedReference: freezed == fundedReference ? _self.fundedReference : fundedReference // ignore: cast_nullable_to_non_nullable
as String?,fundedAmount: freezed == fundedAmount ? _self.fundedAmount : fundedAmount // ignore: cast_nullable_to_non_nullable
as int?,amountIssued: freezed == amountIssued ? _self.amountIssued : amountIssued // ignore: cast_nullable_to_non_nullable
as int?,amountAccounted: freezed == amountAccounted ? _self.amountAccounted : amountAccounted // ignore: cast_nullable_to_non_nullable
as int?,balanceReturned: freezed == balanceReturned ? _self.balanceReturned : balanceReturned // ignore: cast_nullable_to_non_nullable
as int?,balanceRemaining: freezed == balanceRemaining ? _self.balanceRemaining : balanceRemaining // ignore: cast_nullable_to_non_nullable
as int?,receiptDueDate: freezed == receiptDueDate ? _self.receiptDueDate : receiptDueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,recipientId: freezed == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as int?,assignedFunderId: freezed == assignedFunderId ? _self.assignedFunderId : assignedFunderId // ignore: cast_nullable_to_non_nullable
as int?,companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as int,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as UserLite?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as Company?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as UserLite?,attachments: freezed == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>?,receipts: freezed == receipts ? _self._receipts : receipts // ignore: cast_nullable_to_non_nullable
as List<Receipt>?,
  ));
}

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserLiteCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $UserLiteCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of Task
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
}/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserLiteCopyWith<$Res>? get recipient {
    if (_self.recipient == null) {
    return null;
  }

  return $UserLiteCopyWith<$Res>(_self.recipient!, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}
}

// dart format on
