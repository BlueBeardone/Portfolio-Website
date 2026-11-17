import 'package:flutter/material.dart';

class PdfButton extends StatelessWidget {
  const PdfButton({super.key, required this.label, required this.asset, this.onTap});

  final String label;
  final String asset;
  final void Function(String asset)? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () => onTap?.call(asset),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.16)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: theme.textTheme.bodySmall,
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
