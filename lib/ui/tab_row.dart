import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The Skills / History / About selector. Labels come straight from the data
/// file; the underline slides between tabs and arrow keys move the selection.
///
/// The row is one focus target rather than one per tab: Tab lands on the row,
/// arrows change the tab, and Enter or Space confirm the tab already selected.
class TabRow extends StatefulWidget {
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

  @override
  State<TabRow> createState() => _TabRowState();
}

class _TabRowState extends State<TabRow> {
  final FocusNode _focus = FocusNode(debugLabel: 'TabRow');

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _move(int delta) {
    if (widget.labels.isEmpty) return;
    final next = (widget.selected + delta).clamp(0, widget.labels.length - 1);
    if (next != widget.selected) widget.onSelect(next);
  }

  void _tap(int index) {
    // Tapping a tab also admits the row to the focus ring, so the arrow keys
    // keep working after a pointer user touches a tab.
    _focus.requestFocus();
    widget.onSelect(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _move(1),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _move(-1),
        const SingleActivator(LogicalKeyboardKey.enter): () =>
            widget.onSelect(widget.selected),
        const SingleActivator(LogicalKeyboardKey.space): () =>
            widget.onSelect(widget.selected),
      },
      // No autofocus: a row that grabs focus on load eats the arrow keys the
      // page needs for scrolling.
      child: Focus(
        focusNode: _focus,
        child: Wrap(
          spacing: 22,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < widget.labels.length; i++)
              InkWell(
                onTap: () => _tap(i),
                // The row owns focus; individual tabs are pointer targets.
                canRequestFocus: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.labels[i],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: i == widget.selected ? widget.accent : muted,
                          letterSpacing: 1.2,
                          fontWeight: i == widget.selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 1,
                        width: i == widget.selected ? 22 : 0,
                        color: widget.accent,
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
