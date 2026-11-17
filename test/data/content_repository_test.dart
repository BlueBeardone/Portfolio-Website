import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/data/content_repository.dart';
import 'package:portfolio/data/json_read.dart';

Future<String> diskLoader(String key) => File(key).readAsString();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads all five files into typed content', () async {
    final content = await ContentRepository(loader: diskLoader).load();

    expect(content.profile.role, 'Software Developer');
    expect(content.profile.name, 'Barend Blom');
    expect(content.profile.kicker, 'Portfolio / 2026');
    expect(content.profile.links.map((l) => l.label), ['GitHub', 'LinkedIn', 'itch.io']);
    expect(content.profile.links.last.url, 'https://itch.io/profile/4shblue');
    expect(content.profile.tabs, ['Skills', 'History', 'About']);
    expect(content.profile.pdfs, hasLength(2));
    expect(content.profile.contact.email, 'barend.army@gmail.com');

    expect(content.skills.items, hasLength(7));
    expect(content.skills.items.first.name, 'Frontend');
    expect(content.skills.items.first.detail, contains('Flutter'));
    expect(content.skills.items[1].detail, contains('RESTful APIs'));
    expect(content.skills.highlight, contains('full-stack'));

    expect(
      content.history.groups.map((g) => g.title),
      ['Education', 'Work Experience', 'Achievements'],
    );
    final achievements = content.history.groups.last.entries;
    expect(achievements, hasLength(4));
    expect(achievements.first.meta, isEmpty);
    expect(achievements.first.description, isEmpty);

    expect(
      content.about.groups.map((g) => g.title),
      ['Personal Interests', 'Values', 'Currently Learning'],
    );
    expect(content.about.intro, isNotEmpty);
  });

  test('loads theme values', () async {
    final content = await ContentRepository(loader: diskLoader).load();
    expect(content.theme.layout.breakpoint, 900);
    expect(content.theme.matrix.maxLayerOpacity, 0.28);
    expect(content.theme.colors.accent.toARGB32(), 0xFF4ADE80);
  });

  test('malformed JSON surfaces the file name', () async {
    Future<String> loader(String key) async =>
        key.endsWith('profile.json') ? '{"name": ' : '{}';

    expect(
      () => ContentRepository(loader: loader).load(),
      throwsA(isA<DataException>()
          .having((e) => e.file, 'file', 'assets/data/profile.json')
          .having((e) => e.message, 'message', isNotEmpty)),
    );
  });

  test('missing required field surfaces the field path', () async {
    const partial = '{"kicker": "k", "name": "n", "location": "l", "links": [], '
        '"pdfs": [], "tabs": [], "contact": {"email": "e"}}';
    Future<String> loader(String key) async => key.endsWith('profile.json') ? partial : '{}';

    expect(
      () => ContentRepository(loader: loader).load(),
      throwsA(isA<DataException>()
          .having((e) => e.file, 'file', 'assets/data/profile.json')
          .having((e) => e.path, 'path', 'role')),
    );
  });
}
