/// Typed, path-aware JSON readers.
///
/// Every reader reports *where* in which file the problem is, because the
/// person who fixes a broken data file is the site owner, not a programmer.
class DataException implements Exception {
  const DataException({required this.file, required this.path, required this.message});

  final String file;
  final String path;
  final String message;

  @override
  String toString() => 'DataException($file, $path): $message';
}

/// Builds the dotted path shown in error messages.
String joinPath(String path, String key) {
  if (key.isEmpty) return path;
  return path.isEmpty ? key : '$path.$key';
}

String readString(
  Map<String, dynamic> json,
  String key, {
  required String file,
  String path = '',
}) {
  final fullPath = joinPath(path, key);
  if (!json.containsKey(key)) {
    throw DataException(file: file, path: fullPath, message: 'missing required string');
  }
  final value = json[key];
  if (value is! String) {
    throw DataException(
      file: file,
      path: fullPath,
      message: 'expected string, got ${value.runtimeType}',
    );
  }
  return value;
}

String readOptionalString(
  Map<String, dynamic> json,
  String key, {
  required String file,
  String path = '',
}) {
  final value = json[key];
  if (value == null) return '';
  if (value is! String) {
    throw DataException(
      file: file,
      path: joinPath(path, key),
      message: 'expected string or null, got ${value.runtimeType}',
    );
  }
  return value;
}

Map<String, dynamic> readMap(
  Object? value,
  String key, {
  required String file,
  String path = '',
}) {
  final fullPath = joinPath(path, key);
  if (value is! Map) {
    throw DataException(
      file: file,
      path: fullPath,
      message: 'expected object, got ${value.runtimeType}',
    );
  }
  return value.map((k, v) => MapEntry(k.toString(), v));
}

List<dynamic> readList(
  Map<String, dynamic> json,
  String key, {
  required String file,
  String path = '',
}) {
  final fullPath = joinPath(path, key);
  if (!json.containsKey(key)) {
    throw DataException(file: file, path: fullPath, message: 'missing required list');
  }
  final value = json[key];
  if (value is! List) {
    throw DataException(
      file: file,
      path: fullPath,
      message: 'expected list, got ${value.runtimeType}',
    );
  }
  return value;
}

List<String> readStringList(
  Map<String, dynamic> json,
  String key, {
  required String file,
  String path = '',
}) {
  final list = readList(json, key, file: file, path: path);
  final base = joinPath(path, key);
  return [
    for (var i = 0; i < list.length; i++)
      if (list[i] is String)
        list[i] as String
      else
        throw DataException(
          file: file,
          path: '$base[$i]',
          message: 'expected string, got ${list[i].runtimeType}',
        ),
  ];
}

double readDouble(
  Map<String, dynamic> json,
  String key, {
  required String file,
  String path = '',
}) {
  final value = json[key];
  if (value is num) return value.toDouble();
  throw DataException(
    file: file,
    path: joinPath(path, key),
    message: 'expected number, got ${value.runtimeType}',
  );
}

bool readBool(
  Map<String, dynamic> json,
  String key, {
  required String file,
  String path = '',
}) {
  final value = json[key];
  if (value is bool) return value;
  throw DataException(
    file: file,
    path: joinPath(path, key),
    message: 'expected boolean, got ${value.runtimeType}',
  );
}

int readInt(
  Map<String, dynamic> json,
  String key, {
  required String file,
  String path = '',
}) {
  final value = json[key];
  if (value is int) return value;
  throw DataException(
    file: file,
    path: joinPath(path, key),
    message: 'expected integer, got ${value.runtimeType}',
  );
}
