// ────────────────────────────────────────────────────────────────────────────
// MiniPlayer — persistent player bar shown above the bottom navigation bar
// ────────────────────────────────────────────────────────────────────────────
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme.dart';
import '../services/audio_provider.dart';
import '../screens/player/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioProvider>();
    return Obx(() {
      final song = audio.currentSong.value;
      if (song == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.to(() => const PlayerScreen(),
            transition: Transition.upToDown),
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: neuBase,
            borderRadius: BorderRadius.circular(18),
            boxShadow: neuRaisedShadow,
          ),
          child: Row(
            children: [
              // Cover art
              Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: neuBase,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: neuSoftShadow,
                  image: song.coverPath != null &&
                          File(song.coverPath!).existsSync()
                      ? DecorationImage(
                          image: FileImage(File(song.coverPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (song.coverPath == null ||
                        !File(song.coverPath!).existsSync())
                    ? const Icon(Icons.music_note, color: accentBlue, size: 22)
                    : null,
              ),

              // Title + artist
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: textMid),
                    ),
                  ],
                ),
              ),

              // Like button
              Obx(() => IconButton(
                    icon: Icon(
                      audio.currentSong.value?.isLiked == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: audio.currentSong.value?.isLiked == true
                          ? likeRed
                          : textMid,
                      size: 20,
                    ),
                    onPressed: () => audio.toggleLike(song),
                  )),

              // Play/Pause
              Obx(() => _ControlButton(
                    icon: audio.isPlaying.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onTap: audio.togglePlayPause,
                  )),

              // Next
              _ControlButton(
                icon: Icons.skip_next_rounded,
                onTap: audio.next,
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      );
    });
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ControlButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: neuBase,
          shape: BoxShape.circle,
          boxShadow: neuSoftShadow,
        ),
        child: Icon(icon, color: accentBlue, size: 20),
      ),
    );
  }
}
