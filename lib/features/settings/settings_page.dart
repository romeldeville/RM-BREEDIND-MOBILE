import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_state.dart';
import '../../core/config/app_config.dart';
import '../../core/i18n/locale_controller.dart';
import '../../core/notifications/push_controller.dart';
import '../../core/notifications/push_gateway.dart';
import '../../core/sync/sync_controller.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/section_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final sync = ref.watch(syncControllerProvider);
    final push = ref.watch(pushControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: [
        SectionCard(
          title: l10n.language,
          child: RadioGroup<String>(
            groupValue: locale.languageCode,
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(localeControllerProvider.notifier)
                    .setLocale(Locale(value));
              }
            },
            child: const Column(
              children: [
                RadioListTile<String>(
                  value: 'fr',
                  title: Text('Français'),
                ),
                RadioListTile<String>(
                  value: 'en',
                  title: Text('English'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        SectionCard(
          title: 'Mon profil & Informations',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                auth.displayName ?? 'Utilisateur',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
              const SizedBox(height: AppTokens.space1),
              Text(
                'E-mail : ${auth.email ?? '—'}',
                style: const TextStyle(color: AppTokens.textMuted),
              ),
              if (auth.phone != null && auth.phone!.isNotEmpty) ...[
                const SizedBox(height: AppTokens.space1),
                Text(
                  'Téléphone : ${auth.phone}',
                  style: const TextStyle(color: AppTokens.textMuted),
                ),
              ],
              const SizedBox(height: AppTokens.space1),
              Text(
                'Rôle : ${auth.currentMembership?.role ?? (auth.platformAdmin ? 'PLATFORM_ADMIN' : 'Membre')}',
                style: const TextStyle(color: AppTokens.textMuted),
              ),
              const SizedBox(height: AppTokens.space3),
              Wrap(
                spacing: AppTokens.space2,
                runSpacing: AppTokens.space2,
                children: [
                  FilledButton.icon(
                    onPressed: () => _showEditProfileDialog(context, ref, auth),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier mon profil'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showChangePasswordDialog(context, ref),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Changer de mot de passe'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        SectionCard(
          title: l10n.tenant,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(auth.currentMembership?.tenantName ?? 'Exploitation active'),
              const SizedBox(height: AppTokens.space2),
              Text(
                'Identifiant : ${auth.tenantId ?? AppConfig.defaultTenantId}',
                style: const TextStyle(color: AppTokens.textMuted),
              ),
              const SizedBox(height: AppTokens.space2),
              Text(
                'Compte : ${auth.email ?? '—'}',
                style: const TextStyle(color: AppTokens.textMuted),
              ),
              const SizedBox(height: AppTokens.space3),
              OutlinedButton.icon(
                onPressed: () => context.go('/select-tenant'),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Changer d’exploitation'),
              ),
              const SizedBox(height: AppTokens.space2),
              OutlinedButton.icon(
                onPressed: () => context.go('/settings/subscription'),
                icon: const Icon(Icons.card_membership),
                label: const Text('Gérer l’abonnement et les quotas'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        SectionCard(
          title: 'Équipe',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rôles, accès par ferme et invitations.',
                style: TextStyle(color: AppTokens.textMuted),
              ),
              const SizedBox(height: AppTokens.space3),
              OutlinedButton.icon(
                onPressed: () => context.go('/members'),
                icon: const Icon(Icons.group),
                label: const Text('Gérer les membres'),
              ),
            ],
          ),
        ),
        if (auth.platformAdmin) ...[
          const SizedBox(height: AppTokens.space4),
          SectionCard(
            title: 'Administration Plateforme',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Supervision globale des tenants, métriques et annonces.',
                  style: TextStyle(color: AppTokens.textMuted),
                ),
                const SizedBox(height: AppTokens.space3),
                FilledButton.icon(
                  onPressed: () => context.go('/platform'),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Console Plateforme Admin'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppTokens.space4),
        SectionCard(
          title: 'Fichiers et partage',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Générez des exports PDF ou Excel et partagez-les par lien signé.',
                style: TextStyle(color: AppTokens.textMuted),
              ),
              const SizedBox(height: AppTokens.space3),
              Wrap(
                spacing: AppTokens.space2,
                runSpacing: AppTokens.space2,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.go('/files/exports'),
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Exports'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/files/share'),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Liens de partage'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        SectionCard(
          title: 'Notifications',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    push.isEnabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: push.isEnabled
                        ? AppTokens.success
                        : AppTokens.textMuted,
                  ),
                  const SizedBox(width: AppTokens.space2),
                  Expanded(child: Text(_pushStatus(push))),
                ],
              ),
              if (push.error != null) ...[
                const SizedBox(height: AppTokens.space2),
                Text(
                  push.error!,
                  style: const TextStyle(color: AppTokens.danger),
                ),
              ],
              const SizedBox(height: AppTokens.space3),
              Wrap(
                spacing: AppTokens.space2,
                runSpacing: AppTokens.space2,
                children: [
                  if (push.needsPermission)
                    FilledButton.icon(
                      onPressed: push.busy
                          ? null
                          : () => ref
                              .read(pushControllerProvider.notifier)
                              .requestPermission(),
                      icon: const Icon(Icons.notifications_on_outlined),
                      label: const Text('Activer les notifications'),
                    ),
                  if (push.isEnabled)
                    OutlinedButton.icon(
                      onPressed: push.busy
                          ? null
                          : () =>
                              ref.read(pushControllerProvider.notifier).disable(),
                      icon: const Icon(Icons.notifications_off_outlined),
                      label: const Text('Désactiver'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.go('/notifications/preferences'),
                    icon: const Icon(Icons.tune),
                    label: const Text('Préférences'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        SectionCard(
          title: 'Sécurité',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Protégez l’accès mobile hors ligne par un code PIN.',
                style: TextStyle(color: AppTokens.textMuted),
              ),
              const SizedBox(height: AppTokens.space3),
              OutlinedButton.icon(
                onPressed: () => context.go('/pin'),
                icon: const Icon(Icons.pin),
                label: const Text('Configurer ou vérifier le PIN'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        SectionCard(
          title: 'Synchronisation',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    sync.online
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_off_outlined,
                    color: sync.online
                        ? AppTokens.success
                        : AppTokens.warning,
                  ),
                  const SizedBox(width: AppTokens.space2),
                  Text(sync.online ? 'En ligne' : 'Hors ligne'),
                ],
              ),
              const SizedBox(height: AppTokens.space2),
              Text(
                'Dernière synchronisation : ${_formatSyncDate(sync.lastSyncAt)}',
                style: const TextStyle(color: AppTokens.textMuted),
              ),
              Text(
                '${sync.pending} écriture(s) en attente',
                style: const TextStyle(color: AppTokens.textMuted),
              ),
              if (sync.conflicts > 0)
                Text(
                  '${sync.conflicts} conflit(s) à résoudre',
                  style: const TextStyle(color: AppTokens.danger),
                ),
              if (sync.error != null) ...[
                const SizedBox(height: AppTokens.space2),
                Text(
                  sync.error!,
                  style: const TextStyle(color: AppTokens.danger),
                ),
              ],
              const SizedBox(height: AppTokens.space3),
              Wrap(
                spacing: AppTokens.space2,
                runSpacing: AppTokens.space2,
                children: [
                  FilledButton.icon(
                    onPressed: sync.syncing
                        ? null
                        : () => ref
                            .read(syncControllerProvider.notifier)
                            .syncNow(),
                    icon: sync.syncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(
                      sync.syncing ? 'Synchronisation...' : 'Synchroniser',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/sync/conflicts'),
                    icon: const Icon(Icons.sync_problem_outlined),
                    label: const Text('Conflits'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
          label: Text(l10n.logout),
        ),
      ],
    );
  }

  static String _pushStatus(PushState push) {
    if (!push.supported) {
      return 'Notifications push non configurées sur cet appareil.';
    }
    if (push.isEnabled) {
      return 'Notifications push activées sur cet appareil.';
    }
    return switch (push.permission) {
      PushPermission.granted => 'Autorisation accordée, enregistrement en cours…',
      PushPermission.denied =>
        'Notifications refusées dans les réglages du système.',
      PushPermission.notDetermined =>
        'Autorisez les notifications pour recevoir les alertes.',
      PushPermission.unsupported =>
        'Notifications push non configurées sur cet appareil.',
    };
  }

  static String _formatSyncDate(DateTime? value) {
    if (value == null) {
      return 'jamais';
    }
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  static void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    AuthState auth,
  ) {
    final nameCtrl = TextEditingController(text: auth.displayName ?? '');
    final phoneCtrl = TextEditingController(text: auth.phone ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        bool saving = false;
        String? error;

        return StatefulBuilder(
          builder: (dialogCtx, setState) {
            return AlertDialog(
              title: const Text('Modifier mon profil'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (error != null) ...[
                      Text(error!, style: const TextStyle(color: AppTokens.danger)),
                      const SizedBox(height: AppTokens.space2),
                    ],
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet *',
                        hintText: 'Ex: Jean Dupont',
                      ),
                    ),
                    const SizedBox(height: AppTokens.space3),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de téléphone',
                        hintText: 'Ex: +229 97 00 00 00',
                      ),
                    ),
                    const SizedBox(height: AppTokens.space2),
                    Text(
                      'Compte : ${auth.email ?? ''}',
                      style: const TextStyle(color: AppTokens.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            setState(() => error = 'Le nom complet est obligatoire.');
                            return;
                          }
                          setState(() {
                            saving = true;
                            error = null;
                          });
                          try {
                            await ref.read(authControllerProvider.notifier).updateProfile(
                                  fullName: name,
                                  phone: phoneCtrl.text.trim(),
                                );
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profil mis à jour avec succès.'),
                                  backgroundColor: AppTokens.success,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              saving = false;
                              error = 'Erreur lors de la mise à jour : $e';
                            });
                          }
                        },
                  child: Text(saving ? 'Enregistrement…' : 'Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _showChangePasswordDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        bool saving = false;
        String? error;

        return StatefulBuilder(
          builder: (dialogCtx, setState) {
            return AlertDialog(
              title: const Text('Changer de mot de passe'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (error != null) ...[
                      Text(error!, style: const TextStyle(color: AppTokens.danger)),
                      const SizedBox(height: AppTokens.space2),
                    ],
                    TextField(
                      controller: currentCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe actuel',
                      ),
                    ),
                    const SizedBox(height: AppTokens.space3),
                    TextField(
                      controller: newCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        helperText: 'Minimum 12 caractères',
                      ),
                    ),
                    const SizedBox(height: AppTokens.space3),
                    TextField(
                      controller: confirmCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmer le nouveau mot de passe',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (currentCtrl.text.isEmpty) {
                            setState(() => error = 'Renseignez le mot de passe actuel.');
                            return;
                          }
                          if (newCtrl.text.length < 12) {
                            setState(() => error = 'Au moins 12 caractères requis.');
                            return;
                          }
                          if (newCtrl.text != confirmCtrl.text) {
                            setState(() => error = 'Les mots de passe ne correspondent pas.');
                            return;
                          }
                          setState(() {
                            saving = true;
                            error = null;
                          });
                          try {
                            await ref.read(authControllerProvider.notifier).changePassword(
                                  currentPassword: currentCtrl.text,
                                  newPassword: newCtrl.text,
                                );
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mot de passe modifié avec succès.'),
                                  backgroundColor: AppTokens.success,
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              saving = false;
                              error = 'Échec : mot de passe actuel invalide ou erreur serveur.';
                            });
                          }
                        },
                  child: Text(saving ? 'Modification…' : 'Changer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
