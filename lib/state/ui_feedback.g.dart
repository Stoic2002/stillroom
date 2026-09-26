// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_feedback.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Plays [UiSound]s at the effects volume, with their vibration when the
/// player has vibration on.

@ProviderFor(uiFeedback)
final uiFeedbackProvider = UiFeedbackProvider._();

/// Plays [UiSound]s at the effects volume, with their vibration when the
/// player has vibration on.

final class UiFeedbackProvider
    extends $FunctionalProvider<UiFeedback, UiFeedback, UiFeedback>
    with $Provider<UiFeedback> {
  /// Plays [UiSound]s at the effects volume, with their vibration when the
  /// player has vibration on.
  UiFeedbackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uiFeedbackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uiFeedbackHash();

  @$internal
  @override
  $ProviderElement<UiFeedback> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UiFeedback create(Ref ref) {
    return uiFeedback(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UiFeedback value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UiFeedback>(value),
    );
  }
}

String _$uiFeedbackHash() => r'21914d48c4b1398e942e1a12068df1fa5c49383a';
