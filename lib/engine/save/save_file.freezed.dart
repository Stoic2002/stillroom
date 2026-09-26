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
 Map<String, GameState> get episodes;/// Episodes ever finished. Survives starting a tale over, so a jar keeps
/// its seal and higher shelves stay open.
 Set<String> get distilled;/// The keeper's note key of each episode whose secret was found; also
/// survives starting over.
 Map<String, String> get keeperNotes;
/// Create a copy of SaveFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveFileCopyWith<SaveFile> get copyWith => _$SaveFileCopyWithImpl<SaveFile>(this as SaveFile, _$identity);

  /// Serializes this SaveFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveFile&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.lastEpisodeId, lastEpisodeId) || other.lastEpisodeId == lastEpisodeId)&&const DeepCollectionEquality().equals(other.episodes, episodes)&&const DeepCollectionEquality().equals(other.distilled, distilled)&&const DeepCollectionEquality().equals(other.keeperNotes, keeperNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,lastEpisodeId,const DeepCollectionEquality().hash(episodes),const DeepCollectionEquality().hash(distilled),const DeepCollectionEquality().hash(keeperNotes));

@override
String toString() {
  return 'SaveFile(schemaVersion: $schemaVersion, lastEpisodeId: $lastEpisodeId, episodes: $episodes, distilled: $distilled, keeperNotes: $keeperNotes)';
}


}

/// @nodoc
abstract mixin class $SaveFileCopyWith<$Res>  {
  factory $SaveFileCopyWith(SaveFile value, $Res Function(SaveFile) _then) = _$SaveFileCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String? lastEpisodeId, Map<String, GameState> episodes, Set<String> distilled, Map<String, String> keeperNotes
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
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? lastEpisodeId = freezed,Object? episodes = null,Object? distilled = null,Object? keeperNotes = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,lastEpisodeId: freezed == lastEpisodeId ? _self.lastEpisodeId : lastEpisodeId // ignore: cast_nullable_to_non_nullable
as String?,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as Map<String, GameState>,distilled: null == distilled ? _self.distilled : distilled // ignore: cast_nullable_to_non_nullable
as Set<String>,keeperNotes: null == keeperNotes ? _self.keeperNotes : keeperNotes // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String? lastEpisodeId,  Map<String, GameState> episodes,  Set<String> distilled,  Map<String, String> keeperNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaveFile() when $default != null:
return $default(_that.schemaVersion,_that.lastEpisodeId,_that.episodes,_that.distilled,_that.keeperNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String? lastEpisodeId,  Map<String, GameState> episodes,  Set<String> distilled,  Map<String, String> keeperNotes)  $default,) {final _that = this;
switch (_that) {
case _SaveFile():
return $default(_that.schemaVersion,_that.lastEpisodeId,_that.episodes,_that.distilled,_that.keeperNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String? lastEpisodeId,  Map<String, GameState> episodes,  Set<String> distilled,  Map<String, String> keeperNotes)?  $default,) {final _that = this;
switch (_that) {
case _SaveFile() when $default != null:
return $default(_that.schemaVersion,_that.lastEpisodeId,_that.episodes,_that.distilled,_that.keeperNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaveFile implements SaveFile {
  const _SaveFile({this.schemaVersion = SaveFile.currentSchemaVersion, this.lastEpisodeId, final  Map<String, GameState> episodes = const <String, GameState>{}, final  Set<String> distilled = const <String>{}, final  Map<String, String> keeperNotes = const <String, String>{}}): _episodes = episodes,_distilled = distilled,_keeperNotes = keeperNotes;
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

/// Episodes ever finished. Survives starting a tale over, so a jar keeps
/// its seal and higher shelves stay open.
 final  Set<String> _distilled;
/// Episodes ever finished. Survives starting a tale over, so a jar keeps
/// its seal and higher shelves stay open.
@override@JsonKey() Set<String> get distilled {
  if (_distilled is EqualUnmodifiableSetView) return _distilled;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_distilled);
}

/// The keeper's note key of each episode whose secret was found; also
/// survives starting over.
 final  Map<String, String> _keeperNotes;
/// The keeper's note key of each episode whose secret was found; also
/// survives starting over.
@override@JsonKey() Map<String, String> get keeperNotes {
  if (_keeperNotes is EqualUnmodifiableMapView) return _keeperNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_keeperNotes);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveFile&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.lastEpisodeId, lastEpisodeId) || other.lastEpisodeId == lastEpisodeId)&&const DeepCollectionEquality().equals(other._episodes, _episodes)&&const DeepCollectionEquality().equals(other._distilled, _distilled)&&const DeepCollectionEquality().equals(other._keeperNotes, _keeperNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,lastEpisodeId,const DeepCollectionEquality().hash(_episodes),const DeepCollectionEquality().hash(_distilled),const DeepCollectionEquality().hash(_keeperNotes));

@override
String toString() {
  return 'SaveFile(schemaVersion: $schemaVersion, lastEpisodeId: $lastEpisodeId, episodes: $episodes, distilled: $distilled, keeperNotes: $keeperNotes)';
}


}

/// @nodoc
abstract mixin class _$SaveFileCopyWith<$Res> implements $SaveFileCopyWith<$Res> {
  factory _$SaveFileCopyWith(_SaveFile value, $Res Function(_SaveFile) _then) = __$SaveFileCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String? lastEpisodeId, Map<String, GameState> episodes, Set<String> distilled, Map<String, String> keeperNotes
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
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? lastEpisodeId = freezed,Object? episodes = null,Object? distilled = null,Object? keeperNotes = null,}) {
  return _then(_SaveFile(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,lastEpisodeId: freezed == lastEpisodeId ? _self.lastEpisodeId : lastEpisodeId // ignore: cast_nullable_to_non_nullable
as String?,episodes: null == episodes ? _self._episodes : episodes // ignore: cast_nullable_to_non_nullable
as Map<String, GameState>,distilled: null == distilled ? _self._distilled : distilled // ignore: cast_nullable_to_non_nullable
as Set<String>,keeperNotes: null == keeperNotes ? _self._keeperNotes : keeperNotes // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
