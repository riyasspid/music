// ────────────────────────────────────────────────────────────────────────────
// Playlists Screen — grid of playlists with create/delete
// ────────────────────────────────────────────────────────────────────────────
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neumorphic_widget.dart';
import '../../data/models/playlist.dart';
import '../../data/repositories/playlist_repository.dart';
import '../../data/repositories/song_repository.dart';
import 'playlist_detail_screen.dart';
import '../../widgets/empty_state.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen>
    with AutomaticKeepAliveClientMixin {
  final _uuid = const Uuid();
  bool _isCreatingPlaylist = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final playlistRepo = Get.find<PlaylistRepository>();

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
                  const Expanded(
                    child: Text(
                      'Playlists',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ),
                  NeuButton(
                    borderRadius: 12,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    onTap: () => _createPlaylist(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: accentBlue),
                        SizedBox(width: 4),
                        Text(
                          'New',
                          style: TextStyle(
                              color: accentBlue, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Grid
            Expanded(
              child: Obx(() {
                final playlists = playlistRepo.playlists;

                if (playlists.isEmpty) {
                  return EmptyState(
                    icon: Icons.queue_music,
                    title: 'No playlists yet',
                    actionLabel: 'Create Playlist',
                    onAction: () => _createPlaylist(context),
                    iconColor: accentPurple,
                  );
                }

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: playlists.length,
                  itemBuilder: (_, i) => _PlaylistCard(
                    playlist: playlists[i],
                    onTap: () async {
                      await Get.to(
                          () => PlaylistDetailScreen(
                              playlist: playlists[i]),
                          transition: Transition.rightToLeft);
                    },
                    onDelete: () async {
                      await playlistRepo.delete(playlists[i].id);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPlaylist(BuildContext context) async {
    if (_isCreatingPlaylist) return;
    _isCreatingPlaylist = true;
    try {
      final ctrl = TextEditingController();
      final name = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: neuBase,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('New Playlist'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Playlist name...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Create'),
            ),
          ],
        ),
      );
      if (name != null && name.isNotEmpty) {
        final pl = Playlist(
          id: _uuid.v4(),
          name: name,
          songIds: [],
          createdAt: DateTime.now(),
        );
        await Get.find<PlaylistRepository>().save(pl);
        setState(() {});
      }
    } finally {
      _isCreatingPlaylist = false;
    }
  }
}

// ─── Playlist card ────────────────────────────────────────────────────────────
class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PlaylistCard(
      {required this.playlist,
      required this.onTap,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final songRepo = Get.find<SongRepository>();
    final songs = playlist.songIds
        .map(songRepo.getById)
        .whereType<dynamic>()
        .take(4)
        .toList();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          color: neuBase,
          borderRadius: BorderRadius.circular(18),
          boxShadow: neuRaisedShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover collage
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Container(
                height: 120,
                color: const Color(0xFFD0D8E4),
                child: songs.isEmpty
                    ? const Center(
                        child: Icon(Icons.queue_music,
                            size: 40, color: textMid))
                    : GridView.count(
                        crossAxisCount: 2,
                        physics: const NeverScrollableScrollPhysics(),
                        children: songs.map((s) {
                          final coverPath = (s as dynamic).coverPath as String?;
                          return coverPath != null &&
                                  File(coverPath).existsSync()
                              ? Image.file(File(coverPath), fit: BoxFit.cover)
                              : const ColoredBox(
                                  color: Color(0xFFC4CFD8),
                                  child: Icon(Icons.music_note,
                                      color: textMid));
                        }).toList(),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Text(
                playlist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: textDark,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '${playlist.songIds.length} songs',
                style: const TextStyle(fontSize: 11, color: textMid),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
