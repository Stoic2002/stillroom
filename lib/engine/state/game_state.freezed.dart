// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameState {

 String get episodeId; String get sceneId;/// Items currently held, in pickup order. Never contains duplicates.
 List<String> get inventory;/// Every item that has ever been picked up, including ones since removed
/// or combined. Lets content hide a pickup spot for good.
 Set<String> get everHadItems;/// Current value of every declared flag. Values are `bool` or `int`.
 Map<String, Object> get flags; Set<String> get solvedPuzzles;/// How many hints the player has revealed per hint group
/// ([HintGroup.key]).
 Map<String, int> get revealedHints; bool get completed;
/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameStateCopyWith<GameState> get copyWith => _$GameStateCopyWithImpl<GameState>(this as GameState, _$identity);

  /// Serializes this GameState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameState&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&const DeepCollectionEquality().equals(other.inventory, inventory)&&const DeepCollectionEquality().equals(other.everHadItems, everHadItems)&&const DeepCollectionEquality().equals(other.flags, flags)&&const DeepCollectionEquality().equals(other.solvedPuzzles, solvedPuzzles)&&const DeepCollectionEquality().equals(other.revealedHints, revealedHints)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,episodeId,sceneId,const DeepCollectionEquality().hash(inventory),const DeepCollectionEquality().hash(everHadItems),const DeepCollectionEquality().hash(flags),const DeepCollectionEquality().hash(solvedPuzzles),const DeepCollectionEquality().hash(revealedHints),completed);

@override
String toString() {
  return 'GameState(episodeId: $episodeId, sceneId: $sceneId, inventory: $inventory, everHadItems: $everHadItems, flags: $flags, solvedPuzzles: $solvedPuzzles, revealedHints: $revealedHints, completed: $completed)';
}


}

/// @nodoc
abstract mixin class $GameStateCopyWith<$Res>  {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) _then) = _$GameStateCopyWithImpl;
@useResult
$Res call({
 String episodeId, String sceneId, List<String> inventory, Set<String> everHadItems, Map<String, Object> flags, Set<String> solvedPuzzles, Map<String, int> revealedHints, bool completed
});




}
/// @nodoc
class _$GameStateCopyWithImpl<$Res>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._self, this._then);

  final GameState _self;
  final $Res Function(GameState) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? episodeId = null,Object? sceneId = null,Object? inventory = null,Object? everHadItems = null,Object? flags = null,Object? solvedPuzzles = null,Object? revealedHints = null,Object? completed = null,}) {
  return _then(_self.copyWith(
episodeId: null == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as String,sceneId: null == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as String,inventory: null == inventory ? _self.inventory : inventory // ignore: cast_nullable_to_non_nullable
as List<String>,everHadItems: null == everHadItems ? _self.everHadItems : everHadItems // ignore: cast_nullable_to_non_nullable
as Set<String>,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as Map<String, Object>,solvedPuzzles: null == solvedPuzzles ? _self.solvedPuzzles : solvedPuzzles // ignore: cast_nullable_to_non_nullable
as Set<String>,revealedHints: null == revealedHints ? _self.revealedHints : revealedHints // ignore: cast_nullable_to_non_nullable
as Map<String, int>,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GameState].
extension GameStatePatterns on GameState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameState value)  $default,){
final _that = this;
switch (_that) {
case _GameState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameState value)?  $default,){
final _that = this;
switch (_that) {
case _GameState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String episodeId,  String sceneId,  List<String> inventory,  Set<String> everHadItems,  Map<String, Object> flags,  Set<String> solvedPuzzles,  Map<String, int> revealedHints,  bool completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that.episodeId,_that.sceneId,_that.inventory,_that.everHadItems,_that.flags,_that.solvedPuzzles,_that.revealedHints,_that.completed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String episodeId,  String sceneId,  List<String> inventory,  Set<String> everHadItems,  Map<String, Object> flags,  Set<String> solvedPuzzles,  Map<String, int> revealedHints,  bool completed)  $default,) {final _that = this;
switch (_that) {
case _GameState():
return $default(_that.episodeId,_that.sceneId,_that.inventory,_that.everHadItems,_that.flags,_that.solvedPuzzles,_that.revealedHints,_that.completed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String episodeId,  String sceneId,  List<String> inventory,  Set<String> everHadItems,  Map<String, Object> flags,  Set<String> solvedPuzzles,  Map<String, int> revealedHints,  bool completed)?  $default,) {final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that.episodeId,_that.sceneId,_that.inventory,_that.everHadItems,_that.flags,_that.solvedPuzzles,_that.revealedHints,_that.completed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameState extends GameState {
  const _GameState({required this.episodeId, required this.sceneId, final  List<String> inventory = const <String>[], final  Set<String> everHadItems = const <String>{}, final  Map<String, Object> flags = const <String, Object>{}, final  Set<String> solvedPuzzles = const <String>{}, final  Map<String, int> revealedHints = const <String, int>{}, this.completed = false}): _inventory = inventory,_everHadItems = everHadItems,_flags = flags,_solvedPuzzles = solvedPuzzles,_revealedHints = revealedHints,super._();
  factory _GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);

@override final  String episodeId;
@override final  String sceneId;
/// Items currently held, in pickup order. Never contains duplicates.
 final  List<String> _inventory;
/// Items currently held, in pickup order. Never contains duplicates.
@override@JsonKey() List<String> get inventory {
  if (_inventory is EqualUnmodifiableListView) return _inventory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inventory);
}

/// Every item that has ever been picked up, including ones since removed
/// or combined. Lets content hide a pickup spot for good.
 final  Set<String> _everHadItems;
/// Every item that has ever been picked up, including ones since removed
/// or combined. Lets content hide a pickup spot for good.
@override@JsonKey() Set<String> get everHadItems {
  if (_everHadItems is EqualUnmodifiableSetView) return _everHadItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_everHadItems);
}

/// Current value of every declared flag. Values are `bool` or `int`.
 final  Map<String, Object> _flags;
/// Current value of every declared flag. Values are `bool` or `int`.
@override@JsonKey() Map<String, Object> get flags {
  if (_flags is EqualUnmodifiableMapView) return _flags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_flags);
}

 final  Set<String> _solvedPuzzles;
@override@JsonKey() Set<String> get solvedPuzzles {
  if (_solvedPuzzles is EqualUnmodifiableSetView) return _solvedPuzzles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_solvedPuzzles);
}

/// How many hints the player has revealed per hint group
/// ([HintGroup.key]).
 final  Map<String, int> _revealedHints;
/// How many hints the player has revealed per hint group
/// ([HintGroup.key]).
@override@JsonKey() Map<String, int> get revealedHints {
  if (_revealedHints is EqualUnmodifiableMapView) return _revealedHints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_revealedHints);
}

@override@JsonKey() final  bool completed;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameStateCopyWith<_GameState> get copyWith => __$GameStateCopyWithImpl<_GameState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameState&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&const DeepCollectionEquality().equals(other._inventory, _inventory)&&const DeepCollectionEquality().equals(other._everHadItems, _everHadItems)&&const DeepCollectionEquality().equals(other._flags, _flags)&&const DeepCollectionEquality().equals(other._solvedPuzzles, _solvedPuzzles)&&const DeepCollectionEquality().equals(other._revealedHints, _revealedHints)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,episodeId,sceneId,const DeepCollectionEquality().hash(_inventory),const DeepCollectionEquality().hash(_everHadItems),const DeepCollectionEquality().hash(_flags),const DeepCollectionEquality().hash(_solvedPuzzles),const DeepCollectionEquality().hash(_revealedHints),completed);

@override
String toString() {
  return 'GameState(episodeId: $episodeId, sceneId: $sceneId, inventory: $inventory, everHadItems: $everHadItems, flags: $flags, solvedPuzzles: $solvedPuzzles, revealedHints: $revealedHints, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$GameStateCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory _$GameStateCopyWith(_GameState value, $Res Function(_GameState) _then) = __$GameStateCopyWithImpl;
@override @useResult
$Res call({
 String episodeId, String sceneId, List<String> inventory, Set<String> everHadItems, Map<String, Object> flags, Set<String> solvedPuzzles, Map<String, int> revealedHints, bool completed
});




}
/// @nodoc
class __$GameStateCopyWithImpl<$Res>
    implements _$GameStateCopyWith<$Res> {
  __$GameStateCopyWithImpl(this._self, this._then);

  final _GameState _self;
  final $Res Function(_GameState) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? episodeId = null,Object? sceneId = null,Object? inventory = null,Object? everHadItems = null,Object? flags = null,Object? solvedPuzzles = null,Object? revealedHints = null,Object? completed = null,}) {
  return _then(_GameState(
episodeId: null == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as String,sceneId: null == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as String,inventory: null == inventory ? _self._inventory : inventory // ignore: cast_nullable_to_non_nullable
as List<String>,everHadItems: null == everHadItems ? _self._everHadItems : everHadItems // ignore: cast_nullable_to_non_nullable
as Set<String>,flags: null == flags ? _self._flags : flags // ignore: cast_nullable_to_non_nullable
as Map<String, Object>,solvedPuzzles: null == solvedPuzzles ? _self._solvedPuzzles : solvedPuzzles // ignore: cast_nullable_to_non_nullable
as Set<String>,revealedHints: null == revealedHints ? _self._revealedHints : revealedHints // ignore: cast_nullable_to_non_nullable
as Map<String, int>,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
