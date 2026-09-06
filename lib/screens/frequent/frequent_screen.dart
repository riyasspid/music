// ────────────────────────────────────────────────────────────────────────────
// Frequent Screen — songs ranked by play count
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neumorphic_widget.dart';
import '../../data/repositories/song_repository.dart';
import '../../services/audio_provider.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/empty_state.dart';

class FrequentScreen extends StatelessWidget {
  const FrequentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<SongRepository>();
    final audio = Get.find<AudioProvider>();
    final songs = repo.getFrequent();

    return Scaffold(
      backgroundColor: neuBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  NeuBox(
                    borderRadius: 12,
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.trending_up,
                        color: accentBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequent Plays',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                      Text(
                        'Your most-played tracks',
                        style: TextStyle(fontSize: 12, color: textMid),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Song list
            Expanded(
              child: songs.isEmpty
                  ? const EmptyState(
                      icon: Icons.trending_up_rounded,
                      title: 'No play history yet',
                      iconColor: accentBlue,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 110),
                      itemCount: songs.length,
                      itemBuilder: (_, i) {
                        final song = songs[i];
                        return Obx(() => SongTile(
                              song: song,
                              isPlaying:
                                  audio.currentSong.value?.id == song.id,
                              showPlayCount: true,
                              onTap: () =>
                                  audio.playSong(song, songList: songs),
                              onLike: () => audio.toggleLike(song),
                              onAddToQueue: () => audio.addToQueue(song),
                            ));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
