// ────────────────────────────────────────────────────────────────────────────
// ZipImportService — extract ZIP archive and merge metadata into Hive
// ────────────────────────────────────────────────────────────────────────────
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../core/constants.dart';
import '../data/models/song.dart';
import '../data/repositories/song_repository.dart';

class ZipImportService {
  final SongRepository _repo;
  bool _isImporting = false;

  ZipImportService(this._repo);

  /// Prompts the user to pick a ZIP, extracts it, merges songs into library.
  /// Returns (imported, skipped) count tuple.
  Future<(int imported, int skipped)> importFromZip({void Function(double)? onProgress}) async {
    if (_isImporting) return (0, 0);
    _isImporting = true;
    try {
      // 1. Pick ZIP file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (result == null || result.files.isEmpty) return (0, 0);
      final zipPath = result.files.first.path;
      if (zipPath == null) return (0, 0);

      // 2. Extract to temp dir
      final appDir = await getApplicationDocumentsDirectory();
      final extractDir = Directory(p.join(appDir.path, '_zip_import_tmp'));
      if (extractDir.existsSync()) extractDir.deleteSync(recursive: true);
      extractDir.createSync(recursive: true);

      final inputStream = InputFileStream(zipPath);
      final archive = ZipDecoder().decodeBuffer(inputStream);

      int totalArchiveFiles = archive.files.length;
      int completedExtracts = 0;

      // Extract files manually to report progress
      for (final file in archive.files) {
        final filePath = p.join(extractDir.path, file.name);
        if (file.isFile) {
          final parent = File(filePath).parent;
          if (!parent.existsSync()) parent.createSync(recursive: true);
          final outStream = OutputFileStream(filePath);
          file.writeContent(outStream);
          outStream.close();
        } else {
          Directory(filePath).createSync(recursive: true);
        }
        completedExtracts++;
        onProgress?.call((completedExtracts / totalArchiveFiles) * 0.5); // First 50% for extracting
        await Future.delayed(const Duration(milliseconds: 10));
      }
      inputStream.close();

      // 3. Read metadata.json
      final metaFile = File(p.join(extractDir.path, AppConstants.metadataFileName));
      if (!metaFile.existsSync()) {
        extractDir.deleteSync(recursive: true);
        return (0, 0);
      }

      final List<dynamic> metadataList =
          jsonDecode(metaFile.readAsStringSync()) as List<dynamic>;

      // 4. Prepare internal storage dirs
      final songsDestDir = Directory(p.join(appDir.path, 'songs'));
      final coversDestDir = Directory(p.join(appDir.path, 'covers'));
      if (!songsDestDir.existsSync()) songsDestDir.createSync(recursive: true);
      if (!coversDestDir.existsSync()) coversDestDir.createSync(recursive: true);

      int imported = 0;
      int skipped = 0;
      int totalItems = metadataList.length;
      int processedItems = 0;

      for (final raw in metadataList) {
        final meta = raw as Map<String, dynamic>;
        final id = meta['id'] as String;

        // 5. Skip duplicates by UUID
        if (_repo.existsById(id)) {
          skipped++;
        } else {
          // 6. Copy song file
          final songFileName = meta['songFileName'] as String?;
          if (songFileName != null) {
            final srcSongPath =
                p.join(extractDir.path, AppConstants.songsFolder, songFileName);
            final srcSongFile = File(srcSongPath);
            if (srcSongFile.existsSync()) {
              final ext = p.extension(songFileName);
              final destSongPath = p.join(songsDestDir.path, '$id$ext');
              await srcSongFile.copy(destSongPath);

              // 7. Copy cover art (optional)
              String? destCoverPath;
              final coverFileName = meta['coverFileName'] as String?;
              if (coverFileName != null) {
                final srcCoverPath =
                    p.join(extractDir.path, AppConstants.coversFolder, coverFileName);
                final srcCoverFile = File(srcCoverPath);
                if (srcCoverFile.existsSync()) {
                  final coverExt = p.extension(coverFileName);
                  destCoverPath = p.join(coversDestDir.path, '$id$coverExt');
                  await srcCoverFile.copy(destCoverPath);
                }
              }

              // 8. Build Song model and save
              final song = Song(
                id: id,
                title: meta['title'] as String? ?? AppConstants.defaultTitle,
                author: meta['author'] as String? ?? AppConstants.defaultAuthor,
                seconds: meta['seconds'] as int? ?? 0,
                filePath: destSongPath,
                coverPath: destCoverPath,
                isLiked: meta['isLiked'] as bool? ?? false,
                playCount: meta['playCount'] as int? ?? 0,
                addedAt: meta['addedAt'] != null
                    ? DateTime.parse(meta['addedAt'] as String)
                    : DateTime.now(),
              );
              await _repo.save(song);
              imported++;
            }
          }
        }
        
        processedItems++;
        onProgress?.call(0.5 + ((processedItems / totalItems) * 0.5)); // Last 50% for copying
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // 9. Clean up temp
      extractDir.deleteSync(recursive: true);
      return (imported, skipped);
    } catch (e) {
      return (0, 0);
    } finally {
      _isImporting = false;
    }
  }
}
