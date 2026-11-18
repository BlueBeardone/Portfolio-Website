import '../data/json_read.dart';

class SkillItem {
  const SkillItem({required this.name, this.detail = '', this.children = const []});

  final String name;
  final String detail;

  /// Sub-entries (Frontend, Backend, ...) shown indented beneath this one.
  final List<SkillItem> children;

  factory SkillItem.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    final children = readOptionalList(json, 'children', file: file, path: path);
    return SkillItem(
      name: readString(json, 'name', file: file, path: path),
      detail: readOptionalString(json, 'detail', file: file, path: path),
      children: [
        for (var i = 0; i < children.length; i++)
          SkillItem.fromJson(
            readMap(children[i], '', file: file, path: joinPath(path, 'children[$i]')),
            file: file,
            path: joinPath(path, 'children[$i]'),
          ),
      ],
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
