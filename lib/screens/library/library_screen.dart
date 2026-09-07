// ────────────────────────────────────────────────────────────────────────────
// Library Screen — full searchable song list with sort options
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neumorphic_widget.dart';
import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import '../../services/audio_provider.dart';
import '../../services/import_service.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/empty_state.dart';
import '../../core/utils.dart';

enum _SortMode { az, dateAdded, mostPlayed, duration }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchCtrl = TextEditingController();
  _SortMode _sort = _SortMode.dateAdded;
  String _query = '';
  bool _isDeleting = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Song> _getSongs(SongRepository repo) {
    var songs = repo.getAll();

    // Filter
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      songs = songs
          .where((s) =>
              s.title.toLowerCase().contains(q) ||
              s.author.toLowerCase().contains(q))
          .toList();
    }

    // Sort
    switch (_sort) {
      case _SortMode.az:
        songs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case _SortMode.dateAdded:
        songs.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
      case _SortMode.mostPlayed:
        songs.sort((a, b) => b.playCount.compareTo(a.playCount));
        break;
      case _SortMode.duration:
        songs.sort((a, b) => b.seconds.compareTo(a.seconds));
        break;
    }
    return songs;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final audio = Get.find<AudioProvider>();
    final repo = Get.find<SongRepository>();
    final importSvc = Get.find<ImportService>();

    return Scaffold(
      backgroundColor: neuBase,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Library',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ),
                  Obx(() => Text(
                        '${repo.songs.length} songs',
                        style: const TextStyle(fontSize: 12, color: textMid),
                      )),
                ],
              ),
            ),

            // ── Search bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: NeuBox(
                inset: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                borderRadius: 14,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Search songs, artists...',
                    hintStyle: TextStyle(fontSize: 13, color: textLight),
                    prefixIcon: Icon(Icons.search, color: textMid, size: 20),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Sort chips ────────────────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _SortMode.values
                    .map((mode) => _SortChip(
                          label: switch (mode) {
                            _SortMode.az => 'A–Z',
                            _SortMode.dateAdded => 'Date Added',
                            _SortMode.mostPlayed => 'Most Played',
                            _SortMode.duration => 'Duration',
                          },
                          selected: _sort == mode,
                          onTap: () => setState(() => _sort = mode),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 6),

            // ── Song list ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final songs = _getSongs(repo);

                if (songs.isEmpty) {
                  return _query.isNotEmpty
                      // Search returned nothing
                      ? SearchEmptyState(query: _query)
                      // Library is completely empty
                      : EmptyState(
                          icon: Icons.library_music_outlined,
                          title: 'Library is empty',
                          actionLabel: 'Import Song',
                          onAction: () async {
                            await importSvc.importSingleSong(context);
                          },
                        );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 110),
                  itemCount: songs.length,
                  itemBuilder: (_, i) {
                    final song = songs[i];
                    return Obx(() => SongTile(
                          song: song,
                          isLiked: repo.isLiked(song.id),
                          isPlaying: audio.currentSong.value?.id == song.id,
                          onTap: () => audio.playSong(song, songList: songs),
                          onLike: () => audio.toggleLike(song),
                          onDelete: () => _deleteSong(song),
                          onAddToQueue: () => audio.addToQueue(song),
                        ));
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        final hasSongs = repo.songs.isNotEmpty;
        if (!hasSongs) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: NeuButton(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            onTap: () async {
              final song = await importSvc.importSingleSong(context);
              if (song != null && context.mounted) {
                AppSnackbar.show(
                  '✅ Imported!',
                  '"${song.title}" added to library',
                );
              }
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: accentBlue),
                SizedBox(width: 6),
                Text(
                  'Import Song',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: accentBlue),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _deleteSong(Song song) async {
    if (_isDeleting) return;
    _isDeleting = true;
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: neuBase,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Song'),
          content: Text('Delete "${song.title}"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await Get.find<SongRepository>().delete(song.id);
        AppSnackbar.show('Deleted', '"${song.title}" removed from library');
      }
    } finally {
      _isDeleting = false;
    }
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? accentBlue : neuBase,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected ? [] : neuSoftShadow,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : textMid,
          ),
        ),
      ),
    );
  }
}
