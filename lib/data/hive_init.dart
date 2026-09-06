// ────────────────────────────────────────────────────────────────────────────
// Hive initialization
// ────────────────────────────────────────────────────────────────────────────
import 'package:hive_flutter/hive_flutter.dart';
import 'models/song.dart';
import 'models/playlist.dart';

class HiveInit {
  static const String songsBox = 'songs_box';
  static const String playlistsBox = 'playlists_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SongAdapter());
    Hive.registerAdapter(PlaylistAdapter());
    await Hive.openBox<Song>(songsBox);
    await Hive.openBox<Playlist>(playlistsBox);
  }
}
