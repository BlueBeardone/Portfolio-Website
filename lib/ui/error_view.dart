import 'package:flutter/material.dart';

import '../data/json_read.dart';

/// Shown when the hand-edited JSON cannot be read. It names the file, the field
/// and the parser's complaint, because the person who sees this is the site
/// owner, not a programmer.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error});

  final DataException error;

  static const Color _background = Color(0xFF07090A);
  static const Color _text = Color(0xFFEEF2F0);
  static const Color _muted = Color(0xFF8EA79A);
  static const Color _accent = Color(0xFF4ADE80);
  static const Color _panel = Color(0xFF0B0F0D);

  @override
  Widget build(BuildContext context) {
    Widget field(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _panel,
                  border: Border.all(color: const Color(0x14FFFFFF)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13,
                    height: 1.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        );

    return Scaffold(
      backgroundColor: _background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SOMETHING IS OFF IN YOUR DATA',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'The site could not read one of the files in assets/data.',
                  style: TextStyle(color: _text, fontSize: 20, height: 1.3),
                ),
                const SizedBox(height: 28),
                field('FILE', error.file.isEmpty ? '(unknown)' : error.file),
                field('FIELD', error.path.isEmpty ? '(top level)' : error.path),
                field('PROBLEM', error.message),
                const SizedBox(height: 8),
                const Text(
                  'Fix the JSON file above and reload. Check for a missing quote, '
                  'a trailing comma, or a value with the wrong type.',
                  style: TextStyle(color: _muted, fontSize: 13, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
