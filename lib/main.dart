// ────────────────────────────────────────────────────────────────────────────
// main.dart — entry point
// Initializes Hive, registers AudioService, then launches the app.
// ────────────────────────────────────────────────────────────────────────────
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'data/hive_init.dart';
import 'services/audio_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Hive
  await HiveInit.init();

  // Initialize AudioService + handler (background audio)
  final audioHandler = await AudioService.init(
    builder: () => MusicAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.music.app.channel',
      androidNotificationChannelName: 'Music',
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(App(audioHandler: audioHandler));
}
