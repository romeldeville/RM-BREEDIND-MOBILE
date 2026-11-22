import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n/locale_controller.dart';
import '../core/notifications/push_controller.dart';
import '../core/sync/sync_controller.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class RmBreedingApp extends ConsumerWidget {
  const RmBreedingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final router = ref.watch(routerProvider);
    // Starts the connectivity watcher exactly once per application lifetime.
    ref.watch(connectivitySyncProvider);
    // Registers the FCM device token when notifications are enabled.
    ref.watch(pushControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: buildAppTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
