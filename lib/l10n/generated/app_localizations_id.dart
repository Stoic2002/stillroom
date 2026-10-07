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

  @override
  String get strandInstruction =>
      'Ketuk satu ruas untuk mengukurnya. Temukan bacaan tertinggi tiap helai, lalu tandai.';

  @override
  String strandBudget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sisa $count pengukuran',
      zero: 'Tak ada sisa pengukuran',
    );
    return '$_temp0';
  }

  @override
  String get strandMark => 'Tandai tertinggi';

  @override
  String get strandWrong =>
      'Bukan yang tertinggi. Ruas di sebelahnya mungkin lebih tinggi.';

  @override
  String get strandNewSample => 'Sampel baru';

  @override
  String get strandOut =>
      'Waktu reaktor untuk sampel ini habis. Ambil sampel baru.';

  @override
  String get strandCurveQuestion =>
      'Bagaimana sebaran arsenik di sepanjang rambut?';

  @override
  String get strandSteady => 'Merata, bertahun-tahun';

  @override
  String get strandPeak => 'Puncak-puncak tajam';

  @override
  String get strandCurveWrong => 'Lihat lagi bacaan di sekitar yang tertinggi.';

  @override
  String get scanInstruction =>
      'Geser probe di atas jubah. Tandai tempat jarumnya masuk ke merah.';

  @override
  String get scanMark => 'Tandai di sini';

  @override
  String get scanWrong => 'Jarumnya nyaris tak bergerak di sini.';

  @override
  String get scanFaint =>
      'Jarumnya bergerak, tapi tak sampai merah. Terlalu samar lewat kain ini?';

  @override
  String get scanAgain => 'Sudah ditandai.';

  @override
  String scanFound(String place) {
    return 'Ditandai: $place';
  }

  @override
  String scanProgress(int found, int total) {
    return 'Tempat ditandai: $found dari $total';
  }

  @override
  String get vermilionCaption => 'Dengan tinta merah kaisar';

  @override
  String get quireInstruction =>
      'Ketuk satu lembar, lalu lembar lain, untuk menukar tempatnya dalam susunan. Balik sebuah lembar untuk menukar kedua daunnya. Setiap kata alihan harus bertemu halamannya.';

  @override
  String get quireTurn => 'Balik';

  @override
  String quireLinks(int count, int total) {
    return '$count dari $total kata alihan bertemu halamannya';
  }

  @override
  String get quirePicked =>
      'Ketuk lembar lain untuk bertukar tempat, atau balik lembar ini.';

  @override
  String get dipInstruction =>
      'Seret buluh ke dalam tangki sampai menyentuh permukaan, lalu lepaskan dan lihat tetesannya.';

  @override
  String get dipWhat => 'Apa yang menetes dari buluh?';

  @override
  String get dipWrong => 'Tetesannya tidak seperti itu.';

  @override
  String dipLevel(int percent) {
    return 'Terisi $percent%';
  }

  @override
  String get dipStoresQuestion =>
      'Semua tangki sudah dinamai. Apakah persediaannya menipis, atau penuh?';

  @override
  String get dipLow => 'Menipis';

  @override
  String get dipFull => 'Penuh';

  @override
  String get dipStoresWrong => 'Lihat lagi setinggi apa isi tiap tangki.';

  @override
  String get colophonCaption => 'Di sinilah kitab ini tamat';

  @override
  String get coursesInstruction =>
      'Pasang kembali balok-balok yang jatuh, lapis demi lapis dari kiri. Tak boleh ada balok yang berakhir di atas sambungan lapis di bawahnya.';

  @override
  String coursesCourse(int course, int total) {
    return 'Lapis $course dari $total';
  }

  @override
  String get coursesTooLong => 'Terlalu panjang: akan melewati celah.';

  @override
  String get coursesJoint =>
      'Sambungan di atas sambungan: tembok akan retak di situ.';

  @override
  String get coursesTakeBack => 'Ambil kembali';

  @override
  String get coursesBand =>
      'Pita chevron: ketuk lempeng untuk memiringkannya ke arah lain, sampai miring bergantian.';

  @override
  String get identifyInstruction =>
      'Lihat serpihan itu. Mana yang benar tentangnya?';

  @override
  String identifyWrong(String name) {
    return 'Kunci berakhir di: $name';
  }

  @override
  String get identifyBack => 'Kembali ke tempat jalannya salah belok.';

  @override
  String get cartoucheCaption => 'Peta baru pedalaman';

  @override
  String get snowpitInstruction =>
      'Ketuk satu lapisan, lalu dorongkan sesuatu ke dalamnya: yang terbesar yang bisa masuk menunjukkan kekerasannya.';

  @override
  String snowpitIn(String tool) {
    return '$tool: masuk';
  }

  @override
  String snowpitOut(String tool) {
    return '$tool: tidak bisa masuk';
  }

  @override
  String get snowpitMark => 'Tandai lemah';

  @override
  String get snowpitUntested =>
      'Cari dulu kekerasan lapisan ini dan lapisan di atasnya.';

  @override
  String get snowpitNotSofter =>
      'Lapisan ini tidak lebih lunak daripada lapisan di atasnya.';

  @override
  String get snowpitTap => 'Ketuk';

  @override
  String snowpitTaps(int count, String phase) {
    return 'Ketukan: $count ($phase)';
  }

  @override
  String get snowpitWrist => 'dari pergelangan';

  @override
  String get snowpitElbow => 'dari siku';

  @override
  String get snowpitShoulder => 'dari bahu';

  @override
  String get snowpitColumn =>
      'Sebuah kolom dipotong sampai tepat di bawah lapisan yang ditandai. Ketukkan sekop di atasnya.';

  @override
  String get snowpitSpent =>
      'Tiga puluh ketukan dan tak ada yang patah: lapisan lemahnya lebih dalam.';

  @override
  String get snowpitBrokeElsewhere =>
      'Kolom patah di lapisan lain, lebih atas. Tandai yang itu.';

  @override
  String get toolFist => 'Kepalan';

  @override
  String get toolFourFingers => 'Empat jari';

  @override
  String get toolOneFinger => 'Satu jari';

  @override
  String get toolPencil => 'Pensil';

  @override
  String get toolKnife => 'Pisau';

  @override
  String get darkroomInstruction =>
      'Pilih satu bingkai. Di pita ujinya, ketuk pita waktu untuk mencetak.';

  @override
  String get darkroomLight =>
      'Terlalu singkat: abu-abu dan kosong. Kertasnya rusak.';

  @override
  String get darkroomDark =>
      'Terlalu lama: saljunya menjadi abu-abu. Kertasnya rusak.';

  @override
  String darkroomSeconds(String seconds) {
    return '$seconds dtk';
  }

  @override
  String get routebookCaption => 'Buku rute';

  @override
  String get strataInstruction =>
      'Ketuk temuan untuk membaca tahunnya. Lalu ketuk sebuah lapisan dan beri tahun paling awal yang mungkin: tidak lebih tua dari temuan termudanya, maupun dari lapisan di bawahnya.';

  @override
  String strataNotBefore(int year) {
    return 'Tidak sebelum $year';
  }

  @override
  String get strataWrong => 'Tahun itu tidak cocok untuk lapisan ini.';

  @override
  String get strataFireQuestion =>
      'Semua lapisan sudah bertanggal. Ketuk lapisan kebakaran 1582.';

  @override
  String get strataFire => 'Inilah kebakarannya';

  @override
  String get strataNotBurnt => 'Lapisan ini tidak pernah terbakar.';

  @override
  String get strataTooLate => 'Kebakaran ini lebih muda dari 1582.';

  @override
  String get streetsInstruction =>
      'Agaru: utara. Sagaru: selatan. Higashi-iru: timur. Nishi-iru: barat. Ketuk blok yang disebut alamat itu.';

  @override
  String get streetsWrong =>
      'Bukan blok ini. Baca lagi alamatnya dari perempatannya.';

  @override
  String streetsProgress(int found, int total) {
    return 'Alamat ditemukan: $found dari $total';
  }

  @override
  String get markerCaption => 'Situs bersejarah';

  @override
  String get ringsInstruction =>
      'Geser inti kayu sepanjang kronologi induk sampai cincin lebar dan sempitnya seirama, lalu periksa kecocokannya.';

  @override
  String get ringsCheck => 'Periksa kecocokan';

  @override
  String get ringsWrong => 'Polanya tidak cocok di sini. Geser lagi.';

  @override
  String ringsDated(int count) {
    return 'Tanggalnya ketemu. Sekarang tandai $count cincin tersempit berturut-turut: tahun-tahun terkering.';
  }

  @override
  String get ringsMark => 'Inilah tahun-tahun terkering';

  @override
  String get ringsMarkWrong =>
      'Bukan deretan tersempit. Telusuri lagi intinya.';

  @override
  String get dividersInstruction =>
      'Buka jangka pada skala, pilih arah, lalu langkahkan dari Roanoke. Tandai tempat jangka berdiri.';

  @override
  String get dividersHeadings => 'U,TL,T,TG,S,BD,B,BL';

  @override
  String dividersSpan(int miles) {
    return '$miles mil';
  }

  @override
  String get dividersStep => 'Langkah';

  @override
  String get dividersBack => 'Mundur';

  @override
  String get dividersMark => 'Tandai di sini';

  @override
  String dividersWalked(int miles) {
    return '$miles mil ditempuh';
  }

  @override
  String get dividersElsewhere =>
      'Itu tempat lain di peta, bukan yang disebut petunjuk.';

  @override
  String get dividersNothing => 'Tak ada yang tergambar di situ pada peta.';

  @override
  String dividersProgress(int found, int total) {
    return 'Tempat ditemukan: $found dari $total';
  }

  @override
  String get dividersUnset => 'Buka jangka dan pilih arah, lalu melangkah.';

  @override
  String get postCaption => 'Tanda rahasia';

  @override
  String get marginsInstruction =>
      'Putar lembarnya sampai satu bagian tegak, lalu ketuk bagian yang menjawab pertanyaan.';

  @override
  String get marginsUnreadable =>
      'Bagian itu miring atau terbalik. Putar lembarnya.';

  @override
  String get marginsWrong => 'Bagian itu tidak menjawabnya.';

  @override
  String marginsProgress(int answered, int total) {
    return 'Terjawab: $answered dari $total';
  }

  @override
  String get sonarInstruction =>
      'Ketuk satu jalur untuk menjalankan sonar di sepanjangnya, satu jam per jalur. Tandai bangkai kapal di jalur yang sudah dijalankan.';

  @override
  String sonarHours(int hours) {
    return 'Sisa jam: $hours';
  }

  @override
  String get sonarRock => 'Batu: gema bundar, bayangan pendek.';

  @override
  String get sonarScour =>
      'Goresan es: alur panjang, tanpa bayangan yang berdiri.';

  @override
  String get sonarNothing => 'Dasar laut kosong.';

  @override
  String get sonarUnrun => 'Jalur di situ belum dijalankan.';

  @override
  String get sonarSpent =>
      'Musim sudah habis dan bangkai kapal belum ditemukan.';

  @override
  String get sonarNextSeason => 'Musim berikutnya';

  @override
  String get admiraltyCaption =>
      'Siapa pun yang menemukan kertas ini diminta meneruskannya kepada Sekretaris Admiralty, London';

  @override
  String get mudraInstruction =>
      'Ketuk arca Buddha yang jatuh, lalu tempat yang sesuai dengan sikap tangannya.';

  @override
  String get mudraWrong => 'Sikap tangan itu bukan untuk tempat itu.';

  @override
  String get mudraFull => 'Tak ada relung kosong lagi di sana.';

  @override
  String mudraProgress(int set, int total) {
    return 'Dikembalikan: $set dari $total';
  }

  @override
  String get casingInstruction =>
      'Angkat sebuah batu untuk melihat relief di baliknya. Dua sekaligus: perbuatan dan akibatnya disimpan; sisanya kembali.';

  @override
  String get casingNoPair =>
      'Bukan perbuatan dan akibatnya. Batunya dikembalikan.';

  @override
  String get casingPair => 'Perbuatan dan akibatnya: dipotret.';

  @override
  String casingProgress(int kept, int total) {
    return 'Pasangan dipotret: $kept dari $total';
  }

  @override
  String get casingDeed => 'Perbuatan';

  @override
  String get casingFruit => 'Akibat';
}
