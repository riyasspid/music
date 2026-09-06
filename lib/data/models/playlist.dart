// ────────────────────────────────────────────────────────────────────────────
// Playlist model with Hive type adapter
// ────────────────────────────────────────────────────────────────────────────
import 'package:hive/hive.dart';

part 'playlist.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  List<String> songIds; // ordered list of Song IDs

  @HiveField(3)
  late DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
  });
}
