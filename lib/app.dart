// ────────────────────────────────────────────────────────────────────────────
// App root — MaterialApp + GetX bindings
// ────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/playlist_repository.dart';
import 'data/repositories/song_repository.dart';
import 'navigation/main_navigation.dart';
import 'services/audio_handler.dart';
import 'services/audio_provider.dart';
import 'services/export_service.dart';
import 'services/import_service.dart';
import 'services/sleep_timer_service.dart';
import 'services/zip_import_service.dart';

class App extends StatelessWidget {
  final MusicAudioHandler audioHandler;

  const App({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Music',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialBinding: _AppBindings(audioHandler),
      home: const MainNavigation(),
    );
  }
}

class _AppBindings extends Bindings {
  final MusicAudioHandler _handler;

  _AppBindings(this._handler);

  @override
  void dependencies() {
    // Repositories
    Get.put(SongRepository(), permanent: true);
    Get.put(PlaylistRepository(), permanent: true);

    // Services
    Get.put(ImportService(Get.find<SongRepository>()), permanent: true);
    Get.put(ExportService(Get.find<SongRepository>()), permanent: true);
    Get.put(ZipImportService(Get.find<SongRepository>()), permanent: true);
    Get.put(SleepTimerService(), permanent: true);

    // Audio
    Get.put(
      AudioProvider(_handler, Get.find<SongRepository>()),
      permanent: true,
    );
  }
}
