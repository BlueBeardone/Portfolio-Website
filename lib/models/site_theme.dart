import 'dart:ui' show Color;

import '../data/json_read.dart';

/// Parses `#RRGGBB` and `#AARRGGBB`. Throws [FormatException] for anything else.
Color parseHexColor(String value) {
  final hex = value.startsWith('#') ? value.substring(1) : value;
  if (hex.length != 6 && hex.length != 8) {
    throw FormatException('Expected #RRGGBB or #AARRGGBB, got "$value"');
  }
  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) {
    throw FormatException('Expected hex digits, got "$value"');
  }
  return Color(hex.length == 6 ? 0xFF000000 | parsed : parsed);
}


/// A positive number, or a data error naming the field. A zero font size or
/// breakpoint would otherwise reach the layout code as an uncaught error and
/// blank the page.
double _positiveNumber(
  Map<String, dynamic> json,
  String key, {
  required String file,
  required String path,
}) {
  final value = readDouble(json, key, file: file, path: path);
  if (!value.isFinite || value <= 0) {
    throw DataException(
      file: file,
      path: joinPath(path, key),
      message: 'expected a number greater than 0, got $value',
    );
  }
  return value;
}

double _nonNegativeNumber(
  Map<String, dynamic> json,
  String key, {
  required String file,
  required String path,
}) {
  final value = readDouble(json, key, file: file, path: path);
  if (!value.isFinite || value < 0) {
    throw DataException(
      file: file,
      path: joinPath(path, key),
      message: 'expected a number of at least 0, got $value',
    );
  }
  return value;
}

/// A number in `[0, 1]`, the only range an opacity or width factor can mean.
double _fraction(
  Map<String, dynamic> json,
  String key, {
  required String file,
  required String path,
}) {
  final value = readDouble(json, key, file: file, path: path);
  if (!value.isFinite || value < 0 || value > 1) {
    throw DataException(
      file: file,
      path: joinPath(path, key),
      message: 'expected a number between 0 and 1, got $value',
    );
  }
  return value;
}

int _positiveInt(
  Map<String, dynamic> json,
  String key, {
  required String file,
  required String path,
}) {
  final value = readInt(json, key, file: file, path: path);
  if (value < 1) {
    throw DataException(
      file: file,
      path: joinPath(path, key),
      message: 'expected a whole number of at least 1, got $value',
    );
  }
  return value;
}

class SiteColors {
  const SiteColors({
    required this.background,
    required this.text,
    required this.muted,
    required this.hairline,
    required this.accent,
    required this.accentSecondary,
    required this.panel,
  });

  final Color background;
  final Color text;
  final Color muted;
  final Color hairline;
  final Color accent;
  final Color accentSecondary;
  final Color panel;

  factory SiteColors.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    Color color(String key) {
      final raw = readString(json, key, file: file, path: path);
      try {
        return parseHexColor(raw);
      } on FormatException catch (e) {
        throw DataException(
          file: file,
          path: joinPath(path, key),
          message: 'invalid colour: ${e.message}',
        );
      }
    }

    return SiteColors(
      background: color('background'),
      text: color('text'),
      muted: color('muted'),
      hairline: color('hairline'),
      accent: color('accent'),
      accentSecondary: color('accentSecondary'),
      panel: color('panel'),
    );
  }
}

class SiteLayout {
  const SiteLayout({
    required this.breakpoint,
    required this.maxContentWidth,
    required this.pagePadding,
    required this.identityWidthFactor,
  });

  final double breakpoint;
  final double maxContentWidth;
  final double pagePadding;
  final double identityWidthFactor;

  factory SiteLayout.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    return SiteLayout(
      breakpoint: _positiveNumber(json, 'breakpoint', file: file, path: path),
      maxContentWidth: _positiveNumber(json, 'maxContentWidth', file: file, path: path),
      pagePadding: _nonNegativeNumber(json, 'pagePadding', file: file, path: path),
      identityWidthFactor:
          _fraction(json, 'identityWidthFactor', file: file, path: path),
    );
  }
}

class SiteTypography {
  const SiteTypography({
    required this.heroDesktop,
    required this.heroMobile,
    required this.nameTracking,
    required this.bodySize,
    required this.smallSize,
  });

  final double heroDesktop;
  final double heroMobile;
  final double nameTracking;
  final double bodySize;
  final double smallSize;

  factory SiteTypography.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    return SiteTypography(
      heroDesktop: _positiveNumber(json, 'heroDesktop', file: file, path: path),
      heroMobile: _positiveNumber(json, 'heroMobile', file: file, path: path),
      nameTracking: readDouble(json, 'nameTracking', file: file, path: path),
      bodySize: _positiveNumber(json, 'bodySize', file: file, path: path),
      smallSize: _positiveNumber(json, 'smallSize', file: file, path: path),
    );
  }
}

class MatrixConfig {
  const MatrixConfig({
    required this.enabled,
    required this.opacity,
    required this.speed,
    required this.fontSize,
    required this.color,
    required this.trailLength,
    required this.maxLayerOpacity,
  });

  final bool enabled;
  final double opacity;
  final double speed;
  final double fontSize;
  final Color color;
  final int trailLength;
  final double maxLayerOpacity;

  factory MatrixConfig.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    final rawColor = readString(json, 'color', file: file, path: path);
    final Color color;
    try {
      color = parseHexColor(rawColor);
    } on FormatException catch (e) {
      throw DataException(
        file: file,
        path: joinPath(path, 'color'),
        message: 'invalid colour: ${e.message}',
      );
    }
    return MatrixConfig(
      enabled: readBool(json, 'enabled', file: file, path: path),
      opacity: _fraction(json, 'opacity', file: file, path: path),
      speed: _positiveNumber(json, 'speed', file: file, path: path),
      fontSize: _positiveNumber(json, 'fontSize', file: file, path: path),
      color: color,
      trailLength: _positiveInt(json, 'trailLength', file: file, path: path),
      maxLayerOpacity: _fraction(json, 'maxLayerOpacity', file: file, path: path),
    );
  }
}

class SiteTheme {
  const SiteTheme({
    required this.colors,
    required this.layout,
    required this.type,
    required this.matrix,
  });

  final SiteColors colors;
  final SiteLayout layout;
  final SiteTypography type;
  final MatrixConfig matrix;

  factory SiteTheme.fromJson(Map<String, dynamic> json, {required String file, String path = ''}) {
    return SiteTheme(
      colors: SiteColors.fromJson(
        readMap(json['colors'], 'colors', file: file, path: path),
        file: file,
        path: joinPath(path, 'colors'),
      ),
      layout: SiteLayout.fromJson(
        readMap(json['layout'], 'layout', file: file, path: path),
        file: file,
        path: joinPath(path, 'layout'),
      ),
      type: SiteTypography.fromJson(
        readMap(json['type'], 'type', file: file, path: path),
        file: file,
        path: joinPath(path, 'type'),
      ),
      matrix: MatrixConfig.fromJson(
        readMap(json['matrix'], 'matrix', file: file, path: path),
        file: file,
        path: joinPath(path, 'matrix'),
      ),
    );
  }
}
