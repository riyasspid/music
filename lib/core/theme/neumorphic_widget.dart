// ────────────────────────────────────────────────────────────────────────────
// Reusable Neumorphic widgets
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─── NeuBox: raised or inset container ───────────────────────────────────────
class NeuBox extends StatelessWidget {
  final Widget child;
  final bool inset;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const NeuBox({
    super.key,
    required this.child,
    this.inset = false,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? neuBase,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: inset ? neuInsetShadow : neuRaisedShadow,
      ),
      child: child,
    );
  }
}

// ─── NeuButton: pressable neumorphic button ───────────────────────────────────
class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const NeuButton({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 12,
    this.padding,
    this.color,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: widget.padding ?? const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.color ?? neuBase,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _pressed ? neuInsetShadow : neuRaisedShadow,
        ),
        child: widget.child,
      ),
    );
  }
}

// ─── NeuCircleButton: round neumorphic icon button ───────────────────────────
class NeuCircleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final bool isActive;

  const NeuCircleButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 56,
    this.color,
    this.isActive = false,
  });

  @override
  State<NeuCircleButton> createState() => _NeuCircleButtonState();
}

class _NeuCircleButtonState extends State<NeuCircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isInset = _pressed || widget.isActive;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.isActive
              ? const Color(0xFFD2DCEB)
              : (widget.color ?? neuBase),
          shape: BoxShape.circle,
          border: widget.isActive
              ? Border.all(color: accentBlue.withValues(alpha: 0.45), width: 1.5)
              : null,
          boxShadow: isInset ? neuInsetShadow : neuRaisedShadow,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

// ─── NeuCard: section card with slight elevation ─────────────────────────────
class NeuCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const NeuCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: neuBase,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: neuRaisedShadow,
      ),
      child: child,
    );
  }
}
