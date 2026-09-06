// ────────────────────────────────────────────────────────────────────────────
// EmptyState & ErrorState — reusable fallback UI widgets
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/neumorphic_widget.dart';

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Neumorphic icon bubble
            NeuBox(
              borderRadius: 28,
              padding: const EdgeInsets.all(20),
              child: Icon(
                icon,
                size: 42,
                color: iconColor ?? textMid,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: textMid,
                  height: 1.4,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              NeuButton(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                onTap: onAction,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: accentBlue, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      actionLabel!,
                      style: const TextStyle(
                        color: accentBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.retryLabel,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon bubble with red tint
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: neuBase,
                borderRadius: BorderRadius.circular(28),
                boxShadow: neuRaisedShadow,
              ),
              child: Icon(icon, size: 42, color: Colors.redAccent.shade200),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade400,
                  height: 1.4,
                ),
              ),
            ),
            if (retryLabel != null && onRetry != null) ...[
              const SizedBox(height: 18),
              NeuButton(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                onTap: onRetry,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded,
                        color: accentBlue, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      retryLabel!,
                      style: const TextStyle(
                        color: accentBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Search Empty State (compact) ─────────────────────────────────────────────
class SearchEmptyState extends StatelessWidget {
  final String query;

  const SearchEmptyState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            NeuBox(
              borderRadius: 24,
              padding: const EdgeInsets.all(18),
              child:
                  const Icon(Icons.search_off, size: 36, color: textMid),
            ),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── File Not Found State ─────────────────────────────────────────────────────
class FileNotFoundState extends StatelessWidget {
  final String songTitle;
  final VoidCallback? onRemove;

  const FileNotFoundState({
    super.key,
    required this.songTitle,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: neuBase,
                borderRadius: BorderRadius.circular(28),
                boxShadow: neuRaisedShadow,
              ),
              child: const Icon(Icons.audio_file,
                  size: 42, color: textLight),
            ),
            const SizedBox(height: 18),
            const Text(
              'File Not Found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(height: 18),
              NeuButton(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                onTap: onRemove,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Remove from Library',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
