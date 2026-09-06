// ────────────────────────────────────────────────────────────────────────────
// Custom Neumorphic seek bar with time labels
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
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final progress = widget.duration.inMilliseconds > 0
        ? (_dragValue ??
                widget.position.inMilliseconds.toDouble().clamp(
                    0.0, widget.duration.inMilliseconds.toDouble()))
            .toDouble()
        : 0.0;

    final max = widget.duration.inMilliseconds.toDouble();

    return Column(
      children: [
        Container(
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: neuBase,
            borderRadius: BorderRadius.circular(3),
            boxShadow: neuInsetShadow,
          ),
          child: Stack(
            children: [
              // Progress fill
              FractionallySizedBox(
                widthFactor: max > 0 ? (progress / max).clamp(0.0, 1.0) : 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [accentBlue, accentPurple],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Invisible slider for interaction
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: accentBlue,
                  overlayColor: accentBlue.withValues(alpha: 0.2),
                ),
                child: Slider(
                  min: 0,
                  max: max > 0 ? max : 1,
                  value: progress.clamp(0, max > 0 ? max : 1),
                  onChanged: (v) {
                    setState(() => _dragValue = v);
                    widget.onChanged?.call(Duration(milliseconds: v.toInt()));
                  },
                  onChangeEnd: (v) {
                    widget.onChangeEnd?.call(Duration(milliseconds: v.toInt()));
                    setState(() => _dragValue = null);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppUtils.formatDuration(
                    (_dragValue != null
                            ? _dragValue! ~/ 1000
                            : widget.position.inSeconds)
                        .toInt()),
                style: const TextStyle(fontSize: 12, color: textMid),
              ),
              Text(
                AppUtils.formatDuration(widget.duration.inSeconds.toInt()),
                style: const TextStyle(fontSize: 12, color: textMid),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
