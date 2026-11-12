import 'package:flutter/material.dart';

import '../../core/theme.dart';

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title,
    this.icon,
    this.iconSize,
    this.compact = false,
    this.filledButton = false,
    this.iconColor,
    this.messageStyle,
    this.titleStyle,
    this.retryIcon,
    this.alignment = CrossAxisAlignment.center,
  });

  final String message;
  final VoidCallback onRetry;
  final String? title;
  final IconData? icon;
  final double? iconSize;
  final bool compact;
  final bool filledButton;
  final Color? iconColor;
  final TextStyle? messageStyle;
  final TextStyle? titleStyle;
  final IconData? retryIcon;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (icon != null) {
      children
        ..add(
          Icon(
            icon,
            size: iconSize ?? (compact ? 20 : 40),
            color: iconColor ?? WarnaJosBook.merah,
          ),
        )
        ..add(SizedBox(height: compact ? 6 : 12));
    }
    if (title != null) {
      children
        ..add(
          Text(
            title!,
            textAlign: alignment == CrossAxisAlignment.start
                ? TextAlign.left
                : TextAlign.center,
            style:
                titleStyle ??
                const TextStyle(
                  color: WarnaJosBook.teks,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
          ),
        )
        ..add(const SizedBox(height: 4));
    }
    children.add(
      Text(
        message,
        textAlign: alignment == CrossAxisAlignment.start
            ? TextAlign.left
            : TextAlign.center,
        style:
            messageStyle ??
            const TextStyle(color: WarnaJosBook.merah, fontSize: 13),
      ),
    );
    children.add(SizedBox(height: compact ? 2 : 8));
    if (filledButton) {
      children.add(
        FilledButton(
          onPressed: onRetry,
          style: FilledButton.styleFrom(backgroundColor: WarnaJosBook.navy),
          child: const Text('Coba lagi'),
        ),
      );
    } else if (retryIcon != null) {
      children.add(
        TextButton.icon(
          onPressed: onRetry,
          icon: Icon(retryIcon, size: 18),
          label: const Text('Coba lagi'),
        ),
      );
    } else {
      children.add(
        TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: children,
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.iconSize = 44,
    this.iconColor = const Color(0xFF718096),
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    this.textStyle,
    this.titleStyle,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final double iconSize;
  final Color iconColor;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(height: 10),
          ],
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style:
                  titleStyle ??
                  const TextStyle(
                    color: WarnaJosBook.teks,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                textStyle ??
                const TextStyle(color: Color(0xFF718096), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
