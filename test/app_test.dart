import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app.dart';
import 'package:portfolio/data/content_repository.dart';
import 'package:portfolio/data/json_read.dart';
import 'package:portfolio/models/site_content.dart';
import 'package:portfolio/ui/error_view.dart';

import 'support/fixtures.dart';

class FailingRepository extends ContentRepository {
  FailingRepository(this.error);

  final DataException error;

  @override
  Future<SiteContent> load() async => throw error;
}

class PendingRepository extends ContentRepository {
  final Completer<SiteContent> completer = Completer<SiteContent>();

  @override
  Future<SiteContent> load() => completer.future;
}

void main() {
  setUpAll(() async {
    sampleContent = await loadSampleContent();
  });

  testWidgets('a data error shows the file, path and message', (tester) async {
    const error = DataException(
      file: 'assets/data/profile.json',
      path: 'profile.name',
      message: 'expected string, got int',
    );
    await tester.pumpWidget(const MaterialApp(home: ErrorView(error: error)));

    expect(find.textContaining('assets/data/profile.json'), findsOneWidget);
    expect(find.textContaining('profile.name'), findsOneWidget);
    expect(find.textContaining('expected string'), findsOneWidget);
  });

  testWidgets('a valid load shows the portfolio', (tester) async {
    await tester.pumpWidget(PortfolioApp(content: sampleContent));
    expect(find.text('Barend Blom'), findsOneWidget);
    expect(find.text('Software Developer · Gauteng, South Africa'), findsOneWidget);
  });

  testWidgets('a failing repository shows ErrorView, never a blank page', (tester) async {
    await tester.pumpWidget(
      ContentBootstrap(
        repository: FailingRepository(
          const DataException(
            file: 'assets/data/skills.json',
            path: 'items[2].name',
            message: 'missing required string',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.textContaining('assets/data/skills.json'), findsOneWidget);
    expect(find.textContaining('items[2].name'), findsOneWidget);
  });

  testWidgets('shows a spinner while the data loads', (tester) async {
    final pending = PendingRepository();
    await tester.pumpWidget(ContentBootstrap(repository: pending));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ErrorView), findsNothing);

    pending.completer.complete(sampleContent);
    // The matrix ticker never settles, so pump a few frames instead.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Barend Blom'), findsOneWidget);
  });

  testWidgets('an unexpected exception is reported, not swallowed', (tester) async {
    await tester.pumpWidget(
      ContentBootstrap(
        repository: FailingRepository(
          const DataException(file: 'unknown', path: '', message: 'boom'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ErrorView), findsOneWidget);
  });
}
