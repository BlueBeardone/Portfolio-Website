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
    Color color(String key) => parseHexColor(readString(json, key, file: file, path: path));
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
    double number(String key) => readDouble(json, key, file: file, path: path);
    return SiteLayout(
      breakpoint: number('breakpoint'),
      maxContentWidth: number('maxContentWidth'),
      pagePadding: number('pagePadding'),
      identityWidthFactor: number('identityWidthFactor'),
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
    double number(String key) => readDouble(json, key, file: file, path: path);
    return SiteTypography(
      heroDesktop: number('heroDesktop'),
      heroMobile: number('heroMobile'),
      nameTracking: number('nameTracking'),
      bodySize: number('bodySize'),
      smallSize: number('smallSize'),
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
    return MatrixConfig(
      enabled: readBool(json, 'enabled', file: file, path: path),
      opacity: readDouble(json, 'opacity', file: file, path: path),
      speed: readDouble(json, 'speed', file: file, path: path),
      fontSize: readDouble(json, 'fontSize', file: file, path: path),
      color: parseHexColor(readString(json, 'color', file: file, path: path)),
      trailLength: readInt(json, 'trailLength', file: file, path: path),
      maxLayerOpacity: readDouble(json, 'maxLayerOpacity', file: file, path: path),
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
