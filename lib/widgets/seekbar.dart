// ────────────────────────────────────────────────────────────────────────────
// Custom Neumorphic seek bar with time labels, drag-to-seek, and 0-gap thumb
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils.dart';

class SeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  bool _isDragging = false;
  int _dragMs = 0;

  void _handleDrag(double localDx, double totalWidth) {
    if (totalWidth <= 0) return;
    final ratio = (localDx / totalWidth).clamp(0.0, 1.0);
    final maxMs = widget.duration.inMilliseconds;
    final targetMs = (ratio * maxMs).round();
    setState(() {
      _dragMs = targetMs;
    });
    widget.onChanged?.call(Duration(milliseconds: targetMs));
  }

  void _finishDrag() {
    widget.onChangeEnd?.call(Duration(milliseconds: _dragMs));
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = widget.duration.inMilliseconds;
    final currentMs = _isDragging
        ? _dragMs
        : widget.position.inMilliseconds.clamp(0, maxMs > 0 ? maxMs : 0);

    final ratio = maxMs > 0 ? (currentMs / maxMs).clamp(0.0, 1.0) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Interactive seek bar with generous touch target ────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            final thumbRadius = 8.0;
            final trackHeight = 6.0;

            // Compute active track fill width and thumb center
            final activeWidth = (ratio * trackWidth).clamp(0.0, trackWidth);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) {
                setState(() => _isDragging = true);
                _handleDrag(details.localPosition.dx, trackWidth);
              },
              onHorizontalDragUpdate: (details) {
                _handleDrag(details.localPosition.dx, trackWidth);
              },
              onHorizontalDragEnd: (_) => _finishDrag(),
              onHorizontalDragCancel: () {
                setState(() => _isDragging = false);
              },
              onTapDown: (details) {
                _handleDrag(details.localPosition.dx, trackWidth);
                _finishDrag();
              },
              child: SizedBox(
                height: 36, // Comfortable touch target height
                width: double.infinity,
                child: Center(
                  child: SizedBox(
                    height: thumbRadius * 2 + 4,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Inset background track
                        Container(
                          height: trackHeight,
                          width: trackWidth,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3D9E2),
                            borderRadius: BorderRadius.circular(trackHeight / 2),
                            boxShadow: neuInsetShadow,
                          ),
                        ),

                        // Active gradient fill (meets thumb precisely with 0 gap)
                        Container(
                          height: trackHeight,
                          width: activeWidth,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [accentBlue, accentPurple],
                            ),
                            borderRadius: BorderRadius.circular(trackHeight / 2),
                          ),
                        ),

                        // Draggable thumb dot (positioned at activeWidth - thumbRadius)
                        Positioned(
                          left: (activeWidth - thumbRadius).clamp(
                            0.0,
                            trackWidth - (thumbRadius * 2),
                          ),
                          child: Container(
                            width: thumbRadius * 2,
                            height: thumbRadius * 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7BA6FF), accentBlue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accentBlue.withValues(alpha: 0.45),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                                const BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 2,
                                  offset: Offset(-1, -1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // ── Time labels ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppUtils.formatDuration((currentMs ~/ 1000).toInt()),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textMid,
                ),
              ),
              Text(
                AppUtils.formatDuration(widget.duration.inSeconds.toInt()),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textMid,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
