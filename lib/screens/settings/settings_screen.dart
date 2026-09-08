// ────────────────────────────────────────────────────────────────────────────
// Settings Screen — Export ZIP, Import ZIP, Sleep Timer, About
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neumorphic_widget.dart';
import '../../services/export_service.dart';
import '../../services/sleep_timer_service.dart';
import '../../services/zip_import_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exportSvc = Get.find<ExportService>();
    final zipImport = Get.find<ZipImportService>();
    final sleepTimer = Get.find<SleepTimerService>();

    return Scaffold(
      backgroundColor: neuBase,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 24, 4, 20),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ),

            // ── Backup & Restore section ──────────────────────────────────
            _SectionHeader(label: 'Backup & Restore'),
            const SizedBox(height: 8),

            _SettingsTile(
              icon: Icons.file_download_outlined,
              iconColor: accentBlue,
              title: 'Export ZIP',
              subtitle: 'Download all songs + metadata as a ZIP backup',
              onTap: () async {
                final progress = 0.0.obs;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    backgroundColor: neuBase,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Exporting ZIP'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Bundling your songs and metadata...', style: TextStyle(color: textMid, fontSize: 13)),
                        const SizedBox(height: 20),
                        Obx(() => LinearProgressIndicator(
                          value: progress.value,
                          color: accentBlue,
                          backgroundColor: Colors.grey[300],
                        )),
                      ],
                    ),
                  ),
                );

                // Allow the UI to render the dialog before starting heavy blocking work
                await Future.delayed(const Duration(milliseconds: 100));

                final path = await exportSvc.exportAll(
                  onProgress: (p) => progress.value = p,
                );

                if (context.mounted) {
                  Navigator.pop(context); // close progress dialog
                  if (path != null) {
                    await Share.shareXFiles([XFile(path)], subject: 'Music Backup');
                  } else {
                    AppSnackbar.show('Export Failed', 'No songs to export or an error occurred');
                  }
                }
              },
            ),

            const SizedBox(height: 10),

            _SettingsTile(
              icon: Icons.file_upload_outlined,
              iconColor: accentPurple,
              title: 'Import ZIP',
              subtitle: 'Restore songs from a Music ZIP backup',
              onTap: () async {
                final progress = 0.0.obs;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    backgroundColor: neuBase,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Importing ZIP'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Extracting and restoring songs...', style: TextStyle(color: textMid, fontSize: 13)),
                        const SizedBox(height: 20),
                        Obx(() => LinearProgressIndicator(
                          value: progress.value,
                          color: accentPurple,
                          backgroundColor: Colors.grey[300],
                        )),
                      ],
                    ),
                  ),
                );

                await Future.delayed(const Duration(milliseconds: 100));

                final (imported, skipped) = await zipImport.importFromZip(
                  onProgress: (p) => progress.value = p,
                );

                if (context.mounted) {
                  Navigator.pop(context); // close progress dialog
                  if (imported > 0 || skipped > 0) {
                    AppSnackbar.show(
                      '✅ Import Complete',
                      '$imported songs added, $skipped skipped',
                      duration: const Duration(seconds: 4),
                    );
                  } else {
                    AppSnackbar.show('Import Failed', 'No valid ZIP selected or error reading file');
                  }
                }
              },
            ),

            const SizedBox(height: 24),

            // ── Sleep Timer section ───────────────────────────────────────
            _SectionHeader(label: 'Sleep Timer'),
            const SizedBox(height: 8),

            Obx(() => sleepTimer.isActive.value
                ? _ActiveTimerCard(sleepTimer: sleepTimer)
                : _TimerPickerCard(sleepTimer: sleepTimer)),

            const SizedBox(height: 24),

            // ── About section ─────────────────────────────────────────────
            _SectionHeader(label: 'About'),
            const SizedBox(height: 8),

            NeuBox(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accentBlue, accentPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.music_note,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Music',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: textDark,
                        ),
                      ),
                      Text('Version 1.0.0',
                          style: TextStyle(fontSize: 12, color: textMid)),
                      Text('Personal offline music player',
                          style: TextStyle(fontSize: 11, color: textLight)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Settings tile ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeuButton(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: textDark)),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 11, color: textMid)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: textLight),
          ],
        ),
      ),
    );
  }
}

// ─── Active timer display ──────────────────────────────────────────────────────
class _ActiveTimerCard extends StatelessWidget {
  final SleepTimerService sleepTimer;
  const _ActiveTimerCard({required this.sleepTimer});

  @override
  Widget build(BuildContext context) {
    return NeuBox(
      inset: true,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.bedtime, color: accentBlue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sleep Timer Active',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: textDark)),
                Obx(() => Text(
                      'Stopping in ${sleepTimer.formattedRemaining}',
                      style: const TextStyle(fontSize: 12, color: accentBlue),
                    )),
              ],
            ),
          ),
          NeuButton(
            borderRadius: 10,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onTap: sleepTimer.cancelTimer,
            child: const Text('Cancel',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─── Timer preset picker ───────────────────────────────────────────────────────
class _TimerPickerCard extends StatelessWidget {
  final SleepTimerService sleepTimer;
  const _TimerPickerCard({required this.sleepTimer});

  static const _presets = [
    ('15m', 15 * 60),
    ('30m', 30 * 60),
    ('45m', 45 * 60),
    ('1h', 60 * 60),
    ('1.5h', 90 * 60),
  ];

  @override
  Widget build(BuildContext context) {
    return NeuBox(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bedtime_outlined, color: textMid, size: 20),
              SizedBox(width: 8),
              Text('Sleep Timer',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textDark)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets
                .map((p) => GestureDetector(
                      onTap: () => sleepTimer.startTimer(p.$2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: neuBase,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: neuSoftShadow,
                        ),
                        child: Text(
                          p.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: textDark,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
