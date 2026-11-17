import 'package:flutter/material.dart';

import '../data/launcher.dart';
import '../models/profile.dart';
import '../models/site_theme.dart';
import 'widgets/link_row.dart';
import 'widgets/pdf_button.dart';

class IdentityPanel extends StatelessWidget {
  const IdentityPanel({
    super.key,
    required this.profile,
    required this.theme,
    this.onOpenLink,
    this.onDownloadPdf,
  });

  final Profile profile;
  final SiteTheme theme;
  final void Function(String url)? onOpenLink;
  final void Function(String asset)? onDownloadPdf;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = theme.colors;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= theme.layout.breakpoint;
    final nameSize = isDesktop ? theme.type.heroDesktop : theme.type.heroMobile;
    final muted = text.bodySmall?.copyWith(color: colors.muted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          profile.kicker,
          style: text.labelSmall?.copyWith(
            color: colors.accent,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          profile.name,
          style: text.displayLarge?.copyWith(
            fontSize: nameSize,
            letterSpacing: theme.type.nameTracking,
            color: colors.text,
            height: 0.95,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${profile.role} · ${profile.location}',
          style: text.bodyMedium?.copyWith(color: colors.muted),
        ),
        const SizedBox(height: 28),
        ...profile.links.map(
          (link) => LinkRow(
            label: link.label,
            url: link.url,
            onTap: onOpenLink ?? openUrl,
          ),
        ),
        if (profile.contact.email.isNotEmpty)
          LinkRow(
            label: profile.contact.email,
            url: 'mailto:${profile.contact.email}',
            onTap: onOpenLink ?? openUrl,
          ),
        if (profile.contact.phone.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(profile.contact.phone, style: muted),
          ),
        const SizedBox(height: 28),
        // IntrinsicHeight + stretch gives every button the height of the
        // longest label, so a wrapped label does not leave a ragged pair.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < profile.pdfs.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: PdfButton(
                    label: profile.pdfs[i].label,
                    asset: profile.pdfs[i].asset,
                    onTap: onDownloadPdf ?? downloadAsset,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
