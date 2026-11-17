import '../data/json_read.dart';

class SkillItem {
  const SkillItem({required this.name, required this.detail});

  final String name;
  final String detail;

  factory SkillItem.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    return SkillItem(
      name: readString(json, 'name', file: file, path: path),
      detail: readOptionalString(json, 'detail', file: file, path: path),
    );
  }
}

class Skills {
  const Skills({required this.items, required this.highlight});

  final List<SkillItem> items;
  final String highlight;

  factory Skills.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    final items = readList(json, 'items', file: file, path: path);
    return Skills(
      items: [
        for (var i = 0; i < items.length; i++)
          SkillItem.fromJson(
            readMap(items[i], '', file: file, path: joinPath(path, 'items[$i]')),
            file: file,
            path: joinPath(path, 'items[$i]'),
          ),
      ],
      highlight: readOptionalString(json, 'highlight', file: file, path: path),
    );
  }
}
