// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Stillroom';

  @override
  String get menuContinue => 'Continuar';

  @override
  String get menuNewGame => 'Nueva partida';

  @override
  String get menuSettings => 'Ajustes';

  @override
  String get navLeft => 'Girar a la izquierda';

  @override
  String get navRight => 'Girar a la derecha';

  @override
  String get navBack => 'Retroceder';

  @override
  String get contentLoadError => 'No se pudo cargar el contenido del juego.';

  @override
  String get backToMenu => 'Volver al menú';

  @override
  String get examineItem => 'Examinar';

  @override
  String get closeExamine => 'Cerrar';

  @override
  String get inventoryLabel => 'Inventario';

  @override
  String get closePuzzle => 'Cerrar';

  @override
  String get dialNext => 'Símbolo siguiente';

  @override
  String get dialPrevious => 'Símbolo anterior';

  @override
  String get newGameConfirmTitle => '¿Empezar una nueva partida?';

  @override
  String get newGameConfirmBody =>
      'Perderás tu progreso actual en este episodio.';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionStartOver => 'Empezar de nuevo';

  @override
  String get saveCorruptedTitle => 'No se puede leer la partida guardada';

  @override
  String get saveCorruptedBody =>
      'Tu progreso guardado está dañado y no se puede continuar. Puedes empezar una nueva partida.';

  @override
  String get settingsMusicVolume => 'Volumen de la música';

  @override
  String get settingsSfxVolume => 'Volumen de los efectos';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageDevice => 'Idioma del dispositivo';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get settingsVibration => 'Vibración';

  @override
  String get settingsResetProgress => 'Borrar progreso';

  @override
  String get resetConfirmTitle => '¿Borrar todo el progreso?';

  @override
  String get resetConfirmBody =>
      'Se borrará todo el progreso guardado. Tus ajustes se conservan.';

  @override
  String get actionReset => 'Borrar';

  @override
  String get progressResetDone => 'Se ha borrado el progreso.';

  @override
  String get episodeComplete => 'El relato ha sido destilado';

  @override
  String get hintButton => 'Pista';

  @override
  String get hintTitle => 'Pistas';

  @override
  String get hintRevealNext => 'Mostrar una pista';

  @override
  String get hintNoneAvailable => 'No hay pistas por ahora.';

  @override
  String get hintAllShown => 'Esas son todas las pistas por ahora.';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get menuTagline =>
      'Cada frasco guarda un relato que no debe olvidarse.';

  @override
  String get shelfTitle => 'La estantería';

  @override
  String get shelfHint => 'Elige un frasco para abrir su relato.';

  @override
  String get jarSealed => 'Aún sellado';

  @override
  String get jarDistilled => 'Destilado';

  @override
  String get jarUnfinished => 'Dejaste este relato sin terminar.';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionOpenJar => 'Abrir el frasco';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get jarLockedTitle => 'Todavía no';

  @override
  String jarLocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Destila $count relatos más para abrir este frasco.',
      one: 'Destila un relato más para abrir este frasco.',
    );
    return '$_temp0';
  }

  @override
  String get languageKorean => '한국어';

  @override
  String get hintKindling =>
      'La vela de la siguiente pista aún está prendiendo. Sigue buscando un poco más.';

  @override
  String get keeperNoteTitle => 'La nota del guardián';

  @override
  String get keeperNoteFound => 'Has encontrado una de las notas del guardián.';

  @override
  String wordNoted(String word) {
    return 'Anotado: $word';
  }

  @override
  String get deductionInstruction =>
      'Escribe la etiqueta del frasco: toca un hueco y luego una palabra que hayas anotado.';

  @override
  String get deductionCheck => 'Destilar';

  @override
  String get deductionIncomplete => 'Aún quedan huecos vacíos.';

  @override
  String deductionNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count todavía no son correctas.',
      one: 'Una todavía no es correcta.',
    );
    return '$_temp0';
  }

  @override
  String get deductionWrong => 'Algo aquí no está bien.';

  @override
  String get deductionNoWords =>
      'Aún no has anotado ninguna palabra. Toca las palabras subrayadas en lo que leas.';

  @override
  String get revealWipe => 'Límpialo con el dedo.';

  @override
  String get revealRub => 'Sombréalo con el lápiz: frota con el dedo.';

  @override
  String get wordTapTip => 'Toca una palabra subrayada para anotarla.';

  @override
  String get crankInstruction => 'Gira la manivela, vuelta tras vuelta.';

  @override
  String get mapTitle => 'El mapa de las historias';

  @override
  String get mapHint =>
      'Cada alfiler es una historia. Pellizca para acercarte.';

  @override
  String get settingsShowFps => 'Mostrar fotogramas por segundo (FPS)';

  @override
  String get lensRaise => 'Alzar la lente';

  @override
  String get lensLower => 'Bajar la lente';

  @override
  String get overlayInstruction => 'Arrastra las hojas. Toca una para girarla.';

  @override
  String get deductionCorrectionInstruction =>
      'Algunas de estas palabras están mal. Toca una y luego la palabra que va ahí. «Destilar» lo comprueba.';

  @override
  String get telegramHeader => 'TELEGRAMA';

  @override
  String get telegramStop => 'STOP';

  @override
  String get clockHandsInstruction =>
      'Arrastra las agujas alrededor de la esfera.';

  @override
  String get threadInstruction => 'Tiende el hilo de alfiler en alfiler.';
}
