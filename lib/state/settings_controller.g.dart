// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Player settings, persisted on every change. Unreadable stored settings
/// fall back to defaults.

@ProviderFor(SettingsController)
final settingsControllerProvider = SettingsControllerProvider._();

/// Player settings, persisted on every change. Unreadable stored settings
/// fall back to defaults.
final class SettingsControllerProvider
    extends $NotifierProvider<SettingsController, Settings> {
  /// Player settings, persisted on every change. Unreadable stored settings
  /// fall back to defaults.
  SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Settings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Settings>(value),
    );
  }
}

String _$settingsControllerHash() =>
    r'7dedd51e8ddc954248233e24e997d09c2a302d66';

/// Player settings, persisted on every change. Unreadable stored settings
/// fall back to defaults.

abstract class _$SettingsController extends $Notifier<Settings> {
  Settings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Settings, Settings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Settings, Settings>,
              Settings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
