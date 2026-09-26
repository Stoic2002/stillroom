// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single save slot (PRD FR-09): loaded once at start-up, written on
/// every meaningful change. Writes are queued so they land in order.

@ProviderFor(SaveRepository)
final saveRepositoryProvider = SaveRepositoryProvider._();

/// The single save slot (PRD FR-09): loaded once at start-up, written on
/// every meaningful change. Writes are queued so they land in order.
final class SaveRepositoryProvider
    extends $NotifierProvider<SaveRepository, SaveSnapshot> {
  /// The single save slot (PRD FR-09): loaded once at start-up, written on
  /// every meaningful change. Writes are queued so they land in order.
  SaveRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveRepositoryHash();

  @$internal
  @override
  SaveRepository create() => SaveRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveSnapshot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveSnapshot>(value),
    );
  }
}

String _$saveRepositoryHash() => r'0a3a0a696a3002d2978de1121ad9aed1076a25ab';

/// The single save slot (PRD FR-09): loaded once at start-up, written on
/// every meaningful change. Writes are queued so they land in order.

abstract class _$SaveRepository extends $Notifier<SaveSnapshot> {
  SaveSnapshot build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SaveSnapshot, SaveSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaveSnapshot, SaveSnapshot>,
              SaveSnapshot,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
