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
  String get overlayInstruction =>
      'Arrastra las piezas. Toca una para girarla.';

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

  @override
  String get rakingLightInstruction =>
      'Mueve la lucerna alrededor de la tablilla, cerca y baja.';

  @override
  String get beamSweepInstruction =>
      'Mira el haz. Toca lo que muestra mientras esté iluminado.';

  @override
  String get beamSweepMiss => 'Ahí está demasiado oscuro. Espera al haz.';

  @override
  String get swellInstruction =>
      'Toca para bajar un escalón. Mira el mar y escucha.';

  @override
  String get swellCaught => 'El mar te hace subir de nuevo los escalones.';

  @override
  String get rosterInstruction => 'Toca una casilla para cambiarla.';

  @override
  String rosterWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filas no cuadran con lo que encontraste.',
      one: 'Una fila no cuadra con lo que encontraste.',
    );
    return '$_temp0';
  }

  @override
  String get orderHeader => 'De par le Roy';

  @override
  String get orderSubheader => 'Por orden del Rey';

  @override
  String get keyringInstruction => 'Saca una llave de la argolla.';

  @override
  String get keyringHand =>
      'Toca la llave para darle la vuelta; toca la cerradura para probarla.';

  @override
  String get keyringWrong => 'No gira.';

  @override
  String get cipherInstruction =>
      'Toca un número de la carta y luego el mismo número en la hoja de trabajo.';

  @override
  String get sourcesInstruction =>
      'Toca un papel y luego la bandeja a la que pertenece.';

  @override
  String sourcesWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count papeles están en la bandeja equivocada.',
      one: 'Un papel está en la bandeja equivocada.',
    );
    return '$_temp0';
  }

  @override
  String get rubbingCaption => 'Un calco del bronce';

  @override
  String get pourInstruction => 'Gira los canales y luego abre los hornos.';

  @override
  String get pourButton => 'Verter';

  @override
  String get pourSpilt =>
      'El bronce se derrama en la arena. Los hornos se cierran de nuevo.';

  @override
  String get pourShort => 'No se derramó nada, pero una copa quedó vacía.';

  @override
  String get resonanceInstruction =>
      'Tira del badajo hacia atrás y suéltalo. Cava o rellena el hueco de abajo.';

  @override
  String get resonanceDeeper => 'Más hondo';

  @override
  String get resonanceShallower => 'Menos hondo';

  @override
  String get resonanceWeak =>
      'Demasiado suave: el tronco apenas roza el bronce.';

  @override
  String get resonanceShort => 'El tañido se apaga antes de la marca.';

  @override
  String get beatInstruction =>
      'Golpea el borde. Busca dónde el tañido crece y mengua más hondo, y márcalo.';

  @override
  String get beatMark => 'Marcar este lugar';

  @override
  String get beatWrong => 'Aquí no: en otro sitio crece más hondo.';

  @override
  String get docketHeader => 'Policía Metropolitana';

  @override
  String get docketSubheader => 'Departamento de Investigación Criminal';

  @override
  String get unwatchedInstruction => 'Aparta la vista y vuelve a mirar.';

  @override
  String get unwatchedFind => 'Hay algo nuevo en el estante. Encuéntralo.';

  @override
  String get unwatchedWrong => 'Ese ya estaba ahí.';

  @override
  String get unwatchedLookAway => 'Apartar la vista';

  @override
  String unwatchedProgress(int found, int total) {
    return 'Expedientes nuevos: $found de $total';
  }

  @override
  String get composeInstruction =>
      'Compón su nombre con la caja de tipos. Los tipos están tallados en espejo.';

  @override
  String get composeTakeOut => 'Sacar';

  @override
  String get composeWrong => 'La prueba sale mal en algún sitio.';

  @override
  String get strandInstruction =>
      'Toca un segmento para medirlo. Encuentra la lectura más alta de cada mechón y márcala.';

  @override
  String strandBudget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count lecturas',
      one: 'Queda 1 lectura',
      zero: 'No quedan lecturas',
    );
    return '$_temp0';
  }

  @override
  String get strandMark => 'Marcar como la más alta';

  @override
  String get strandWrong =>
      'No es la más alta. Un segmento vecino puede dar más.';

  @override
  String get strandNewSample => 'Nueva muestra';

  @override
  String get strandOut =>
      'No queda tiempo de reactor para esta muestra. Toma una nueva.';

  @override
  String get strandCurveQuestion =>
      '¿Cómo se reparte el arsénico a lo largo del cabello?';

  @override
  String get strandSteady => 'Constante, durante años';

  @override
  String get strandPeak => 'Picos agudos';

  @override
  String get strandCurveWrong =>
      'Mira otra vez las lecturas en torno a la más alta.';

  @override
  String get scanInstruction =>
      'Arrastra la sonda sobre la túnica. Marca donde la aguja entra en el rojo.';

  @override
  String get scanMark => 'Marcar aquí';

  @override
  String get scanWrong => 'Aquí la aguja apenas se mueve.';

  @override
  String get scanFaint =>
      'La aguja se mueve, pero no llega al rojo. ¿Demasiado débil a través de esta tela?';

  @override
  String get scanAgain => 'Ya está marcado.';

  @override
  String scanFound(String place) {
    return 'Marcado: $place';
  }

  @override
  String scanProgress(int found, int total) {
    return 'Lugares marcados: $found de $total';
  }

  @override
  String get vermilionCaption => 'En bermellón';

  @override
  String get quireInstruction =>
      'Toca un pliego y luego otro para intercambiar su sitio en el cuadernillo. Da la vuelta a un pliego para intercambiar sus hojas. Cada reclamo debe encontrar su página.';

  @override
  String get quireTurn => 'Dar la vuelta';

  @override
  String quireLinks(int count, int total) {
    return '$count de $total reclamos encuentran su página';
  }

  @override
  String get quirePicked =>
      'Toca otro pliego para intercambiarlos, o da la vuelta a este.';

  @override
  String get dipInstruction =>
      'Baja la caña a un depósito hasta que toque la superficie; luego suéltala y mira cómo gotea.';

  @override
  String get dipWhat => '¿Qué gotea de la caña?';

  @override
  String get dipWrong => 'No gotea así.';

  @override
  String dipLevel(int percent) {
    return 'Lleno al $percent %';
  }

  @override
  String get dipStoresQuestion =>
      'Todos los depósitos tienen nombre. ¿Las provisiones escaseaban o estaban llenas?';

  @override
  String get dipLow => 'Escaseaban';

  @override
  String get dipFull => 'Llenas';

  @override
  String get dipStoresWrong =>
      'Vuelve a mirar hasta dónde llega cada depósito.';

  @override
  String get colophonCaption => 'Aquí termina el libro';

  @override
  String get coursesInstruction =>
      'Vuelve a colocar los bloques caídos, hilada a hilada desde la izquierda. Ningún bloque puede acabar sobre una junta de la hilada de abajo.';

  @override
  String coursesCourse(int course, int total) {
    return 'Hilada $course de $total';
  }

  @override
  String get coursesTooLong => 'Demasiado largo: se saldría del hueco.';

  @override
  String get coursesJoint => 'Junta sobre junta: el muro se partiría ahí.';

  @override
  String get coursesTakeBack => 'Retirar';

  @override
  String get coursesBand =>
      'La banda de chevrones: toca una losa para inclinarla al otro lado, hasta que se inclinen por turnos.';

  @override
  String get identifyInstruction => 'Mira la astilla. ¿Qué es cierto de ella?';

  @override
  String identifyWrong(String name) {
    return 'La clave termina en: $name';
  }

  @override
  String get identifyBack => 'Vuelve a donde el camino se torció.';

  @override
  String get cartoucheCaption => 'Nuevo mapa del interior';
}
