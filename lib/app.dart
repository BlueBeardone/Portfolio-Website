import 'package:flutter/material.dart';

import 'data/content_repository.dart';
import 'data/json_read.dart';
import 'models/site_content.dart';
import 'theme/app_theme.dart';
import 'ui/error_view.dart';
import 'ui/portfolio_page.dart';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key, required this.content});

  final SiteContent content;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${content.profile.name} — ${content.profile.role}',
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(content.theme),
      home: PortfolioPage(content: content),
    );
  }
}

/// Loads the content, then shows either the portfolio or a readable error.
class ContentBootstrap extends StatefulWidget {
  const ContentBootstrap({super.key, required this.repository});

  final ContentRepository repository;

  @override
  State<ContentBootstrap> createState() => _ContentBootstrapState();
}

class _ContentBootstrapState extends State<ContentBootstrap> {
  late final Future<SiteContent> _content = widget.repository.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SiteContent>(
      future: _content,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: ErrorView(
              error: error is DataException
                  ? error
                  : DataException(file: 'unknown', path: '', message: '$error'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color(0xFF07090A),
              body: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }
        return PortfolioApp(content: snapshot.requireData);
      },
    );
  }
}
