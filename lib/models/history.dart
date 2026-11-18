import '../data/json_read.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.title,
    this.meta = '',
    this.description = '',
    this.children = const [],
  });

  final String title;
  final String meta;
  final String description;

  /// Sub-entries (a specific product, say) shown indented beneath this one.
  final List<HistoryEntry> children;

  factory HistoryEntry.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    final children = readOptionalList(json, 'children', file: file, path: path);
    return HistoryEntry(
      title: readString(json, 'title', file: file, path: path),
      meta: readOptionalString(json, 'meta', file: file, path: path),
      description: readOptionalString(json, 'description', file: file, path: path),
      children: [
        for (var i = 0; i < children.length; i++)
          HistoryEntry.fromJson(
            readMap(children[i], '', file: file, path: joinPath(path, 'children[$i]')),
            file: file,
            path: joinPath(path, 'children[$i]'),
          ),
      ],
    );
  }
}

class HistoryGroup {
  const HistoryGroup({required this.title, required this.entries});

  final String title;
  final List<HistoryEntry> entries;

  factory HistoryGroup.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    final entries = readList(json, 'entries', file: file, path: path);
    return HistoryGroup(
      title: readString(json, 'title', file: file, path: path),
      entries: [
        for (var i = 0; i < entries.length; i++)
          HistoryEntry.fromJson(
            readMap(entries[i], '', file: file, path: joinPath(path, 'entries[$i]')),
            file: file,
            path: joinPath(path, 'entries[$i]'),
          ),
      ],
    );
  }
}

class History {
  const History({required this.groups});

  final List<HistoryGroup> groups;

  factory History.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    final groups = readList(json, 'groups', file: file, path: path);
    return History(
      groups: [
        for (var i = 0; i < groups.length; i++)
          HistoryGroup.fromJson(
            readMap(groups[i], '', file: file, path: joinPath(path, 'groups[$i]')),
            file: file,
            path: joinPath(path, 'groups[$i]'),
          ),
      ],
    );
  }
}
