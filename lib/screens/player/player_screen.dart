// ────────────────────────────────────────────────────────────────────────────
// Player Screen — full-screen music player
// ────────────────────────────────────────────────────────────────────────────
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/neumorphic_widget.dart';
import '../../data/repositories/song_repository.dart';
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
                    Obx(() {
                      final isLiked =
                          Get.find<SongRepository>().isLiked(song.id);
                      return GestureDetector(
                        onTap: () => audio.toggleLike(song),
                        child: NeuCircleButton(
                          size: 44,
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? likeRed : textMid,
                            size: 22,
                          ),
                        ),
                      );
                    }),
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
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous
                    NeuCircleButton(
                      size: 58,
                      onTap: audio.previous,
                      child: const Icon(Icons.skip_previous_rounded,
                          color: textDark, size: 32),
                    ),
                    // Play/Pause (large)
                    Obx(() => GestureDetector(
                          onTap: audio.togglePlayPause,
                          child: Container(
                            width: 74,
                            height: 74,
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
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              audio.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        )),
                    // Next
                    NeuCircleButton(
                      size: 58,
                      onTap: audio.next,
                      child: const Icon(Icons.skip_next_rounded,
                          color: textDark, size: 32),
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

// ─── Rotating Vinyl Disk Album Art ───────────────────────────────────────────
class _AlbumArt extends StatefulWidget {
  final String? coverPath;
  final bool isPlaying;

  const _AlbumArt({this.coverPath, required this.isPlaying});

  @override
  State<_AlbumArt> createState() => _AlbumArtState();
}

class _AlbumArtState extends State<_AlbumArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18), // Slow, realistic vinyl rotation
    );
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(_AlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!widget.isPlaying && _rotationController.isAnimating) {
      _rotationController.stop(); // Pauses right at current rotation angle
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxAvailable = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight - 20
            : 280.0;
        final double diskSize = maxAvailable.clamp(200.0, 280.0);

        return Center(
          child: Container(
            width: diskSize,
            height: diskSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 16,
                  offset: Offset(-6, -6),
                ),
                BoxShadow(
                  color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(6, 6),
                ),
              ],
            ),
            child: RotationTransition(
              turns: _rotationController,
              child: _VinylDisc(
                coverPath: widget.coverPath,
                size: diskSize,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VinylDisc extends StatelessWidget {
  final String? coverPath;
  final double size;

  const _VinylDisc({required this.coverPath, required this.size});

  @override
  Widget build(BuildContext context) {
    final spindleSize = size * 0.14;

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Cover image filling the entire circular disk space ─────────────
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD0D8E4),
          ),
          child: ClipOval(
            child: coverPath != null && File(coverPath!).existsSync()
                ? Image.file(
                    File(coverPath!),
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                  )
                : Container(
                    color: const Color(0xFFD0D8E4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.music_note_rounded,
                            size: 64, color: accentBlue),
                        SizedBox(height: 6),
                        Text(
                          'No Cover Art',
                          style: TextStyle(
                            color: textMid,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),

        // ── Subtle glossy disc sheen reflection ───────────────────────────
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),
        ),

        // ── Subtle outer disc edge ring ───────────────────────────────────
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 2.0,
            ),
          ),
        ),

        // ── Center spindle metallic ring & hole ───────────────────────────
        Container(
          width: spindleSize,
          height: spindleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFA3B1C6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: spindleSize * 0.45,
              height: spindleSize * 0.45,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: neuBase,
              ),
            ),
          ),
        ),
      ],
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
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeuCircleButton(
            size: 46,
            isActive: active,
            onTap: onTap,
            child: Icon(
              icon,
              color: active ? accentBlue : textDark,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? accentBlue : textMid,
            ),
          ),
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
    final icon = loopMode == LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded;
    final label = switch (loopMode) {
      LoopMode.off => 'Loop Off',
      LoopMode.all => 'Loop All',
      LoopMode.one => 'Loop 1',
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeuCircleButton(
            size: 46,
            isActive: active,
            onTap: onTap,
            child: Icon(
              icon,
              color: active ? accentBlue : textDark,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? accentBlue : textMid,
            ),
          ),
        ],
      ),
    );
  }
}
