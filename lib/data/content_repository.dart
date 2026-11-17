import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/about.dart';
import '../models/history.dart';
import '../models/profile.dart';
import '../models/site_content.dart';
import '../models/site_theme.dart';
import '../models/skills.dart';
import 'json_read.dart';

typedef AssetLoader = Future<String> Function(String key);

const String profileFile = 'assets/data/profile.json';
const String skillsFile = 'assets/data/skills.json';
const String historyFile = 'assets/data/history.json';
const String aboutFile = 'assets/data/about.json';
const String themeFile = 'assets/data/theme.json';

/// Loads the five hand-edited JSON files into typed content.
///
/// Takes an [AssetLoader] so tests can read the files from disk or supply
/// broken JSON without touching the bundle.
class ContentRepository {
  ContentRepository({AssetLoader? loader}) : _loader = loader ?? rootBundle.loadString;

  final AssetLoader _loader;

  static const List<String> files = [
    profileFile,
    skillsFile,
    historyFile,
    aboutFile,
    themeFile,
  ];

  Future<SiteContent> load() async {
    final profile = await _read(
      profileFile,
      (json) => Profile.fromJson(json, file: profileFile),
    );
    final skills = await _read(
      skillsFile,
      (json) => Skills.fromJson(json, file: skillsFile),
    );
    final history = await _read(
      historyFile,
      (json) => History.fromJson(json, file: historyFile),
    );
    final about = await _read(
      aboutFile,
      (json) => About.fromJson(json, file: aboutFile),
    );
    final theme = await _read(
      themeFile,
      (json) => SiteTheme.fromJson(json, file: themeFile),
    );

    return SiteContent(
      profile: profile,
      skills: skills,
      history: history,
      about: about,
      theme: theme,
    );
  }

  Future<T> _read<T>(String file, T Function(Map<String, dynamic> json) build) async {
    final raw = await _loader(file);
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      throw DataException(file: file, path: '', message: 'invalid JSON: ${e.message}');
    }
    return build(readMap(decoded, '', file: file));
  }
}
