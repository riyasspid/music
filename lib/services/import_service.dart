// ────────────────────────────────────────────────────────────────────────────
// ImportService — single song file picker + metadata dialog + save to Hive
// ────────────────────────────────────────────────────────────────────────────
import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils.dart';
import '../data/models/song.dart';
import '../data/repositories/song_repository.dart';

class ImportService {
  final SongRepository _repo;
  final _uuid = const Uuid();
  static bool _isImporting = false;

  ImportService(this._repo);

  /// Pick a single audio file, extract embedded metadata & cover art,
  /// show metadata dialog with cover preview & picker, then save to library.
  /// Returns the saved Song or null if cancelled.
  Future<List<Song>> importSongs(BuildContext context) async {
    if (_isImporting) return [];
    _isImporting = true;
    try {
      // 1. File picker for audio (allow multiple)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedExtensions,
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) return [];

      List<Song> importedSongs = [];

      for (var pickedFile in result.files) {
        final sourcePath = pickedFile.path;
        if (sourcePath == null) continue;

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

        // 3. Extract embedded audio metadata & cover art from file
        String defaultTitle = AppUtils.fileNameToTitle(sourcePath);
        String defaultAuthor = 'Unknown Artist';
        String? extractedCoverPath;

        try {
          final audioMeta = readMetadata(File(sourcePath), getImage: true);
          if (audioMeta.title != null && audioMeta.title!.trim().isNotEmpty) {
            defaultTitle = audioMeta.title!.trim();
          }
          if (audioMeta.artist != null && audioMeta.artist!.trim().isNotEmpty) {
            defaultAuthor = audioMeta.artist!.trim();
          }
          if (audioMeta.pictures.isNotEmpty) {
            final pic = audioMeta.pictures.first;
            if (pic.bytes.isNotEmpty) {
              final tempDir = await getTemporaryDirectory();
              String ext = '.jpg';
              if (pic.bytes.length >= 4 &&
                  pic.bytes[0] == 0x89 &&
                  pic.bytes[1] == 0x50 &&
                  pic.bytes[2] == 0x4E &&
                  pic.bytes[3] == 0x47) {
                ext = '.png';
              }
              final tempFile = File(p.join(
                tempDir.path,
                'extracted_cover_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}$ext',
              ));
              await tempFile.writeAsBytes(pic.bytes);
              extractedCoverPath = tempFile.path;
            }
          }
        } catch (e) {
          debugPrint('Could not read embedded audio metadata: $e');
        }

        // 4. Copy song file to internal storage
        final appDir = await getApplicationDocumentsDirectory();
        final songsDir = Directory(p.join(appDir.path, 'songs'));
        if (!songsDir.existsSync()) songsDir.createSync(recursive: true);

        final songId = _uuid.v4();
        final ext = p.extension(sourcePath);
        final destPath = p.join(songsDir.path, '$songId$ext');
        await File(sourcePath).copy(destPath);

        // 5. Move extracted cover to covers directory
        String? coverDestPath;
        if (extractedCoverPath != null && File(extractedCoverPath).existsSync()) {
          final coversDir = Directory(p.join(appDir.path, 'covers'));
          if (!coversDir.existsSync()) coversDir.createSync(recursive: true);
          final coverExt = p.extension(extractedCoverPath).isNotEmpty
              ? p.extension(extractedCoverPath)
              : '.jpg';
          coverDestPath = p.join(coversDir.path, '$songId$coverExt');
          await File(extractedCoverPath).copy(coverDestPath);

          // Clean up temp extracted file
          try {
            File(extractedCoverPath).deleteSync();
          } catch (_) {}
        }

        // 6. Save to Hive
        final song = Song(
          id: songId,
          title: defaultTitle,
          author: defaultAuthor,
          seconds: songSeconds,
          filePath: destPath,
          coverPath: coverDestPath,
          addedAt: DateTime.now(),
        );
        await _repo.save(song);
        importedSongs.add(song);
      }
      return importedSongs;
    } finally {
      _isImporting = false;
    }
  }

  Future<Map<String, dynamic>?> _showMetadataDialog({
    required BuildContext context,
    required String defaultTitle,
    required String defaultAuthor,
    required String? initialCoverPath,
  }) async {
    final titleCtrl = TextEditingController(text: defaultTitle);
    final authorCtrl = TextEditingController(text: defaultAuthor);
    String? currentCoverPath = initialCoverPath;
    bool isFromAudio = initialCoverPath != null;
    bool isPickingCover = false;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          Future<void> pickNewCover() async {
            if (isPickingCover) return;
            isPickingCover = true;
            try {
              try {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 92,
                );
                if (image != null) {
                  setState(() {
                    currentCoverPath = image.path;
                    isFromAudio = false;
                  });
                  return;
                }
              } catch (_) {
                // Fallback to FilePicker if image_picker fails on device
              }

              try {
                final r = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                );
                if (r != null && r.files.isNotEmpty && r.files.first.path != null) {
                  setState(() {
                    currentCoverPath = r.files.first.path;
                    isFromAudio = false;
                  });
                }
              } catch (_) {}
            } finally {
              isPickingCover = false;
            }
          }

          final hasCover = currentCoverPath != null &&
              File(currentCoverPath!).existsSync();

          return AlertDialog(
            backgroundColor: neuBase,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.music_note_rounded,
                      color: accentBlue, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Song Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: textDark,
                        ),
                      ),
                      Text(
                        'Review metadata and cover art',
                        style: TextStyle(fontSize: 12, color: textMid),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Cover art preview & actions ──────────────────────────
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: pickNewCover,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: neuBase,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: hasCover ? neuSoftShadow : neuInsetShadow,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: hasCover
                                  ? Image.file(
                                      File(currentCoverPath!),
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_rounded,
                                          size: 38,
                                          color: accentBlue.withValues(alpha: 0.8),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Pick Cover',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: textMid,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Source badge / Action buttons
                        if (hasCover) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isFromAudio
                                    ? Icons.auto_awesome
                                    : Icons.image_rounded,
                                size: 13,
                                color: isFromAudio ? accentPurple : accentBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isFromAudio
                                    ? 'Cover from audio file'
                                    : 'Custom cover art',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isFromAudio ? accentPurple : accentBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                onPressed: pickNewCover,
                                icon: const Icon(Icons.edit, size: 14),
                                label: const Text(
                                  'Change',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: accentBlue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    currentCoverPath = null;
                                    isFromAudio = false;
                                  });
                                },
                                icon: const Icon(Icons.close, size: 14),
                                label: const Text(
                                  'Remove',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          TextButton.icon(
                            onPressed: pickNewCover,
                            icon: const Icon(Icons.photo_library_outlined,
                                size: 15),
                            label: const Text(
                              'Choose from gallery',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: accentBlue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Title field ──────────────────────────────────────────
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle:
                          const TextStyle(color: textMid, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFD6DBE2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.title,
                          size: 18, color: textMid),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Author field ─────────────────────────────────────────
                  TextField(
                    controller: authorCtrl,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Artist / Author',
                      labelStyle:
                          const TextStyle(color: textMid, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFD6DBE2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person_outline,
                          size: 18, color: textMid),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: textMid, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                ),
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
                    'coverPath': currentCoverPath,
                  });
                },
                child: const Text(
                  'Save Song',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
