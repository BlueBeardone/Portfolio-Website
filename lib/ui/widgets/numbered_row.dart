import 'package:flutter/material.dart';

/// Width of the index column. Callers indent content beneath the title by this.
const double numberedRowIndexWidth = 34;

/// A hairline-separated row used by the Skills and History lists.
class NumberedRow extends StatelessWidget {
  const NumberedRow({
    super.key,
    required this.index,
    required this.title,
    this.meta,
    this.description,
    this.trailing,
  });

  final String index;
  final String title;
  final String? meta;
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final hasMeta = (meta ?? '').trim().isNotEmpty;
    final hasDescription = (description ?? '').trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: numberedRowIndexWidth,
            child: Text(index, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (hasMeta)
                      Text(meta!, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                  ],
                ),
                if (hasDescription)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      description!,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.5),
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
