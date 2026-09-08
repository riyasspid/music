import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/neumorphic_widget.dart';
import '../core/utils.dart';
import '../data/models/playlist.dart';
import '../data/repositories/playlist_repository.dart';

class PlaylistPickerSheet extends StatelessWidget {
  final List<String> songIds;

  const PlaylistPickerSheet({super.key, required this.songIds});

  static Future<void> show(BuildContext context, List<String> songIds) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PlaylistPickerSheet(songIds: songIds),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<PlaylistRepository>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: neuBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add to Playlist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NeuButton(
              onTap: () async {
                final pl = await _showCreatePlaylistDialog(context);
                if (pl != null) {
                  for (final id in songIds) {
                    await repo.addSongToPlaylist(pl.id, id);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppSnackbar.show('Success', 'Added ${songIds.length} song(s) to ${pl.name}');
                  }
                }
              },
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: accentBlue),
                  SizedBox(width: 8),
                  Text(
                    'Create New Playlist',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: accentBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final playlists = repo.playlists;
              if (playlists.isEmpty) {
                return const Center(
                  child: Text(
                    'No playlists yet',
                    style: TextStyle(color: textMid),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final pl = playlists[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: neuBase,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: neuSoftShadow,
                      ),
                      child: const Icon(Icons.playlist_play, color: accentPurple),
                    ),
                    title: Text(
                      pl.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: textDark),
                    ),
                    subtitle: Text('${pl.songIds.length} songs', style: const TextStyle(color: textMid, fontSize: 12)),
                    onTap: () async {
                      for (final id in songIds) {
                        await repo.addSongToPlaylist(pl.id, id);
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        AppSnackbar.show('Success', 'Added ${songIds.length} song(s) to ${pl.name}');
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<Playlist?> _showCreatePlaylistDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<Playlist>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: neuBase,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Playlist'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Playlist Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: textMid)),
          ),
          TextButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                final pl = Playlist(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  songIds: [],
                  createdAt: DateTime.now(),
                );
                Get.find<PlaylistRepository>().save(pl);
                Navigator.pop(context, pl);
              }
            },
            child: const Text('Create', style: TextStyle(color: accentBlue)),
          ),
        ],
      ),
    );
  }
}
