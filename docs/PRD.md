# PRD — Stillroom

> Versi: 0.5 (draft) — 2026-09-25: bingkai cerita, episode pertama, dan arah visual diputuskan developer
> Status: Fondasi teknis siap dikerjakan. Konten cerita dan art masih terbuka.
> Pembaca utama: coding agent. Pembaca kedua: developer (pemilik proyek).

---

## 0. Aturan untuk Agent

Baca bagian ini sebelum mengerjakan apa pun.

1. **Jangan memutuskan hal yang berstatus OPEN** di bagian 2. Kalau sebuah tugas bergantung pada keputusan OPEN, berhenti dan tanyakan ke developer.
2. **Jangan menulis cerita, teks naratif final, atau membuat art.** Pakai placeholder: kotak berwarna dengan label, teks `TODO_TEXT`, dan suara kosong. Konten final dibuat oleh developer.
3. **Kerjakan satu milestone (bagian 10) dalam satu waktu.** Setelah selesai, laporkan hasil dan tunggu konfirmasi sebelum lanjut.
4. **Konten game harus data-driven (JSON), bukan hardcode.** Menambah ruangan, item, atau teka-teki baru tidak boleh membutuhkan perubahan kode Dart, kecuali untuk tipe teka-teki yang benar-benar baru.
5. **Jangan menambah package tanpa alasan.** Setiap package baru di luar bagian 7 harus disebutkan beserta alasannya di laporan.
6. **Engine (lapisan logika game) wajib pure Dart dan punya unit test.**
7. Selalu jalankan Flutter lewat FVM: `fvm flutter ...`, `fvm dart ...`.
8. Kode, nama file, dan identifier dalam bahasa Inggris. Laporan ke developer dalam bahasa Indonesia.

---

## 1. Ringkasan Produk

**Stillroom** adalah game puzzle escape room untuk mobile dengan nuansa surreal, gelap, dan sedikit horor, terinspirasi gaya game seperti Rusty Lake. Pemain menjelajahi ruangan-ruangan statis 2D, mengetuk objek, mengumpulkan dan menggabungkan item, lalu memecahkan teka-teki untuk membuka kunci dan maju.

- **Genre:** point-and-click escape room / puzzle adventure
- **Tema (arah):** antologi misteri, legenda, dan kisah kelam dari berbagai negara, ditafsirkan ulang secara surreal. Setiap episode mengangkat satu kisah
- **Nuansa horor:** atmosferik dan psikologis, bukan gore. Kekerasan tidak ditampilkan secara grafis
- **Target pemain:** Indonesia dan global
- **Episode pertama (v1):** satu ruangan (beberapa sudut pandang), 8–12 teka-teki, waktu main sekitar 30–60 menit

---

## 2. Status Keputusan

| Topik | Status | Nilai |
|---|---|---|
| Nama game | LOCKED | Stillroom |
| Framework | LOCKED | Flutter + Flame |
| Versi Flutter | LOCKED | 3.41.7, dikunci per project lewat FVM (`.fvmrc`) |
| Platform v1 | LOCKED | Android saja. iOS belum direncanakan; jangan kerjakan konfigurasi atau build iOS |
| Genre & nuansa | LOCKED | Escape room, surreal, gelap, horor ringan-atmosferik (tanpa gore) |
| Struktur cerita | DIRECTION | Antologi: satu episode = satu kisah dari satu negara. Bingkai: "The Stillroom" (`docs/stillroom_frame.md`). Episode pertama: Whitechapel, 1888 (Jack the Ripper), fokus pada kelima korban (`docs/episodes/whitechapel_1888.md`). Teks final masih ditulis developer |
| Bahasa | DEFAULT | Inggris (`en`) dan Indonesia (`id`); boleh diubah developer |
| Package name | DEFERRED | Sementara memakai nilai dari `flutter create`. **Wajib diganti ke nama final sebelum upload pertama ke Play Store** (permanen setelah itu). Jangan hardcode package name di kode Dart |
| Orientasi layar | LOCKED | Landscape (kunci orientasi di Android). Nilai tetap dibaca dari konfigurasi (NFR-03) |
| Resolusi logis scene | LOCKED | 1920×1080 (16:9), letterbox di layar dengan rasio lain |
| Premis cerita & simbol sentral | OPEN | Ditulis developer. Engine harus mendukung banyak episode (lihat catatan di bawah tabel) |
| Arah visual | DIRECTION | Ilustrasi kartun bergaya lukisan, surreal, sejiwa dengan Rusty Lake tapi dengan identitas visual sendiri. Art dibuat dengan AI image generation. Panduan gaya v1 (palet, tipografi IM FELL, UI, template prompt): `docs/art_style_guide.md`. Desain karakter dan logo masih OPEN. Lihat bagian 9A |
| Monetisasi | DEFERRED | Diputuskan setelah game jadi. Engine hanya menyiapkan interface `HintGate` (FR-08); jangan tambahkan SDK iklan atau pembayaran |

**Catatan dukungan multi-episode:** konten diorganisasi per episode (`assets/content/episodes/<episode_id>/`), progres dan save dicatat per episode, dan main menu bisa menampilkan daftar episode. v1 hanya berisi satu episode, tapi struktur data tidak boleh mengasumsikan hanya ada satu.

---

## 3. Scope

### 3.1 Dalam scope v1

- Sistem inti game point-and-click (bagian 4)
- Satu ruangan uji berisi konten placeholder yang mendemonstrasikan semua sistem
- Main menu, pengaturan, save otomatis, dua bahasa
- Alat bantu developer: debug overlay hotspot dan validator konten

### 3.2 Di luar scope v1

- Konten cerita dan art final (dibuat developer)
- Integrasi iklan, in-app purchase, analytics, dan cloud save (hanya interface)
- Multiplayer, akun pengguna, koneksi internet apa pun
- Rendering 3D real-time
- Editor visual hotspot (direncanakan untuk versi berikutnya, tapi format data harus siap untuk itu)

---

## 4. Kebutuhan Fungsional

### FR-01 Navigasi scene
- Game terdiri dari **scene**: satu gambar latar per sudut pandang (dinding, meja, laci yang di-zoom, dll).
- Pemain berpindah scene lewat **exit**: area ketuk atau tombol arah (kiri, kanan, kembali/zoom out).
- Transisi antar scene memakai fade singkat (durasi bisa dikonfigurasi).
- Scene bisa punya lapisan objek (sprite) yang tampil atau hilang berdasarkan kondisi.

### FR-02 Hotspot
- Hotspot adalah area ketuk di atas scene, didefinisikan dalam **koordinat ternormalisasi (0–1)** relatif terhadap gambar scene, supaya tidak bergantung resolusi.
- Setiap hotspot punya kondisi tampil/aktif (`when`) dan daftar aksi saat diketuk (`onTap`).
- Hotspot bisa menerima item dari inventori (`onUseItem`): pemain memilih item lalu mengetuk hotspot.
- Mengetuk area kosong tidak melakukan apa-apa (tanpa feedback yang mengganggu).

### FR-03 Inventori
- Bilah inventori selalu terlihat saat bermain (posisi mengikuti orientasi).
- Pemain bisa memilih satu item aktif untuk dipakai pada hotspot.
- Pemain bisa **memeriksa item** (tampilan besar item) dan item bisa punya hotspot sendiri saat diperiksa (misalnya membuka tutup kotak kecil).
- **Kombinasi item:** memilih item A lalu item B menghasilkan item C sesuai tabel kombinasi. Kombinasi tidak valid memberi feedback singkat.

### FR-04 Teka-teki
Teka-teki dibuka dari aksi `openPuzzle` dan tampil sebagai layar khusus. Tipe v1:

| Tipe | Deskripsi |
|---|---|
| `codeLock` | Kombinasi digit atau simbol dengan N slot yang bisa diputar |
| `sequence` | Mengetuk elemen dalam urutan yang benar |
| `rotaryAlign` | Beberapa cincin atau piringan diputar sampai sudut target |
| `slotPlacement` | Menaruh item atau kepingan ke slot yang benar |

- Setiap teka-teki punya konfigurasi di JSON dan aksi `onSolved`.
- Tipe baru harus bisa ditambahkan dengan membuat satu widget/komponen baru dan mendaftarkannya ke registry, tanpa mengubah engine inti.
- Status teka-teki (belum/sudah selesai) tersimpan di state.

### FR-05 Flag dan kondisi
- State dunia disimpan sebagai **flag** (boolean atau integer bernama).
- Kondisi yang didukung: flag bernilai tertentu, punya/tidak punya item, teka-teki sudah/belum selesai. Beberapa kondisi digabung dengan AND.
- Semua flag harus dideklarasikan di file konten supaya bisa divalidasi.

### FR-06 Aksi
Daftar aksi v1 (dieksekusi berurutan):

`goToScene`, `pickItem`, `removeItem`, `setFlag`, `showText`, `openPuzzle`, `examineItem`, `playSound`, `shake` (efek getar kamera kecil), `endEpisode`.

Menambah aksi baru harus lewat registry, sama seperti tipe teka-teki.

### FR-07 Teks
- Teks deskripsi objek dan monolog pendek tampil di kotak teks, ketuk untuk menutup.
- Semua teks memakai **key**, bukan string langsung (lihat FR-10).

### FR-08 Sistem hint
- Setiap teka-teki atau tahap punya hingga 3 tingkat hint (samar → jelas → solusi).
- Hint mana yang tersedia ditentukan oleh kondisi (flag).
- Akses hint lewat interface `HintGate`. Sejak 2026-09-26 implementasinya `CandleHintGate`: setiap hint menunggu "lilin" (45 dtk → 90 dtk → 150 dtk untuk solusi, lebih lama di rak yang lebih tinggi), yang hanya menyala selama pemain berada di tahap/teka-teki itu. Implementasi berbasis iklan (mis. melewati tunggu) menyusul setelah keputusan monetisasi.

### FR-09 Save dan load
- **Autosave** setiap kali state berubah secara berarti (ambil item, flag berubah, teka-teki selesai, pindah scene).
- Satu slot save. Main menu menampilkan "Lanjutkan" jika save ada, dan "Mulai Baru" dengan konfirmasi.
- Format save berupa JSON dengan field `schemaVersion` untuk migrasi di masa depan.

### FR-10 Lokalisasi
- String UI (menu, pengaturan, tombol) memakai Flutter gen-l10n (ARB).
- Teks konten game (deskripsi, monolog, nama item) memakai tabel string per bahasa: `assets/content/strings/en.json`, `assets/content/strings/id.json`.
- Bahasa bisa diganti dari pengaturan tanpa restart.
- Key yang hilang di satu bahasa harus ketahuan oleh validator konten.

### FR-11 Main menu dan pengaturan
- Main menu: Lanjutkan, Mulai Baru, Pengaturan.
- Pengaturan: volume musik, volume efek suara, bahasa, getaran (on/off), reset progres (dengan konfirmasi).

### FR-12 Akhir episode
- Aksi `endEpisode` menampilkan layar penutup sederhana, lalu kembali ke main menu. Status episode selesai tersimpan.

---

## 5. Format Data Konten

Semua konten ada di `assets/content/`. Contoh berikut menunjukkan bentuk yang diharapkan; agent boleh menyempurnakan skema, tapi harus menjaga prinsipnya dan mendokumentasikan perubahan di `docs/content_format.md`.

### 5.1 Scene (`assets/content/scenes/*.json`)

```json
{
  "id": "desk",
  "background": "images/scenes/desk.png",
  "exits": [
    { "direction": "back", "to": "room_north" }
  ],
  "hotspots": [
    {
      "id": "drawer_locked",
      "rect": [0.42, 0.61, 0.18, 0.12],
      "when": [{ "flag": "drawer_open", "equals": false }],
      "onTap": [{ "type": "openPuzzle", "puzzle": "drawer_lock" }]
    },
    {
      "id": "small_key",
      "rect": [0.47, 0.64, 0.05, 0.04],
      "when": [
        { "flag": "drawer_open", "equals": true },
        { "hasItem": "small_key", "equals": false }
      ],
      "onTap": [{ "type": "pickItem", "item": "small_key" }]
    },
    {
      "id": "music_box",
      "rect": [0.12, 0.40, 0.14, 0.18],
      "onTap": [{ "type": "showText", "key": "desk.music_box.look" }],
      "onUseItem": [
        {
          "item": "small_key",
          "actions": [
            { "type": "removeItem", "item": "small_key" },
            { "type": "setFlag", "flag": "music_box_wound", "value": true },
            { "type": "playSound", "sound": "music_box" }
          ]
        }
      ]
    }
  ],
  "layers": [
    {
      "id": "drawer_open_sprite",
      "image": "images/objects/drawer_open.png",
      "rect": [0.40, 0.58, 0.22, 0.18],
      "when": [{ "flag": "drawer_open", "equals": true }]
    }
  ]
}
```

`rect` = `[x, y, width, height]` dalam koordinat ternormalisasi terhadap gambar scene.

### 5.2 Item (`assets/content/items.json`)

```json
{
  "items": [
    { "id": "small_key", "nameKey": "item.small_key.name", "descKey": "item.small_key.desc", "icon": "images/items/small_key.png" }
  ],
  "combinations": [
    { "a": "lens", "b": "frame", "result": "magnifier" }
  ]
}
```

Kombinasi berlaku dua arah (A+B sama dengan B+A).

### 5.3 Teka-teki (`assets/content/puzzles/*.json`)

```json
{
  "id": "drawer_lock",
  "type": "codeLock",
  "config": { "slots": 4, "symbols": ["0","1","2","3","4","5","6","7","8","9"], "solution": ["3","1","4","1"] },
  "onSolved": [
    { "type": "setFlag", "flag": "drawer_open", "value": true },
    { "type": "goToScene", "scene": "desk" }
  ],
  "hints": [
    { "key": "hint.drawer_lock.1" },
    { "key": "hint.drawer_lock.2", "when": [{ "flag": "saw_clock", "equals": true }] },
    { "key": "hint.drawer_lock.3" }
  ]
}
```

### 5.4 Deklarasi global (`assets/content/game.json`)

```json
{
  "startScene": "room_north",
  "flags": { "drawer_open": false, "music_box_wound": false, "saw_clock": false },
  "logicalResolution": [1920, 1080]
}
```

---

## 6. Arsitektur

Skala proyek: **kecil (solo developer)**. Arsitektur dibuat seminimal mungkin tapi dengan pemisahan tegas antara logika dan tampilan.

### 6.1 Lapisan

1. **Engine (pure Dart, `lib/engine/`)**
   Model konten, `GameState` (scene aktif, inventori, flag, status teka-teki), evaluator kondisi, eksekutor aksi, registry aksi dan tipe teka-teki, serializer save. Tidak boleh import Flutter atau Flame. Wajib unit test.
2. **Content loader (`lib/content/`)**
   Memuat dan mem-parse JSON dari assets menjadi model engine. Menjalankan validasi saat mode debug.
3. **State (`lib/state/`)**
   Riverpod `Notifier` yang membungkus engine dan mengekspos state ke UI. Autosave dipicu di sini.
4. **Presentation (`lib/features/`)**
   - Flame dipakai untuk merender scene, layer sprite, hotspot, transisi, dan efek.
   - Widget Flutter dipakai untuk inventori, kotak teks, layar teka-teki, menu, dan pengaturan, sebagai overlay di atas `GameWidget`.
   - Kamera memakai resolusi logis tetap dengan letterbox supaya komposisi scene sama di semua ukuran layar.

### 6.2 Struktur folder

```
lib/
├── core/
│   ├── audio/            # Wrapper flame_audio (interface + impl)
│   ├── storage/          # Save/load ke shared_preferences
│   ├── services/         # HintGate dan interface layanan lain
│   └── theme/
├── engine/               # Pure Dart — model, state, conditions, actions, registries
├── content/              # Loader + validator konten
├── state/                # Riverpod providers
├── features/
│   ├── menu/
│   ├── settings/
│   ├── game/             # FlameGame, komponen scene, hotspot, overlays
│   ├── inventory/
│   └── puzzles/          # Satu subfolder per tipe teka-teki
├── debug/                # Debug overlay, scene jumper
├── l10n/
├── app.dart
└── main.dart

assets/
├── content/              # JSON scene, item, puzzle, game, strings
├── images/               # scenes/, objects/, items/, ui/
└── audio/                # music/, sfx/

docs/
├── PRD.md                # Dokumen ini
└── content_format.md     # Dokumentasi skema konten (dibuat agent)

tool/
└── validate_content.dart # Validator konten via CLI
```

### 6.3 Aturan arsitektur
- Fitur tidak saling import langsung; kebutuhan bersama lewat `engine/`, `state/`, atau `core/`.
- Layanan pihak ketiga (audio, iklan, analytics) selalu dibungkus interface di `core/`.
- Tidak ada logika game di widget atau komponen Flame; mereka hanya membaca state dan mengirim event ke engine.

---

## 7. Tech Stack

Gunakan versi terbaru yang kompatibel dengan Flutter 3.41.7. Periksa pub.dev sebelum menambahkan.

| Kebutuhan | Package |
|---|---|
| Game rendering | `flame` |
| Audio | `flame_audio` |
| State management | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`, `riverpod_lint` |
| Model immutable | `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation` |
| Penyimpanan | `shared_preferences` |
| Lokalisasi | `flutter_localizations`, `intl` (gen-l10n) |
| Code generation | `build_runner` |

Tidak dipakai di v1: `dio`, `flutter_secure_storage`, `go_router` (navigasi cukup antara menu, game, dan pengaturan), Firebase, SDK iklan.

---

## 8. Kebutuhan Non-Fungsional

- **NFR-01 Performa:** 60 fps stabil di Android kelas menengah bawah. Gambar scene dimuat per scene, tidak semuanya di awal.
- **NFR-02 Ukuran aplikasi:** target di bawah 80 MB untuk episode pertama. Gambar dikompresi (WebP disarankan).
- **NFR-03 Orientasi & resolusi:** orientasi dan resolusi logis dibaca dari konfigurasi (`game.json`), bukan hardcode. Mengganti orientasi tidak boleh membutuhkan perubahan kode engine.
- **NFR-04 Offline penuh:** tidak ada permintaan jaringan di v1.
- **NFR-05 Aksesibilitas dasar:** area ketuk minimal setara 44×44 dp di layar fisik; teks bisa dibaca di layar kecil.
- **NFR-06 Ketahanan save:** save yang rusak tidak boleh membuat game crash; tampilkan opsi mulai baru.

---

## 9. Alat Bantu Developer

- **Debug overlay (hanya mode debug):** tombol untuk menampilkan batas semua hotspot beserta id-nya, menampilkan flag aktif, lompat ke scene mana pun, dan reset save.
- **Validator konten** (`fvm dart run tool/validate_content.dart` dan juga dijalankan sebagai test), memeriksa:
  - semua referensi scene, item, puzzle, sound, dan gambar ada
  - semua flag yang dipakai sudah dideklarasikan
  - semua text key ada di setiap bahasa
  - `rect` berada dalam rentang 0–1
  - `startScene` valid

---

## 9A. Pipeline Art

Art final dibuat dengan AI image generation, bukan oleh coding agent. Aturan untuk coding agent:

- Selama belum ada art final, pakai placeholder yang digambar lewat kode: kotak dan bentuk sederhana berwarna dengan label id, pada kanvas 1920×1080.
- Jangan mengunduh gambar dari internet dan jangan memakai aset pihak ketiga tanpa izin developer.
- Sistem harus memudahkan penggantian placeholder dengan art final: cukup menaruh file di `assets/images/` dengan path yang sama seperti di JSON.

Kebutuhan art yang harus dipenuhi oleh pipeline gambar (untuk developer):

- **Style guide dan gambar referensi** dibuat pertama kali, lalu dipakai di setiap prompt supaya semua scene konsisten.
- **Scene latar** 1920×1080 per sudut pandang.
- **Varian state** untuk objek yang berubah (laci tertutup/terbuka, lampu mati/nyala), dibuat sebagai layer terpisah dengan latar transparan, atau lewat editing/inpainting dari gambar yang sama supaya posisinya tidak bergeser.
- **Ikon item** dengan latar transparan dan gaya yang sama.
- Setelah art masuk, posisi `rect` hotspot dan layer disesuaikan ulang memakai debug overlay (bagian 9).
- Jangan menyebut nama game atau studio lain dalam prompt; deskripsikan gaya sendiri.

---

## 10. Milestone

Setiap milestone diakhiri laporan ke developer dan menunggu konfirmasi.

| ID | Milestone | Hasil |
|---|---|---|
| M0 | Setup | Project Flutter via FVM, package di bagian 7, struktur folder, analysis options + riverpod_lint, lokalisasi dasar, app berjalan di emulator Android |
| M1 | Engine inti | Model konten, `GameState`, kondisi, aksi, registry, serializer save, beserta unit test |
| M2 | Scene & hotspot | Loader konten, FlameGame dengan resolusi logis tetap, render scene & layer, hotspot, exit, transisi, debug overlay |
| M3 | Inventori & teks | Bilah inventori, pilih item, `onUseItem`, periksa item, kombinasi, kotak teks |
| M4 | Teka-teki | Registry tipe teka-teki dan empat tipe v1 dari FR-04 |
| M5 | Meta game | Main menu, pengaturan, autosave/load, ganti bahasa, akhir episode |
| M6 | Hint & polish | Sistem hint dengan `FreeHintGate`, audio, efek, validator konten via CLI, ruangan uji lengkap yang memakai semua fitur |

Rilis (closed testing Play Store, listing, signing) dikerjakan setelah konten final tersedia dan di luar scope agent untuk saat ini.

---

## 11. Definition of Done

Sebuah milestone dianggap selesai jika:

- `fvm flutter analyze` tanpa error dan warning
- `fvm flutter test` lulus semua
- Validator konten lulus untuk konten yang ada
- Fitur milestone bisa didemonstrasikan di ruangan uji pada emulator atau perangkat Android
- Tidak ada string UI atau teks konten yang di-hardcode
- Perubahan skema konten tercatat di `docs/content_format.md`

---

## 12. Pertanyaan Terbuka (untuk Developer)

1. Kisah untuk episode pertama, dan bingkai cerita yang menghubungkan semua episode?
2. Style guide visual: palet, tekstur, garis, ciri khas yang membedakan dari Rusty Lake?

Ditunda dengan sengaja: package name (sebelum rilis) dan monetisasi.
