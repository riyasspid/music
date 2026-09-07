// ────────────────────────────────────────────────────────────────────────────
// Playlist repository — reactive CRUD operations on Hive box with GetX observables
// ────────────────────────────────────────────────────────────────────────────
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/playlist.dart';
import '../hive_init.dart';

class PlaylistRepository extends GetxController {
  Box<Playlist> get _box => Hive.box<Playlist>(HiveInit.playlistsBox);

  final RxList<Playlist> playlists = <Playlist>[].obs;

  @override
  void onInit() {
    super.onInit();
    _refresh();
    _box.listenable().addListener(_refresh);
  }

  void _refresh() {
    playlists.assignAll(_box.values.toList());
  }

  List<Playlist> getAll() => [...playlists];

  Playlist? getById(String id) {
    try {
      return _box.get(id) ?? _box.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Playlist playlist) async {
    await _box.put(playlist.id, playlist);
    _refresh();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _refresh();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final pl = getById(playlistId);
    if (pl != null && !pl.songIds.contains(songId)) {
      pl.songIds.add(songId);
      await _box.put(playlistId, pl);
      _refresh();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final pl = getById(playlistId);
    if (pl != null) {
      pl.songIds.remove(songId);
      await _box.put(playlistId, pl);
      _refresh();
    }
  }
}
