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
  try {
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
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.music.app.channel',
        androidNotificationChannelName: 'Music',
        androidStopForegroundOnPause: true,
      ),
    );

    runApp(App(audioHandler: audioHandler));
  } catch (e, st) {
    debugPrint('App initialization error: $e\n$st');
    runApp(MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Text(
                'Failed to start app:\n$e\n\n$st',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
