import 'package:flutter/material.dart';

import '../models/about.dart';
import '../models/history.dart';
import '../models/site_theme.dart';
import '../models/skills.dart';
import 'tab_row.dart';
import 'widgets/hairline.dart';
import 'widgets/numbered_row.dart';

class ContentPanel extends StatefulWidget {
  const ContentPanel({
    super.key,
    required this.skills,
    required this.history,
    required this.about,
    required this.tabs,
    required this.theme,
    this.scrollable = true,
  });

  final Skills skills;
  final History history;
  final About about;
  final List<String> tabs;
  final SiteTheme theme;

  /// False when the parent already provides the page scroll (mobile layout).
  final bool scrollable;

  @override
  State<ContentPanel> createState() => _ContentPanelState();
}

class _ContentPanelState extends State<ContentPanel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topLeft,
        children: [...previous, ?current],
      ),
      child: KeyedSubtree(
        key: ValueKey<int>(_index),
        child: _sectionFor(_index),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TabRow(
          labels: widget.tabs,
          selected: _index,
          accent: widget.theme.colors.accent,
          onSelect: (i) => setState(() => _index = i),
        ),
        const SizedBox(height: 10),
        Hairline(color: widget.theme.colors.hairline),
        const SizedBox(height: 8),
        if (widget.scrollable)
          Expanded(child: SingleChildScrollView(child: body))
        else
          body,
      ],
    );
  }

  Widget _sectionFor(int index) {
    // Tabs are data-driven; an extra tab falls back to the About section rather
    // than crashing the page.
    final sections = <Widget>[
      _skillsSection(),
      _historySection(),
      _aboutSection(),
    ];
    return index < sections.length ? sections[index] : _aboutSection();
  }

  Widget _skillsSection() {
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < widget.skills.items.length; i++) ...[
            NumberedRow(
              index: (i + 1).toString().padLeft(2, '0'),
              title: widget.skills.items[i].name,
              description: widget.skills.items[i].detail,
            ),
            if (i < widget.skills.items.length - 1) Hairline(color: theme.colors.hairline),
          ],
          if (widget.skills.highlight.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Container(
                padding: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: theme.colors.accent, width: 2),
                  ),
                ),
                child: Text(
                  widget.skills.highlight,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: theme.colors.text,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _historySection() {
    final theme = widget.theme;
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(color: theme.colors.muted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in widget.history.groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 2),
            child: Text(
              group.title,
              style: muted?.copyWith(
                letterSpacing: 1.4,
                fontWeight: FontWeight.w500,
                color: theme.colors.accent,
              ),
            ),
          ),
          for (var i = 0; i < group.entries.length; i++) ...[
            NumberedRow(
              index: (i + 1).toString().padLeft(2, '0'),
              title: group.entries[i].title,
              meta: group.entries[i].meta,
              description: group.entries[i].description,
            ),
            if (i < group.entries.length - 1) Hairline(color: theme.colors.hairline),
          ],
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _aboutSection() {
    final theme = widget.theme;
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(color: theme.colors.muted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.about.intro.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Text(widget.about.intro, style: text.bodyMedium),
          ),
        for (final group in widget.about.groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 6),
            child: Text(
              group.title,
              style: muted?.copyWith(
                letterSpacing: 1.4,
                fontWeight: FontWeight.w500,
                color: theme.colors.accent,
              ),
            ),
          ),
          for (final item in group.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text('•', style: muted?.copyWith(color: theme.colors.accent)),
                  ),
                  Expanded(child: Text(item, style: text.bodySmall?.copyWith(height: 1.6))),
                ],
              ),
            ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
