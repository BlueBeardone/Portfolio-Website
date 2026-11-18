import 'package:flutter/material.dart';

import 'numbered_row.dart';

/// A sub-entry shown beneath a [NumberedRow]: indented past the index column so
/// it reads as part of the entry above it, with an accent dash and its detail
/// in muted text.
class IndentedChildRow extends StatelessWidget {
  const IndentedChildRow({super.key, required this.title, this.description = ''});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final accent = theme.colorScheme.primary;
    final hasDescription = description.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(left: numberedRowIndexWidth),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('—', style: text.bodySmall?.copyWith(color: accent)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (hasDescription)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(description, style: text.bodySmall),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
