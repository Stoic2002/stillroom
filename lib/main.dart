import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/storage/shared_preferences_store.dart';
import 'state/storage_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  LicenseRegistry.addLicense(() async* {
    for (final (font, file) in _fontLicenses) {
      yield LicenseEntryWithLineBreaks([
        font,
      ], await rootBundle.loadString('assets/fonts/licenses/$file'));
    }
  });
  final store = await SharedPreferencesStore.create();
  runApp(
    ProviderScope(
      // Everything is local and offline (NFR-04): a failed load will fail
      // again, so Riverpod's automatic retry would only hide the error.
      retry: (_, _) => null,
      overrides: [keyValueStoreProvider.overrideWithValue(store)],
      child: const StillroomApp(),
    ),
  );
}

const _fontLicenses = [
  ('IM FELL English', 'OFL-IMFell.txt'),
  ('Old Standard TT', 'OFL-OldStandard.txt'),
  ('Noto Serif JP', 'OFL-NotoSerifJP.txt'),
  ('Noto Serif SC', 'OFL-NotoSerifSC.txt'),
  ('Noto Serif KR', 'OFL-NotoSerifKR.txt'),
];
