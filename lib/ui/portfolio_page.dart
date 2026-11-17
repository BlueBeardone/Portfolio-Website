import 'package:flutter/material.dart';

import '../models/site_content.dart';
import 'content_panel.dart';
import 'identity_panel.dart';
import 'matrix_background.dart';
import 'widgets/hairline.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key, required this.content});

  final SiteContent content;

  @override
  Widget build(BuildContext context) {
    final theme = content.theme;
    final padding = theme.layout.pagePadding;

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: MatrixBackground(
        config: theme.matrix,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = MediaQuery.sizeOf(context).width >= theme.layout.breakpoint;
              final maxWidth = theme.layout.maxContentWidth;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth + padding * 2),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
                    child: isDesktop ? _desktop(context) : _mobile(context),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _desktop(BuildContext context) {
    final theme = content.theme;
    final identityFlex = (theme.layout.identityWidthFactor * 100).round();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: identityFlex,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 28),
              child: IdentityPanel(profile: content.profile, theme: theme),
            ),
          ),
        ),
        Hairline(color: theme.colors.hairline, vertical: true),
        Expanded(
          flex: 100 - identityFlex,
          child: Padding(
            padding: const EdgeInsets.only(left: 32),
            child: ContentPanel(
              skills: content.skills,
              history: content.history,
              about: content.about,
              tabs: content.profile.tabs,
              theme: theme,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobile(BuildContext context) {
    final theme = content.theme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IdentityPanel(profile: content.profile, theme: theme),
          const SizedBox(height: 28),
          Hairline(color: theme.colors.hairline),
          const SizedBox(height: 20),
          ContentPanel(
            skills: content.skills,
            history: content.history,
            about: content.about,
            tabs: content.profile.tabs,
            theme: theme,
            scrollable: false,
          ),
        ],
      ),
    );
  }
}
