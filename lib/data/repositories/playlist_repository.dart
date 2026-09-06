// ────────────────────────────────────────────────────────────────────────────
// Playlist repository
// ────────────────────────────────────────────────────────────────────────────
import 'package:hive_flutter/hive_flutter.dart';
import '../models/playlist.dart';
import '../hive_init.dart';

class PlaylistRepository {
  Box<Playlist> get _box => Hive.box<Playlist>(HiveInit.playlistsBox);

  List<Playlist> getAll() => _box.values.toList();

  Playlist? getById(String id) {
    try {
      return _box.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Playlist playlist) async {
    await _box.put(playlist.id, playlist);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final pl = getById(playlistId);
    if (pl != null && !pl.songIds.contains(songId)) {
      pl.songIds.add(songId);
      await pl.save();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final pl = getById(playlistId);
    if (pl != null) {
      pl.songIds.remove(songId);
      await pl.save();
    }
  }
}
