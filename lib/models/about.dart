import '../data/json_read.dart';

class AboutGroup {
  const AboutGroup({required this.title, required this.items});

  final String title;
  final List<String> items;

  factory AboutGroup.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    return AboutGroup(
      title: readString(json, 'title', file: file, path: path),
      items: readStringList(json, 'items', file: file, path: path),
    );
  }
}

class About {
  const About({required this.intro, required this.groups});

  final String intro;
  final List<AboutGroup> groups;

  factory About.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    final groups = readList(json, 'groups', file: file, path: path);
    return About(
      intro: readOptionalString(json, 'intro', file: file, path: path),
      groups: [
        for (var i = 0; i < groups.length; i++)
          AboutGroup.fromJson(
            readMap(groups[i], '', file: file, path: joinPath(path, 'groups[$i]')),
            file: file,
            path: joinPath(path, 'groups[$i]'),
          ),
      ],
    );
  }
}
