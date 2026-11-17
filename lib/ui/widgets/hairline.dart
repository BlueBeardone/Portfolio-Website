import 'package:flutter/material.dart';

/// A one-pixel rule. Horizontal by default, vertical when [vertical] is true.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.color, this.vertical = false});

  final Color? color;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? Theme.of(context).dividerTheme.color ?? Colors.white24;
    return Container(
      width: vertical ? 1 : double.infinity,
      height: vertical ? double.infinity : 1,
      color: resolved,
    );
  }
}
