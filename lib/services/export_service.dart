// ────────────────────────────────────────────────────────────────────────────
// ExportService — bundles all songs + covers + metadata.json into a ZIP
// ────────────────────────────────────────────────────────────────────────────
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../core/constants.dart';
import '../data/models/song.dart';
import '../data/repositories/song_repository.dart';

class ExportService {
  final SongRepository _repo;

  ExportService(this._repo);

  /// Creates a ZIP file in Downloads containing all songs + metadata.
  /// Returns the path to the created ZIP, or null on failure.
  Future<String?> exportAll() async {
    final songs = _repo.getAll();
    if (songs.isEmpty) return null;

    final encoder = ZipFileEncoder();

    // Write to external Downloads directory
    final downloadsDir = await _getDownloadsDir();
    final now = DateTime.now();
    final fileName =
        'music_${now.year}${_pad(now.month)}${_pad(now.day)}.zip';
    final zipPath = p.join(downloadsDir.path, fileName);

    encoder.create(zipPath);

    // metadata.json
    final metadata = songs.map((s) => _songToExportJson(s)).toList();
    final metaBytes = utf8.encode(jsonEncode(metadata));
    encoder.addArchiveFile(
      ArchiveFile(AppConstants.metadataFileName, metaBytes.length, metaBytes),
    );

    // Song files
    for (final song in songs) {
      final file = File(song.filePath);
      if (file.existsSync()) {
        final ext = p.extension(song.filePath);
        encoder.addFile(file, '${AppConstants.songsFolder}/${song.id}$ext');
      }
    }

    // Cover art files
    for (final song in songs) {
      if (song.coverPath != null) {
        final coverFile = File(song.coverPath!);
        if (coverFile.existsSync()) {
          final ext = p.extension(song.coverPath!);
          encoder.addFile(
              coverFile, '${AppConstants.coversFolder}/${song.id}$ext');
        }
      }
    }

    encoder.close();
    return zipPath;
  }

  Map<String, dynamic> _songToExportJson(Song song) {
    final ext = p.extension(song.filePath);
    return {
      'id': song.id,
      'title': song.title,
      'author': song.author,
      'seconds': song.seconds,
      'songFileName': '${song.id}$ext',
      'coverFileName': song.coverPath != null
          ? '${song.id}${p.extension(song.coverPath!)}'
          : null,
      'isLiked': song.isLiked,
      'playCount': song.playCount,
      'addedAt': song.addedAt.toIso8601String(),
    };
  }

  Future<Directory> _getDownloadsDir() async {
    // Try standard Downloads on Android
    final dir = Directory('/storage/emulated/0/Download');
    if (dir.existsSync()) return dir;
    // Fallback to documents directory
    return getApplicationDocumentsDirectory();
  }

  String _pad(int v) => v.toString().padLeft(2, '0');
}
