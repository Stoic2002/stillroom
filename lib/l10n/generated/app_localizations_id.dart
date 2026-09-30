// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Stillroom';

  @override
  String get menuContinue => 'Lanjutkan';

  @override
  String get menuNewGame => 'Mulai Baru';

  @override
  String get menuSettings => 'Pengaturan';

  @override
  String get navLeft => 'Putar ke kiri';

  @override
  String get navRight => 'Putar ke kanan';

  @override
  String get navBack => 'Mundur';

  @override
  String get contentLoadError => 'Konten game gagal dimuat.';

  @override
  String get backToMenu => 'Kembali ke menu';

  @override
  String get examineItem => 'Periksa';

  @override
  String get closeExamine => 'Tutup';

  @override
  String get inventoryLabel => 'Inventori';

  @override
  String get closePuzzle => 'Tutup';

  @override
  String get dialNext => 'Simbol berikutnya';

  @override
  String get dialPrevious => 'Simbol sebelumnya';

  @override
  String get newGameConfirmTitle => 'Mulai permainan baru?';

  @override
  String get newGameConfirmBody => 'Progres kamu di episode ini akan hilang.';

  @override
  String get actionCancel => 'Batal';

  @override
  String get actionStartOver => 'Mulai ulang';

  @override
  String get saveCorruptedTitle => 'Data simpanan tidak bisa dibaca';

  @override
  String get saveCorruptedBody =>
      'Progres yang tersimpan rusak dan tidak bisa dilanjutkan. Kamu bisa memulai permainan baru.';

  @override
  String get settingsMusicVolume => 'Volume musik';

  @override
  String get settingsSfxVolume => 'Volume efek suara';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get languageDevice => 'Ikuti perangkat';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get settingsVibration => 'Getaran';

  @override
  String get settingsResetProgress => 'Reset progres';

  @override
  String get resetConfirmTitle => 'Reset semua progres?';

  @override
  String get resetConfirmBody =>
      'Semua progres tersimpan akan dihapus. Pengaturan kamu tetap tersimpan.';

  @override
  String get actionReset => 'Reset';

  @override
  String get progressResetDone => 'Progres sudah direset.';

  @override
  String get episodeComplete => 'Kisah ini telah tersuling';

  @override
  String get hintButton => 'Petunjuk';

  @override
  String get hintTitle => 'Petunjuk';

  @override
  String get hintRevealNext => 'Tampilkan petunjuk';

  @override
  String get hintNoneAvailable => 'Belum ada petunjuk untuk saat ini.';

  @override
  String get hintAllShown => 'Semua petunjuk sudah ditampilkan.';

  @override
  String get actionClose => 'Tutup';

  @override
  String get menuTagline =>
      'Setiap toples menyimpan satu kisah yang tak boleh dilupakan.';

  @override
  String get shelfTitle => 'Rak';

  @override
  String get shelfHint => 'Pilih toples untuk membuka kisahnya.';

  @override
  String get jarSealed => 'Masih tersegel';

  @override
  String get jarDistilled => 'Tersuling';

  @override
  String get jarUnfinished => 'Kisah ini belum kamu selesaikan.';

  @override
  String get actionContinue => 'Lanjutkan';

  @override
  String get actionOpenJar => 'Buka toples';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get jarLockedTitle => 'Belum saatnya';

  @override
  String jarLocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Suling $count kisah lagi untuk membuka toples ini.',
    );
    return '$_temp0';
  }

  @override
  String get languageKorean => '한국어';

  @override
  String get hintKindling =>
      'Lilin untuk petunjuk berikutnya masih menyala perlahan. Coba cari lagi sebentar.';

  @override
  String get keeperNoteTitle => 'Catatan penjaga';

  @override
  String get keeperNoteFound => 'Kamu menemukan salah satu catatan penjaga.';

  @override
  String wordNoted(String word) {
    return 'Dicatat: $word';
  }

  @override
  String get deductionInstruction =>
      'Tulis label toples: ketuk bagian kosong, lalu kata yang sudah kamu catat.';

  @override
  String get deductionCheck => 'Suling';

  @override
  String get deductionIncomplete => 'Masih ada bagian yang kosong.';

  @override
  String deductionNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count di antaranya belum tepat.',
    );
    return '$_temp0';
  }

  @override
  String get deductionWrong => 'Ada yang belum tepat di sini.';

  @override
  String get deductionNoWords =>
      'Kamu belum mencatat kata apa pun. Ketuk kata bergaris bawah pada teks yang kamu baca.';

  @override
  String get revealWipe => 'Usap dengan jarimu.';

  @override
  String get revealRub => 'Arsir dengan pensil: gosok dengan jarimu.';

  @override
  String get wordTapTip => 'Ketuk kata bergaris bawah untuk mencatatnya.';

  @override
  String get crankInstruction => 'Putar engkolnya terus-menerus.';

  @override
  String get mapTitle => 'Peta kisah';

  @override
  String get mapHint =>
      'Setiap pin adalah sebuah kisah. Cubit untuk memperbesar.';

  @override
  String get settingsShowFps => 'Tampilkan frame rate (FPS)';

  @override
  String get lensRaise => 'Angkat lensa';

  @override
  String get lensLower => 'Turunkan lensa';

  @override
  String get overlayInstruction => 'Geser kepingannya. Ketuk untuk memutarnya.';

  @override
  String get deductionCorrectionInstruction =>
      'Sebagian kata ini salah. Ketuk satu, lalu kata yang seharusnya. \"Suling\" memeriksanya.';

  @override
  String get telegramHeader => 'TELEGRAM';

  @override
  String get telegramStop => 'STOP';

  @override
  String get clockHandsInstruction =>
      'Geser jarum-jarumnya mengelilingi piringan jam.';

  @override
  String get threadInstruction => 'Tarik benangnya dari paku ke paku.';

  @override
  String get rakingLightInstruction =>
      'Gerakkan pelita mengelilingi lempeng, rendah dan dekat.';

  @override
  String get beamSweepInstruction =>
      'Perhatikan sinarnya. Ketuk apa yang tampak selagi disinari.';

  @override
  String get beamSweepMiss => 'Terlalu gelap di situ. Tunggu sinarnya.';

  @override
  String get swellInstruction =>
      'Ketuk untuk turun satu anak tangga. Perhatikan lautnya, dan dengarkan.';

  @override
  String get swellCaught => 'Laut mendorongmu naik lagi ke atas tangga.';

  @override
  String get rosterInstruction => 'Ketuk kotak untuk mengubahnya.';

  @override
  String rosterWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baris belum cocok dengan temuanmu.',
    );
    return '$_temp0';
  }

  @override
  String get orderHeader => 'De par le Roy';

  @override
  String get orderSubheader => 'Atas perintah Raja';

  @override
  String get keyringInstruction => 'Ambil satu kunci dari gelangnya.';

  @override
  String get keyringHand =>
      'Ketuk kuncinya untuk membaliknya; ketuk gemboknya untuk mencobanya.';

  @override
  String get keyringWrong => 'Kuncinya tak mau berputar.';

  @override
  String get cipherInstruction =>
      'Ketuk sebuah angka di surat, lalu angka yang sama di lembar kerja.';

  @override
  String get sourcesInstruction =>
      'Ketuk selembar kertas, lalu baki tempatnya.';

  @override
  String sourcesWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lembar ada di baki yang salah.',
    );
    return '$_temp0';
  }

  @override
  String get rubbingCaption => 'Cetakan tinta dari perunggu';

  @override
  String get pourInstruction => 'Putar saluran-salurannya, lalu buka tungku.';

  @override
  String get pourButton => 'Tuang';

  @override
  String get pourSpilt => 'Perunggu tumpah ke pasir. Tungku ditutup lagi.';

  @override
  String get pourShort =>
      'Tidak ada yang tumpah, tapi satu mangkuk tetap kosong.';

  @override
  String get resonanceInstruction =>
      'Tarik pemukul ke belakang lalu lepaskan. Gali atau timbun lubang di bawahnya.';

  @override
  String get resonanceDeeper => 'Lebih dalam';

  @override
  String get resonanceShallower => 'Lebih dangkal';

  @override
  String get resonanceWeak =>
      'Terlalu pelan: kayunya hampir tidak menyentuh perunggu.';

  @override
  String get resonanceShort => 'Gaungnya padam sebelum tanda.';

  @override
  String get beatInstruction =>
      'Pukul bibir lonceng. Cari tempat gaungnya naik-turun paling dalam, lalu tandai.';

  @override
  String get beatMark => 'Tandai tempat ini';

  @override
  String get beatWrong => 'Bukan di sini: ada tempat yang lebih dalam.';

  @override
  String get docketHeader => 'Kepolisian Metropolitan';

  @override
  String get docketSubheader => 'Departemen Investigasi Kriminal';

  @override
  String get unwatchedInstruction => 'Berpalinglah, lalu lihat lagi.';

  @override
  String get unwatchedFind => 'Ada yang baru di rak. Temukan.';

  @override
  String get unwatchedWrong => 'Yang itu sudah ada dari tadi.';

  @override
  String get unwatchedLookAway => 'Berpaling';

  @override
  String unwatchedProgress(int found, int total) {
    return 'Berkas baru ditemukan: $found dari $total';
  }

  @override
  String get composeInstruction =>
      'Susun namanya dari kotak huruf. Huruf cetak dipahat terbalik seperti cermin.';

  @override
  String get composeTakeOut => 'Ambil';

  @override
  String get composeWrong => 'Cetakan percobaannya salah di suatu tempat.';
}
