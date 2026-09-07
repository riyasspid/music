// ────────────────────────────────────────────────────────────────────────────
// Song repository — reactive CRUD operations on Hive box with GetX observables
// ────────────────────────────────────────────────────────────────────────────
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/song.dart';
import '../hive_init.dart';

class SongRepository extends GetxController {
  Box<Song> get _box => Hive.box<Song>(HiveInit.songsBox);

  /// Reactive list of all songs in the library
  final RxList<Song> songs = <Song>[].obs;

  /// Reactive set of liked song IDs for instant O(1) reactive lookup
  final RxSet<String> likedSongIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _refresh();
    // Listen to Hive box mutations to react to any changes across the app
    _box.listenable().addListener(_refresh);
  }

  void _refresh() {
    final all = _box.values.toList();
    songs.assignAll(all);
    likedSongIds.assignAll(
      all.where((s) => s.isLiked).map((s) => s.id),
    );
  }

  /// Check if a song is liked reactively
  bool isLiked(String id) => likedSongIds.contains(id);

  List<Song> getAll() => [...songs];

  Song? getById(String id) {
    try {
      return _box.get(id) ?? _box.values.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Song song) async {
    await _box.put(song.id, song);
    _refresh();
  }

  Future<void> saveAll(List<Song> newSongs) async {
    final map = {for (final s in newSongs) s.id: s};
    await _box.putAll(map);
    _refresh();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _refresh();
  }

  Future<void> toggleLike(String id) async {
    final song = getById(id);
    if (song != null) {
      song.isLiked = !song.isLiked;
      await _box.put(id, song);
      _refresh();
    }
  }

  Future<void> incrementPlayCount(String id) async {
    final song = getById(id);
    if (song != null) {
      song.playCount++;
      await _box.put(id, song);
      _refresh();
    }
  }

  List<Song> getLiked() =>
      songs.where((s) => isLiked(s.id)).toList();

  List<Song> getFrequent({int limit = 50}) {
    final all = [...songs];
    all.sort((a, b) => b.playCount.compareTo(a.playCount));
    return all.take(limit).toList();
  }

  List<Song> getRecent({int limit = 10}) {
    final all = [...songs];
    all.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return all.take(limit).toList();
  }

  bool existsById(String id) => _box.containsKey(id);
}
