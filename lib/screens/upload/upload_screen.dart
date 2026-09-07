// ────────────────────────────────────────────────────────────────────────────
// Upload Screen — import single song or ZIP
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neumorphic_widget.dart';
import '../../services/import_service.dart';
import '../../services/zip_import_service.dart';
import '../../core/utils.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final importSvc = Get.find<ImportService>();
    final zipImport = Get.find<ZipImportService>();

    return Scaffold(
      backgroundColor: neuBase,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Import Music',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add songs to your library',
                style: TextStyle(fontSize: 13, color: textMid),
              ),
              const SizedBox(height: 24),

              // ── Import single song ────────────────────────────────────────
              _ImportCard(
                icon: Icons.audio_file,
                title: 'Import Song',
                subtitle: 'Pick an audio file (MP3, FLAC, WAV, M4A…)',
                color: accentBlue,
                onTap: () async {
                  final song = await importSvc.importSingleSong(context);
                  if (song != null && context.mounted) {
                    AppSnackbar.show(
                      '✅ Imported!',
                      '"${song.title}" by ${song.author} added',
                      duration: const Duration(seconds: 3),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              // ── Import ZIP ───────────────────────────────────────────────
              _ImportCard(
                icon: Icons.folder_zip,
                title: 'Import ZIP Archive',
                subtitle: 'Restore a GrooveBox backup with all metadata',
                color: accentPurple,
                onTap: () async {
                  AppSnackbar.show('Importing…', 'Please wait');
                  final (imported, skipped) = await zipImport.importFromZip();
                  if (context.mounted && (imported > 0 || skipped > 0)) {
                    AppSnackbar.show(
                      '✅ ZIP Imported',
                      '$imported songs added, $skipped skipped (duplicates)',
                      duration: const Duration(seconds: 4),
                    );
                  }
                },
              ),

              const SizedBox(height: 24),

              // ── Supported formats info ────────────────────────────────────
              NeuBox(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supported Formats',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: ['MP3', 'FLAC', 'WAV', 'M4A', 'OGG', 'AAC']
                          .map((ext) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ext,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: accentBlue,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ImportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeuButton(
      borderRadius: 18,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: textMid),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
