// ────────────────────────────────────────────────────────────────────────────
// Song repository — CRUD operations on Hive box
// ────────────────────────────────────────────────────────────────────────────
import 'package:hive_flutter/hive_flutter.dart';
import '../models/song.dart';
import '../hive_init.dart';

class SongRepository {
  Box<Song> get _box => Hive.box<Song>(HiveInit.songsBox);

  List<Song> getAll() => _box.values.toList();

  Song? getById(String id) {
    try {
      return _box.values.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Song song) async {
    await _box.put(song.id, song);
  }

  Future<void> saveAll(List<Song> songs) async {
    final map = {for (final s in songs) s.id: s};
    await _box.putAll(map);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleLike(String id) async {
    final song = getById(id);
    if (song != null) {
      song.isLiked = !song.isLiked;
      await song.save();
    }
  }

  Future<void> incrementPlayCount(String id) async {
    final song = getById(id);
    if (song != null) {
      song.playCount++;
      await song.save();
    }
  }

  List<Song> getLiked() =>
      _box.values.where((s) => s.isLiked).toList();

  List<Song> getFrequent({int limit = 50}) {
    final all = _box.values.toList();
    all.sort((a, b) => b.playCount.compareTo(a.playCount));
    return all.take(limit).toList();
  }

  List<Song> getRecent({int limit = 10}) {
    final all = _box.values.toList();
    all.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return all.take(limit).toList();
  }

  bool existsById(String id) => _box.containsKey(id);
}
