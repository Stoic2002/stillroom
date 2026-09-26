// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'save_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SaveFile {

 int get schemaVersion;/// Episode the "Continue" button resumes.
 String? get lastEpisodeId;/// Keyed by episode id.
 Map<String, GameState> get episodes;
/// Create a copy of SaveFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveFileCopyWith<SaveFile> get copyWith => _$SaveFileCopyWithImpl<SaveFile>(this as SaveFile, _$identity);

  /// Serializes this SaveFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveFile&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.lastEpisodeId, lastEpisodeId) || other.lastEpisodeId == lastEpisodeId)&&const DeepCollectionEquality().equals(other.episodes, episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,lastEpisodeId,const DeepCollectionEquality().hash(episodes));

@override
String toString() {
  return 'SaveFile(schemaVersion: $schemaVersion, lastEpisodeId: $lastEpisodeId, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class $SaveFileCopyWith<$Res>  {
  factory $SaveFileCopyWith(SaveFile value, $Res Function(SaveFile) _then) = _$SaveFileCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String? lastEpisodeId, Map<String, GameState> episodes
});




}
/// @nodoc
class _$SaveFileCopyWithImpl<$Res>
    implements $SaveFileCopyWith<$Res> {
  _$SaveFileCopyWithImpl(this._self, this._then);

  final SaveFile _self;
  final $Res Function(SaveFile) _then;

/// Create a copy of SaveFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? lastEpisodeId = freezed,Object? episodes = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,lastEpisodeId: freezed == lastEpisodeId ? _self.lastEpisodeId : lastEpisodeId // ignore: cast_nullable_to_non_nullable
as String?,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as Map<String, GameState>,
  ));
}

}


/// Adds pattern-matching-related methods to [SaveFile].
extension SaveFilePatterns on SaveFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaveFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaveFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaveFile value)  $default,){
final _that = this;
switch (_that) {
case _SaveFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaveFile value)?  $default,){
final _that = this;
switch (_that) {
case _SaveFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String? lastEpisodeId,  Map<String, GameState> episodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaveFile() when $default != null:
return $default(_that.schemaVersion,_that.lastEpisodeId,_that.episodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String? lastEpisodeId,  Map<String, GameState> episodes)  $default,) {final _that = this;
switch (_that) {
case _SaveFile():
return $default(_that.schemaVersion,_that.lastEpisodeId,_that.episodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String? lastEpisodeId,  Map<String, GameState> episodes)?  $default,) {final _that = this;
switch (_that) {
case _SaveFile() when $default != null:
return $default(_that.schemaVersion,_that.lastEpisodeId,_that.episodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaveFile implements SaveFile {
  const _SaveFile({this.schemaVersion = SaveFile.currentSchemaVersion, this.lastEpisodeId, final  Map<String, GameState> episodes = const <String, GameState>{}}): _episodes = episodes;
  factory _SaveFile.fromJson(Map<String, dynamic> json) => _$SaveFileFromJson(json);

@override@JsonKey() final  int schemaVersion;
/// Episode the "Continue" button resumes.
@override final  String? lastEpisodeId;
/// Keyed by episode id.
 final  Map<String, GameState> _episodes;
/// Keyed by episode id.
@override@JsonKey() Map<String, GameState> get episodes {
  if (_episodes is EqualUnmodifiableMapView) return _episodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_episodes);
}


/// Create a copy of SaveFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveFileCopyWith<_SaveFile> get copyWith => __$SaveFileCopyWithImpl<_SaveFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaveFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveFile&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.lastEpisodeId, lastEpisodeId) || other.lastEpisodeId == lastEpisodeId)&&const DeepCollectionEquality().equals(other._episodes, _episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,lastEpisodeId,const DeepCollectionEquality().hash(_episodes));

@override
String toString() {
  return 'SaveFile(schemaVersion: $schemaVersion, lastEpisodeId: $lastEpisodeId, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class _$SaveFileCopyWith<$Res> implements $SaveFileCopyWith<$Res> {
  factory _$SaveFileCopyWith(_SaveFile value, $Res Function(_SaveFile) _then) = __$SaveFileCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String? lastEpisodeId, Map<String, GameState> episodes
});




}
/// @nodoc
class __$SaveFileCopyWithImpl<$Res>
    implements _$SaveFileCopyWith<$Res> {
  __$SaveFileCopyWithImpl(this._self, this._then);

  final _SaveFile _self;
  final $Res Function(_SaveFile) _then;

/// Create a copy of SaveFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? lastEpisodeId = freezed,Object? episodes = null,}) {
  return _then(_SaveFile(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,lastEpisodeId: freezed == lastEpisodeId ? _self.lastEpisodeId : lastEpisodeId // ignore: cast_nullable_to_non_nullable
as String?,episodes: null == episodes ? _self._episodes : episodes // ignore: cast_nullable_to_non_nullable
as Map<String, GameState>,
  ));
}


}

// dart format on
