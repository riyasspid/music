// ────────────────────────────────────────────────────────────────────────────
// QueueSheet — draggable bottom sheet showing the current play queue
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme.dart';
import '../services/audio_provider.dart';
import 'song_tile.dart';
import 'empty_state.dart';

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  static bool _isOpen = false;

  static void show(BuildContext context) {
    if (_isOpen) return;
    _isOpen = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const QueueSheet(),
    ).whenComplete(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioProvider>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: neuBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFA3B1C6),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: neuDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.queue_music, color: accentBlue),
                SizedBox(width: 8),
                Text(
                  'Play Queue',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final q = audio.queue;
              if (q.isEmpty) {
                return const EmptyState(
                  icon: Icons.queue_music,
                  title: 'Queue is empty',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: q.length,
                itemBuilder: (_, i) => Obx(() => SongTile(
                      song: q[i],
                      isPlaying: audio.currentIndex.value == i,
                      onTap: () async {
                        await audio.skipToIndex(i);
                        if (context.mounted) Navigator.pop(context);
                      },
                    )),
              );
            }),
          ),
        ],
      ),
    );
  }
}
