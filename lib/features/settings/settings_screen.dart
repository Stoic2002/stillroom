import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/stillroom_palette.dart';
import '../../core/widgets/atmosphere.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/save_repository.dart';
import '../../state/settings_controller.dart';

/// Settings (PRD FR-11): volumes, language, vibration, reset progress.
/// Every change applies and saves immediately; language switches without a
/// restart.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuSettings)),
      body: Atmosphere(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _VolumeSlider(
                    label: l10n.settingsMusicVolume,
                    value: settings.musicVolume,
                    onChanged: controller.setMusicVolume,
                  ),
                  _VolumeSlider(
                    label: l10n.settingsSfxVolume,
                    value: settings.sfxVolume,
                    onChanged: controller.setSfxVolume,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.settingsLanguage),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (code, label) in [
                        (null, l10n.languageDevice),
                        ('en', l10n.languageEnglish),
                        ('id', l10n.languageIndonesian),
                        ('es', l10n.languageSpanish),
                        ('ja', l10n.languageJapanese),
                        ('zh', l10n.languageChinese),
                        ('ru', l10n.languageRussian),
                        ('ko', l10n.languageKorean),
                      ])
                        ChoiceChip(
                          label: Text(label),
                          selected: settings.languageCode == code,
                          showCheckmark: false,
                          selectedColor: StillroomPalette.walnut,
                          side: const BorderSide(
                            color: StillroomPalette.walnutLight,
                          ),
                          labelStyle: TextStyle(
                            color: settings.languageCode == code
                                ? StillroomPalette.gaslight
                                : StillroomPalette.paperShade,
                          ),
                          onSelected: (_) => controller.setLanguage(code),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.settingsVibration),
                    value: settings.vibration,
                    onChanged: (enabled) =>
                        controller.setVibration(enabled: enabled),
                  ),
                  const Divider(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.settingsResetProgress),
                      onPressed: () => _resetProgress(context, ref),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetProgress(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.resetConfirmTitle,
      body: l10n.resetConfirmBody,
      confirmLabel: l10n.actionReset,
      cancelLabel: l10n.actionCancel,
    );
    if (!confirmed) return;
    ref.read(saveRepositoryProvider.notifier).clearAll();
    messenger.showSnackBar(SnackBar(content: Text(l10n.progressResetDone)));
  }
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(label)),
        Expanded(
          flex: 3,
          child: Slider(
            value: value,
            divisions: 10,
            label: '${(value * 100).round()}%',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
