// ────────────────────────────────────────────────────────────────────────────
// ImportService — single song file picker + metadata dialog + save to Hive
// ────────────────────────────────────────────────────────────────────────────
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../data/models/song.dart';
import '../data/repositories/song_repository.dart';

class ImportService {
  final SongRepository _repo;
  final _uuid = const Uuid();

  ImportService(this._repo);

  /// Pick a single audio file, show metadata dialog, save to library.
  /// Returns the saved Song or null if cancelled.
  Future<Song?> importSingleSong(BuildContext context) async {
    // 1. File picker
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.allowedExtensions,
    );
    if (result == null || result.files.isEmpty) return null;

    final pickedFile = result.files.first;
    final sourcePath = pickedFile.path;
    if (sourcePath == null) return null;

    // 2. Get duration from audio file
    final tempPlayer = AudioPlayer();
    int songSeconds = 0;
    try {
      await tempPlayer.setFilePath(sourcePath);
      final dur = tempPlayer.duration;
      songSeconds = dur?.inSeconds ?? 0;
    } catch (_) {
      songSeconds = 0;
    } finally {
      await tempPlayer.dispose();
    }

    // 3. Default title from filename
    final defaultTitle = AppUtils.fileNameToTitle(sourcePath);

    // 4. Show metadata dialog (guard context after async gap)
    // ignore: use_build_context_synchronously
    final metadata = await _showMetadataDialog(context, defaultTitle);
    if (metadata == null) return null;

    // 5. Copy file to internal storage
    final appDir = await getApplicationDocumentsDirectory();
    final songsDir = Directory(p.join(appDir.path, 'songs'));
    if (!songsDir.existsSync()) songsDir.createSync(recursive: true);

    final songId = _uuid.v4();
    final ext = p.extension(sourcePath);
    final destPath = p.join(songsDir.path, '$songId$ext');
    await File(sourcePath).copy(destPath);

    // 6. Copy cover if selected
    String? coverDestPath;
    if (metadata['coverPath'] != null) {
      final coversDir = Directory(p.join(appDir.path, 'covers'));
      if (!coversDir.existsSync()) coversDir.createSync(recursive: true);
      final coverExt = p.extension(metadata['coverPath'] as String);
      coverDestPath = p.join(coversDir.path, '$songId$coverExt');
      await File(metadata['coverPath'] as String).copy(coverDestPath);
    }

    // 7. Save to Hive
    final song = Song(
      id: songId,
      title: metadata['title'] as String,
      author: metadata['author'] as String,
      seconds: songSeconds,
      filePath: destPath,
      coverPath: coverDestPath,
      addedAt: DateTime.now(),
    );
    await _repo.save(song);
    return song;
  }

  Future<Map<String, dynamic>?> _showMetadataDialog(
    BuildContext context,
    String defaultTitle,
  ) async {
    final titleCtrl = TextEditingController(text: defaultTitle);
    final authorCtrl = TextEditingController(text: '');
    String? coverPath;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFFE0E5EC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Song Details',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Author / Artist',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      coverPath != null
                          ? '✅ Cover selected'
                          : 'No cover art',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final r = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );
                      if (r != null && r.files.isNotEmpty) {
                        setState(() => coverPath = r.files.first.path);
                      }
                    },
                    child: const Text('Pick Cover'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleCtrl.text.trim().isEmpty
                    ? AppConstants.defaultTitle
                    : titleCtrl.text.trim();
                final author = authorCtrl.text.trim().isEmpty
                    ? AppConstants.defaultAuthor
                    : authorCtrl.text.trim();
                Navigator.pop(ctx, {
                  'title': title,
                  'author': author,
                  'coverPath': coverPath,
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
