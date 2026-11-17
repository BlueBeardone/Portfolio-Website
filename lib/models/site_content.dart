import 'about.dart';
import 'history.dart';
import 'profile.dart';
import 'site_theme.dart';
import 'skills.dart';

class SiteContent {
  const SiteContent({
    required this.profile,
    required this.skills,
    required this.history,
    required this.about,
    required this.theme,
  });

  final Profile profile;
  final Skills skills;
  final History history;
  final About about;
  final SiteTheme theme;
}
