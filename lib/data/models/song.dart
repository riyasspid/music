// ────────────────────────────────────────────────────────────────────────────
// Song model with Hive type adapter
// ────────────────────────────────────────────────────────────────────────────
import 'package:hive/hive.dart';

part 'song.g.dart';

@HiveType(typeId: 0)
class Song extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String author;

  @HiveField(3)
  late int seconds;

  @HiveField(4)
  late String filePath;

  @HiveField(5)
  String? coverPath;

  @HiveField(6)
  bool isLiked;

  @HiveField(7)
  int playCount;

  @HiveField(8)
  late DateTime addedAt;

  Song({
    required this.id,
    required this.title,
    required this.author,
    required this.seconds,
    required this.filePath,
    this.coverPath,
    this.isLiked = false,
    this.playCount = 0,
    required this.addedAt,
  });

  String get durationFormatted {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'seconds': seconds,
        'filePath': filePath,
        'coverPath': coverPath,
        'isLiked': isLiked,
        'playCount': playCount,
        'addedAt': addedAt.toIso8601String(),
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        seconds: json['seconds'] as int,
        filePath: json['filePath'] as String,
        coverPath: json['coverPath'] as String?,
        isLiked: json['isLiked'] as bool? ?? false,
        playCount: json['playCount'] as int? ?? 0,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}
