// ────────────────────────────────────────────────────────────────────────────
// SongTile — reusable song list row with cover art, title, author, duration
// ────────────────────────────────────────────────────────────────────────────
import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onDelete;
  final bool? isLiked;
  final VoidCallback? onAddToQueue;
  final bool showPlayCount;

  const SongTile({
    super.key,
    required this.song,
    this.isPlaying = false,
    this.isLiked,
    this.onTap,
    this.onLike,
    this.onDelete,
    this.onAddToQueue,
    this.showPlayCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: neuBase,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isPlaying ? neuInsetShadow : neuRaisedShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        onTap: onTap,
        leading: _CoverArt(coverPath: song.coverPath, isPlaying: isPlaying),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isPlaying ? accentBlue : textDark,
          ),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                song.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: textMid),
              ),
            ),
            if (showPlayCount)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${song.playCount}×',
                  style: const TextStyle(fontSize: 10, color: accentBlue),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              song.durationFormatted,
              style: const TextStyle(fontSize: 11, color: textLight),
            ),
            const SizedBox(width: 2),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onLike,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  (isLiked ?? song.isLiked)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: (isLiked ?? song.isLiked) ? likeRed : textLight,
                  size: 20,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: textLight),
              color: neuBase,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'queue') onAddToQueue?.call();
                if (value == 'delete') onDelete?.call();
                if (value == 'like') onLike?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'queue',
                  child: Text('Add to Queue'),
                ),
                PopupMenuItem(
                  value: 'like',
                  child: Text((isLiked ?? song.isLiked) ? 'Unlike' : 'Like'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverArt extends StatelessWidget {
  final String? coverPath;
  final bool isPlaying;

  const _CoverArt({this.coverPath, this.isPlaying = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: neuBase,
        borderRadius: BorderRadius.circular(10),
        boxShadow: neuSoftShadow,
        image: coverPath != null && File(coverPath!).existsSync()
            ? DecorationImage(
                image: FileImage(File(coverPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: coverPath == null || !File(coverPath!).existsSync()
          ? Icon(
              isPlaying ? Icons.graphic_eq : Icons.music_note,
              color: isPlaying ? accentBlue : textMid,
              size: 22,
            )
          : isPlaying
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.graphic_eq,
                      color: Colors.white, size: 22),
                )
              : null,
    );
  }
}
