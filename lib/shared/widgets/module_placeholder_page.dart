import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../l10n/app_localizations.dart';

class ModulePlaceholderPage extends StatelessWidget {
  const ModulePlaceholderPage({
    super.key,
    required this.title,
    required this.icon,
    required this.bullets,
  });

  final String title;
  final IconData icon;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: [
        Row(
          children: [
            Icon(icon, size: 28, color: AppTokens.primary),
            const SizedBox(width: AppTokens.space3),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: AppTokens.space4),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.comingSoon),
                const SizedBox(height: AppTokens.space3),
                for (final bullet in bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.space2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6, right: AppTokens.space2),
                          child: Icon(Icons.circle, size: 8, color: AppTokens.accent),
                        ),
                        Expanded(child: Text(bullet)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
