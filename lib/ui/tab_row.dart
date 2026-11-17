import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The Skills / History / About selector. Labels come straight from the data
/// file; the underline slides between tabs and arrow keys move the selection.
class TabRow extends StatelessWidget {
  const TabRow({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelect,
    required this.accent,
  });

  final List<String> labels;
  final int selected;
  final void Function(int index) onSelect;
  final Color accent;

  void _move(int delta) {
    if (labels.isEmpty) return;
    final next = (selected + delta).clamp(0, labels.length - 1);
    if (next != selected) onSelect(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _move(1),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _move(-1),
      },
      child: Focus(
        autofocus: true,
        child: Wrap(
          spacing: 22,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < labels.length; i++)
              InkWell(
                onTap: () => onSelect(i),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        labels[i],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: i == selected ? accent : muted,
                          letterSpacing: 1.2,
                          fontWeight: i == selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 1,
                        width: i == selected ? 22 : 0,
                        color: accent,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
