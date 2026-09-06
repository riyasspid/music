// ────────────────────────────────────────────────────────────────────────────
// Home Screen — Recommended, Recently Added, Liked Songs shortcut
// ────────────────────────────────────────────────────────────────────────────
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neumorphic_widget.dart';
import '../../core/utils.dart';
import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import '../../services/audio_provider.dart';
import '../../services/import_service.dart';
import '../../widgets/empty_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<SongRepository>();
    final audio = Get.find<AudioProvider>();
    final recent = repo.getRecent(limit: 10);
    final frequent = repo.getFrequent(limit: 6);
    final liked = repo.getLiked();

    return Scaffold(
      backgroundColor: neuBase,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppUtils.greeting(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: textMid,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            'Music',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    NeuCircleButton(
                      size: 44,
                      child: const Icon(Icons.search, color: textMid, size: 20),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // ── Liked Songs shortcut ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: GestureDetector(
                  onTap: () {
                    // Show liked songs (navigate to filtered library)
                    Get.snackbar('Liked Songs', '${liked.length} songs liked');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5E7E), Color(0xFFFF9966)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5E7E).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Liked Songs',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${liked.length} songs',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.play_circle_fill,
                            color: Colors.white, size: 38),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Recommended ───────────────────────────────────────────────
            if (frequent.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Text(
                    'Recommended For You',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: textDark,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: frequent.length,
                    itemBuilder: (_, i) =>
                        _SongCard(song: frequent[i], audio: audio),
                  ),
                ),
              ),
            ],

            // ── Recently Added ────────────────────────────────────────────
            if (recent.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Recently Added',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: textDark,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final song = recent[i];
                    return Obx(() => _RecentTile(
                          song: song,
                          isPlaying:
                              audio.currentSong.value?.id == song.id,
                          onTap: () =>
                              audio.playSong(song, songList: recent),
                        ));
                  },
                  childCount: recent.take(5).length,
                ),
              ),
            ],

            // Empty state — no songs in library at all
            if (recent.isEmpty && frequent.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.music_note_outlined,
                  title: 'Your library is empty',
                  actionLabel: 'Import a Song',
                  onAction: () async {
                    final svc = Get.find<ImportService>();
                    await svc.importSingleSong(context);
                  },
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}

// ─── Horizontal song card ─────────────────────────────────────────────────────
class _SongCard extends StatelessWidget {
  final Song song;
  final AudioProvider audio;

  const _SongCard({required this.song, required this.audio});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => audio.playSong(song),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: neuBase,
          borderRadius: BorderRadius.circular(16),
          boxShadow: neuRaisedShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 100,
                width: double.infinity,
                color: const Color(0xFFD0D8E4),
                child: song.coverPath != null &&
                        File(song.coverPath!).existsSync()
                    ? Image.file(File(song.coverPath!), fit: BoxFit.cover)
                    : const Icon(Icons.music_note,
                        size: 40, color: textMid),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                song.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: textMid),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent song tile (compact) ───────────────────────────────────────────────
class _RecentTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback? onTap;

  const _RecentTile(
      {required this.song, this.isPlaying = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: neuBase,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPlaying ? neuInsetShadow : neuSoftShadow,
      ),
      child: ListTile(
        dense: true,
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: neuBase,
            borderRadius: BorderRadius.circular(8),
            boxShadow: neuSoftShadow,
            image: song.coverPath != null && File(song.coverPath!).existsSync()
                ? DecorationImage(
                    image: FileImage(File(song.coverPath!)),
                    fit: BoxFit.cover)
                : null,
          ),
          child: (song.coverPath == null || !File(song.coverPath!).existsSync())
              ? Icon(Icons.music_note,
                  size: 18, color: isPlaying ? accentBlue : textMid)
              : null,
        ),
        title: Text(
          song.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isPlaying ? accentBlue : textDark,
          ),
        ),
        subtitle: Text(song.author,
            style: const TextStyle(fontSize: 11, color: textMid)),
        trailing: Text(song.durationFormatted,
            style: const TextStyle(fontSize: 11, color: textLight)),
      ),
    );
  }
}
