// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Settings {

/// 0–1.
 double get musicVolume;/// 0–1.
 double get sfxVolume;/// UI and content language, e.g. `id`. `null` follows the device.
 String? get languageCode; bool get vibration;/// Shows the frame-rate readout (for checking performance).
 bool get showFps;
/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsCopyWith<Settings> get copyWith => _$SettingsCopyWithImpl<Settings>(this as Settings, _$identity);

  /// Serializes this Settings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Settings&&(identical(other.musicVolume, musicVolume) || other.musicVolume == musicVolume)&&(identical(other.sfxVolume, sfxVolume) || other.sfxVolume == sfxVolume)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.vibration, vibration) || other.vibration == vibration)&&(identical(other.showFps, showFps) || other.showFps == showFps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,musicVolume,sfxVolume,languageCode,vibration,showFps);

@override
String toString() {
  return 'Settings(musicVolume: $musicVolume, sfxVolume: $sfxVolume, languageCode: $languageCode, vibration: $vibration, showFps: $showFps)';
}


}

/// @nodoc
abstract mixin class $SettingsCopyWith<$Res>  {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) _then) = _$SettingsCopyWithImpl;
@useResult
$Res call({
 double musicVolume, double sfxVolume, String? languageCode, bool vibration, bool showFps
});




}
/// @nodoc
class _$SettingsCopyWithImpl<$Res>
    implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._self, this._then);

  final Settings _self;
  final $Res Function(Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? musicVolume = null,Object? sfxVolume = null,Object? languageCode = freezed,Object? vibration = null,Object? showFps = null,}) {
  return _then(_self.copyWith(
musicVolume: null == musicVolume ? _self.musicVolume : musicVolume // ignore: cast_nullable_to_non_nullable
as double,sfxVolume: null == sfxVolume ? _self.sfxVolume : sfxVolume // ignore: cast_nullable_to_non_nullable
as double,languageCode: freezed == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String?,vibration: null == vibration ? _self.vibration : vibration // ignore: cast_nullable_to_non_nullable
as bool,showFps: null == showFps ? _self.showFps : showFps // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Settings].
extension SettingsPatterns on Settings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Settings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Settings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Settings value)  $default,){
final _that = this;
switch (_that) {
case _Settings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Settings value)?  $default,){
final _that = this;
switch (_that) {
case _Settings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double musicVolume,  double sfxVolume,  String? languageCode,  bool vibration,  bool showFps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that.musicVolume,_that.sfxVolume,_that.languageCode,_that.vibration,_that.showFps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double musicVolume,  double sfxVolume,  String? languageCode,  bool vibration,  bool showFps)  $default,) {final _that = this;
switch (_that) {
case _Settings():
return $default(_that.musicVolume,_that.sfxVolume,_that.languageCode,_that.vibration,_that.showFps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double musicVolume,  double sfxVolume,  String? languageCode,  bool vibration,  bool showFps)?  $default,) {final _that = this;
switch (_that) {
case _Settings() when $default != null:
return $default(_that.musicVolume,_that.sfxVolume,_that.languageCode,_that.vibration,_that.showFps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Settings implements Settings {
  const _Settings({this.musicVolume = 0.8, this.sfxVolume = 1.0, this.languageCode, this.vibration = true, this.showFps = false});
  factory _Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

/// 0–1.
@override@JsonKey() final  double musicVolume;
/// 0–1.
@override@JsonKey() final  double sfxVolume;
/// UI and content language, e.g. `id`. `null` follows the device.
@override final  String? languageCode;
@override@JsonKey() final  bool vibration;
/// Shows the frame-rate readout (for checking performance).
@override@JsonKey() final  bool showFps;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsCopyWith<_Settings> get copyWith => __$SettingsCopyWithImpl<_Settings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Settings&&(identical(other.musicVolume, musicVolume) || other.musicVolume == musicVolume)&&(identical(other.sfxVolume, sfxVolume) || other.sfxVolume == sfxVolume)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.vibration, vibration) || other.vibration == vibration)&&(identical(other.showFps, showFps) || other.showFps == showFps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,musicVolume,sfxVolume,languageCode,vibration,showFps);

@override
String toString() {
  return 'Settings(musicVolume: $musicVolume, sfxVolume: $sfxVolume, languageCode: $languageCode, vibration: $vibration, showFps: $showFps)';
}


}

/// @nodoc
abstract mixin class _$SettingsCopyWith<$Res> implements $SettingsCopyWith<$Res> {
  factory _$SettingsCopyWith(_Settings value, $Res Function(_Settings) _then) = __$SettingsCopyWithImpl;
@override @useResult
$Res call({
 double musicVolume, double sfxVolume, String? languageCode, bool vibration, bool showFps
});




}
/// @nodoc
class __$SettingsCopyWithImpl<$Res>
    implements _$SettingsCopyWith<$Res> {
  __$SettingsCopyWithImpl(this._self, this._then);

  final _Settings _self;
  final $Res Function(_Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? musicVolume = null,Object? sfxVolume = null,Object? languageCode = freezed,Object? vibration = null,Object? showFps = null,}) {
  return _then(_Settings(
musicVolume: null == musicVolume ? _self.musicVolume : musicVolume // ignore: cast_nullable_to_non_nullable
as double,sfxVolume: null == sfxVolume ? _self.sfxVolume : sfxVolume // ignore: cast_nullable_to_non_nullable
as double,languageCode: freezed == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String?,vibration: null == vibration ? _self.vibration : vibration // ignore: cast_nullable_to_non_nullable
as bool,showFps: null == showFps ? _self.showFps : showFps // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
