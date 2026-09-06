// ────────────────────────────────────────────────────────────────────────────
// Player Screen — full-screen music player
// ────────────────────────────────────────────────────────────────────────────
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neumorphic_widget.dart';
import '../../services/audio_provider.dart';
import '../../widgets/seekbar.dart';
import '../../widgets/queue_sheet.dart';
import '../../widgets/empty_state.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioProvider>();

    return Scaffold(
      backgroundColor: neuBase,
      body: SafeArea(
        child: Obx(() {
          final song = audio.currentSong.value;
          if (song == null) {
            return Column(
              children: [
                // Back button even on empty state
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: NeuCircleButton(
                      size: 40,
                      onTap: () => Get.back(),
                      child: const Icon(Icons.keyboard_arrow_down,
                          color: textMid, size: 22),
                    ),
                  ),
                ),
                Expanded(
                  child: const EmptyState(
                    icon: Icons.headphones_outlined,
                    title: 'Nothing playing',
                    iconColor: accentBlue,
                  ),
                ),
              ],
            );
          }

          // File deleted from disk — show error
          final fileExists = File(song.filePath).existsSync();
          if (!fileExists) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: NeuCircleButton(
                      size: 40,
                      onTap: () => Get.back(),
                      child: const Icon(Icons.keyboard_arrow_down,
                          color: textMid, size: 22),
                    ),
                  ),
                ),
                Expanded(
                  child: FileNotFoundState(
                    songTitle: song.title,
                    onRemove: () async {
                      await audio.stop();
                      Get.back();
                    },
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    NeuCircleButton(
                      size: 40,
                      onTap: () => Get.back(),
                      child: const Icon(Icons.keyboard_arrow_down,
                          color: textMid, size: 22),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Now Playing',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textMid,
                          ),
                        ),
                      ),
                    ),
                    NeuCircleButton(
                      size: 40,
                      onTap: () => QueueSheet.show(context),
                      child: const Icon(Icons.queue_music,
                          color: textMid, size: 20),
                    ),
                  ],
                ),
              ),

              // ── Album art (animated) ─────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Center(
                    child: Obx(() => _AlbumArt(
                          coverPath: song.coverPath,
                          isPlaying: audio.isPlaying.value,
                        )),
                  ),
                ),
              ),

              // ── Song info ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.author,
                            style:
                                const TextStyle(fontSize: 14, color: textMid),
                          ),
                        ],
                      ),
                    ),
                    // Like button
                    Obx(() => GestureDetector(
                          onTap: () => audio.toggleLike(song),
                          child: NeuCircleButton(
                            size: 44,
                            child: Icon(
                              audio.currentSong.value?.isLiked == true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  audio.currentSong.value?.isLiked == true
                                      ? likeRed
                                      : textMid,
                              size: 22,
                            ),
                          ),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Seek bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() => SeekBar(
                      position: audio.position.value,
                      duration: audio.duration.value,
                      onChangeEnd: audio.seekTo,
                    )),
              ),

              const SizedBox(height: 24),

              // ── Main controls ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous
                    NeuCircleButton(
                      size: 52,
                      onTap: audio.previous,
                      child: const Icon(Icons.skip_previous_rounded,
                          color: textDark, size: 28),
                    ),
                    // Seek back 15s
                    NeuCircleButton(
                      size: 46,
                      onTap: () =>
                          audio.seekRelative(const Duration(seconds: -15)),
                      child: const Icon(Icons.replay_10, color: textMid, size: 24),
                    ),
                    // Play/Pause (large)
                    Obx(() => GestureDetector(
                          onTap: audio.togglePlayPause,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [accentBlue, accentPurple],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentBlue.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              audio.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        )),
                    // Seek forward 15s
                    NeuCircleButton(
                      size: 46,
                      onTap: () =>
                          audio.seekRelative(const Duration(seconds: 15)),
                      child: const Icon(Icons.forward_10, color: textMid, size: 24),
                    ),
                    // Next
                    NeuCircleButton(
                      size: 52,
                      onTap: audio.next,
                      child: const Icon(Icons.skip_next_rounded,
                          color: textDark, size: 28),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Secondary controls ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle
                    Obx(() => _SecondaryButton(
                          icon: Icons.shuffle_rounded,
                          active: audio.isShuffle.value,
                          onTap: audio.toggleShuffle,
                          label: 'Shuffle',
                        )),
                    // Loop
                    Obx(() => _LoopButton(loopMode: audio.loopMode.value,
                        onTap: audio.cycleLoopMode)),
                    // Add to queue
                    _SecondaryButton(
                      icon: Icons.playlist_add,
                      active: false,
                      onTap: () => QueueSheet.show(context),
                      label: 'Queue',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Animated album art ───────────────────────────────────────────────────────
class _AlbumArt extends StatefulWidget {
  final String? coverPath;
  final bool isPlaying;

  const _AlbumArt({this.coverPath, required this.isPlaying});

  @override
  State<_AlbumArt> createState() => _AlbumArtState();
}

class _AlbumArtState extends State<_AlbumArt>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = Tween(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    if (widget.isPlaying) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_AlbumArt old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isPlaying && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: neuBase,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            const BoxShadow(
              color: Color(0xFFFFFFFF),
              blurRadius: 20,
              offset: Offset(-8, -8),
            ),
            BoxShadow(
              color: const Color(0xFFA3B1C6),
              blurRadius: 20,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: widget.coverPath != null && File(widget.coverPath!).existsSync()
              ? Image.file(File(widget.coverPath!), fit: BoxFit.cover)
              : Container(
                  color: const Color(0xFFD0D8E4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.music_note,
                          size: 80, color: textMid),
                      const SizedBox(height: 12),
                      Text(
                        'No Cover Art',
                        style: TextStyle(color: textLight, fontSize: 13),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Secondary control button ─────────────────────────────────────────────────
class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String label;

  const _SecondaryButton({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          NeuCircleButton(
            size: 44,
            child: Icon(
              icon,
              color: active ? accentBlue : textMid,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 10,
                color: active ? accentBlue : textLight,
              )),
        ],
      ),
    );
  }
}

class _LoopButton extends StatelessWidget {
  final LoopMode loopMode;
  final VoidCallback onTap;

  const _LoopButton({required this.loopMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = loopMode != LoopMode.off;
    final icon = loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat;
    final label = switch (loopMode) {
      LoopMode.off => 'Loop',
      LoopMode.all => 'Loop All',
      LoopMode.one => 'Loop 1',
    };

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          NeuCircleButton(
            size: 44,
            child: Icon(icon, color: active ? accentBlue : textMid, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 10,
                color: active ? accentBlue : textLight,
              )),
        ],
      ),
    );
  }
}
