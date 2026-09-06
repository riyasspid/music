// ────────────────────────────────────────────────────────────────────────────
// Playlist Detail Screen — shows songs in a playlist with Play All / Shuffle
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neumorphic_widget.dart';
import '../../data/models/playlist.dart';
import '../../data/models/song.dart';
import '../../data/repositories/playlist_repository.dart';
import '../../data/repositories/song_repository.dart';
import '../../services/audio_provider.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/empty_state.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<Song> _getSongs() {
    final repo = Get.find<SongRepository>();
    return widget.playlist.songIds
        .map(repo.getById)
        .whereType<Song>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioProvider>();
    final songs = _getSongs();

    return Scaffold(
      backgroundColor: neuBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  NeuCircleButton(
                    size: 40,
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back,
                        color: textMid, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.playlist.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        Text(
                          '${songs.length} songs',
                          style:
                              const TextStyle(fontSize: 12, color: textMid),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Play All / Shuffle buttons
            if (songs.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: NeuButton(
                        borderRadius: 14,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onTap: () async {
                          await audio.playSong(songs.first, songList: songs);
                          // Ensure shuffle is OFF for Play All
                          if (audio.isShuffle.value) await audio.toggleShuffle();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                color: accentBlue, size: 20),
                            SizedBox(width: 6),
                            Text('Play All',
                                style: TextStyle(
                                    color: accentBlue,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeuButton(
                        borderRadius: 14,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onTap: () async {
                          await audio.playSong(songs.first, songList: songs);
                          await audio.toggleShuffle();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shuffle_rounded,
                                color: accentPurple, size: 20),
                            SizedBox(width: 6),
                            Text('Shuffle',
                                style: TextStyle(
                                    color: accentPurple,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Song list
            Expanded(
              child: songs.isEmpty
                  ? const EmptyState(
                      icon: Icons.playlist_add,
                      title: 'Playlist is empty',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 100),
                      itemCount: songs.length,
                      itemBuilder: (_, i) {
                        final song = songs[i];
                        return Obx(() => SongTile(
                              song: song,
                              isPlaying:
                                  audio.currentSong.value?.id == song.id,
                              onTap: () =>
                                  audio.playSong(song, songList: songs),
                              onLike: () => audio.toggleLike(song),
                              onDelete: () async {
                                await Get.find<PlaylistRepository>()
                                    .removeSongFromPlaylist(
                                        widget.playlist.id, song.id);
                                setState(() {});
                              },
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


