import 'package:flutter/material.dart';

import 'stillroom_palette.dart';

/// Dark, aged look for every Material widget (docs/art_style_guide.md):
/// IM Fell serif type, paper-on-ink colors, square-ish brass-edged controls.
abstract final class AppTheme {
  /// Body and UI text.
  static const serif = 'IMFell';

  /// Small caps for titles and labels.
  static const smallCaps = 'IMFellSC';

  /// Fonts for scripts IM FELL lacks: Cyrillic (Old Standard TT), Japanese,
  /// Chinese and Korean (Noto Serif JP/SC/KR). Han characters and shared
  /// punctuation look different in each language, so the language's own CJK
  /// font comes first.
  static List<String> fallbackFor(String languageCode) => [
    'OldStandard',
    ...switch (languageCode) {
      'ja' => const ['NotoSerifJP', 'NotoSerifSC', 'NotoSerifKR'],
      'ko' => const ['NotoSerifKR', 'NotoSerifSC', 'NotoSerifJP'],
      _ => const ['NotoSerifSC', 'NotoSerifJP', 'NotoSerifKR'],
    },
  ];

  /// [languageCode] picks the fallback fonts ([fallbackFor]).
  static ThemeData dark({String languageCode = 'en'}) {
    final fallback = fallbackFor(languageCode);
    TextStyle style(TextStyle s) => s.copyWith(fontFamilyFallback: fallback);
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: StillroomPalette.gaslight,
      onPrimary: StillroomPalette.ink,
      secondary: StillroomPalette.brass,
      onSecondary: StillroomPalette.ink,
      error: StillroomPalette.oxbloodBright,
      onError: StillroomPalette.paper,
      surface: StillroomPalette.soot,
      onSurface: StillroomPalette.paper,
      onSurfaceVariant: StillroomPalette.faded,
      outline: StillroomPalette.brass,
      outlineVariant: StillroomPalette.walnutLight,
      surfaceContainerHighest: StillroomPalette.walnut,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: serif,
      scaffoldBackgroundColor: StillroomPalette.ink,
      splashFactory: InkRipple.splashFactory,
    );
    final text = base.textTheme.apply(
      bodyColor: StillroomPalette.paper,
      displayColor: StillroomPalette.paper,
      fontFamily: serif,
      fontFamilyFallback: fallback,
    );
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    );
    return base.copyWith(
      textTheme: text.copyWith(
        displayMedium: text.displayMedium?.copyWith(
          fontFamily: smallCaps,
          letterSpacing: 6,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          fontFamily: smallCaps,
          letterSpacing: 3,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontFamily: smallCaps,
          letterSpacing: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: StillroomPalette.paper,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: style(
          const TextStyle(
            fontFamily: smallCaps,
            fontSize: 24,
            letterSpacing: 3,
            color: StillroomPalette.paper,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: StillroomPalette.paper,
          disabledForegroundColor: StillroomPalette.faded.withValues(
            alpha: 0.45,
          ),
          textStyle: style(const TextStyle(fontFamily: serif, fontSize: 20)),
          shape: shape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: StillroomPalette.oxblood,
          foregroundColor: StillroomPalette.paper,
          textStyle: style(const TextStyle(fontFamily: serif, fontSize: 17)),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: StillroomPalette.paper,
          side: const BorderSide(color: StillroomPalette.brass),
          textStyle: style(const TextStyle(fontFamily: serif, fontSize: 17)),
          shape: shape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: StillroomPalette.paper),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: StillroomPalette.soot,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: StillroomPalette.brass, width: 0.8),
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        titleTextStyle: style(
          const TextStyle(
            fontFamily: smallCaps,
            fontSize: 22,
            letterSpacing: 1.5,
            color: StillroomPalette.paper,
          ),
        ),
        contentTextStyle: style(
          const TextStyle(
            fontFamily: serif,
            fontSize: 16,
            height: 1.45,
            color: StillroomPalette.paperShade,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: StillroomPalette.paper,
        contentTextStyle: style(
          const TextStyle(
            fontFamily: serif,
            fontSize: 16,
            color: StillroomPalette.inkOnPaper,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: StillroomPalette.brass,
        inactiveTrackColor: StillroomPalette.walnutLight,
        thumbColor: StillroomPalette.gaslight,
        valueIndicatorColor: StillroomPalette.walnut,
        valueIndicatorTextStyle: style(
          const TextStyle(color: StillroomPalette.paper),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? StillroomPalette.gaslight
              : StillroomPalette.faded,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? StillroomPalette.oxblood
              : StillroomPalette.walnut,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(
          StillroomPalette.walnutLight,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(shape),
          side: const WidgetStatePropertyAll(
            BorderSide(color: StillroomPalette.walnutLight),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? StillroomPalette.walnut
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? StillroomPalette.gaslight
                : StillroomPalette.paperShade,
          ),
          textStyle: WidgetStatePropertyAll(
            style(const TextStyle(fontFamily: serif, fontSize: 15)),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: StillroomPalette.walnutLight),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: StillroomPalette.brass,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(color: StillroomPalette.walnut),
        textStyle: style(
          const TextStyle(fontFamily: serif, color: StillroomPalette.paper),
        ),
      ),
    );
  }
}
