import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/i18n/locale_controller.dart';
import '../../core/sync/sync_controller.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../features/sync/sync_banner.dart';

class _Destination {
  const _Destination(this.path, this.icon, this.labelKey);

  final String path;
  final IconData icon;
  final String Function(AppLocalizations) labelKey;
}

const _destinations = <_Destination>[
  _Destination('/dashboard', Icons.dashboard_outlined, _dashboardLabel),
  _Destination('/herd', Icons.pets_outlined, _herdLabel),
  _Destination('/reproduction', Icons.favorite_border, _reproductionLabel),
  _Destination('/health', Icons.medical_services_outlined, _healthLabel),
  _Destination('/feeding', Icons.restaurant_outlined, _feedingLabel),
  _Destination('/production', Icons.agriculture_outlined, _productionLabel),
  _Destination('/species', Icons.category_outlined, _speciesLabel),
  _Destination('/lots', Icons.inventory_2_outlined, _lotsLabel),
  _Destination('/sites', Icons.warehouse_outlined, _sitesLabel),
  _Destination('/sales', Icons.point_of_sale_outlined, _salesLabel),
  _Destination('/finance', Icons.account_balance_outlined, _financeLabel),
  _Destination('/alerts', Icons.notifications_outlined, _alertsLabel),
  _Destination('/reports', Icons.assessment_outlined, _reportsLabel),
  _Destination('/settings', Icons.settings_outlined, _settingsLabel),
];

String _dashboardLabel(AppLocalizations l) => l.dashboard;
String _herdLabel(AppLocalizations l) => l.herd;
String _reproductionLabel(AppLocalizations l) => l.reproduction;
String _healthLabel(AppLocalizations l) => l.health;
String _feedingLabel(AppLocalizations l) => l.feeding;
String _productionLabel(AppLocalizations l) => l.production;
String _speciesLabel(AppLocalizations l) => l.species;
String _lotsLabel(AppLocalizations l) => 'Lots';
String _sitesLabel(AppLocalizations l) => l.sites;
String _salesLabel(AppLocalizations l) => l.sales;
String _financeLabel(AppLocalizations l) => l.finance;
String _alertsLabel(AppLocalizations l) => l.alerts;
String _reportsLabel(AppLocalizations l) => 'Rapports';
String _settingsLabel(AppLocalizations l) => l.settings;

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 900;
    final currentIndex = _destinations.indexWhere((d) => location.startsWith(d.path));
    final selectedIndex = currentIndex < 0 ? 0 : currentIndex;
    final locale = ref.watch(localeControllerProvider);
    final syncState = ref.watch(syncControllerProvider);

    void navigate(int index) {
      context.go(_destinations[index].path);
      if (!wide) {
        Navigator.of(context).maybePop();
      }
    }

    final title = _destinations[selectedIndex].labelKey(l10n);

    final appBar = AppBar(
      title: Text(title),
      actions: [
        IconButton(
          tooltip: 'Synchroniser',
          onPressed: syncState.syncing
              ? null
              : () => _manualSync(context, ref),
          icon: syncState.syncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
        ),
        TextButton(
          onPressed: () => ref.read(localeControllerProvider.notifier).toggle(),
          child: Text(locale.languageCode == 'fr' ? 'EN' : 'FR'),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              ref.read(authControllerProvider.notifier).logout();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'logout', child: Text(l10n.logout)),
          ],
        ),
      ],
    );

    if (wide) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: navigate,
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppTokens.surface,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTokens.space4),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTokens.accent,
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                  child: const Text(
                    'RM',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppTokens.text),
                  ),
                ),
              ),
              destinations: [
                for (final destination in _destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    label: Text(destination.labelKey(l10n)),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  const SyncBanner(),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTokens.space4),
                child: Text(
                  l10n.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (var index = 0; index < _destinations.length; index++)
                ListTile(
                  leading: Icon(_destinations[index].icon),
                  title: Text(_destinations[index].labelKey(l10n)),
                  selected: index == selectedIndex,
                  onTap: () => navigate(index),
                ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SyncBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex < 4 ? selectedIndex : 0,
        onDestinationSelected: navigate,
        destinations: [
          for (final destination in _destinations.take(4))
            NavigationDestination(
              icon: Icon(destination.icon),
              label: destination.labelKey(l10n),
            ),
        ],
      ),
    );
  }
}

Future<void> _manualSync(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final report = await ref.read(syncControllerProvider.notifier).syncNow();
  if (!context.mounted) {
    return;
  }
  if (report == null) {
    final message =
        ref.read(syncControllerProvider).error ?? 'Synchronisation impossible.';
    messenger.showSnackBar(SnackBar(content: Text(message)));
    return;
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        '${report.pushed} envoi(s), ${report.pulled} réception(s), '
        '${report.conflicts} conflit(s).',
      ),
    ),
  );
}
