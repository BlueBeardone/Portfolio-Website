import 'package:flutter/material.dart';

import 'hairline.dart';

/// One row of the identity panel's link list: label, small arrow, hairline.
class LinkRow extends StatelessWidget {
  const LinkRow({super.key, required this.label, required this.url, this.onTap});

  final String label;
  final String url;
  final void Function(String url)? onTap;

  bool get _enabled => url.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _enabled ? () => onTap?.call(url) : null,
          hoverColor: theme.colorScheme.primary.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _enabled ? theme.colorScheme.onSurface : muted,
                    ),
                  ),
                ),
                Text(
                  '↗',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
        ),
        Hairline(color: theme.dividerTheme.color),
      ],
    );
  }
}
