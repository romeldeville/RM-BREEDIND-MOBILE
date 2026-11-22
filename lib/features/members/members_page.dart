import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_tokens.dart';

class MembersPage extends ConsumerStatefulWidget {
  const MembersPage({super.key});

  @override
  ConsumerState<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  List<MemberInfo> _members = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tenantId = ref.read(authControllerProvider).tenantId;
    if (tenantId == null || tenantId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Aucune exploitation active.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final members =
          await ref.read(authRepositoryProvider).members(tenantId);
      if (mounted) {
        setState(() => _members = members);
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _invite() async {
    final emailController = TextEditingController();
    var role = 'WORKER';
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Inviter un membre'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              const SizedBox(height: AppTokens.space3),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Rôle'),
                items: const [
                  DropdownMenuItem(value: 'MANAGER', child: Text('Manager')),
                  DropdownMenuItem(value: 'WORKER', child: Text('Ouvrier')),
                  DropdownMenuItem(value: 'VET', child: Text('Vétérinaire')),
                  DropdownMenuItem(value: 'ACCOUNTANT', child: Text('Comptable')),
                ],
                onChanged: (value) => setDialogState(() => role = value ?? role),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
    if (submitted != true) {
      return;
    }
    final tenantId = ref.read(authControllerProvider).tenantId;
    final email = emailController.text.trim();
    emailController.dispose();
    if (tenantId == null || email.isEmpty) {
      return;
    }
    try {
      await ref.read(authRepositoryProvider).inviteMember(
            tenantId: tenantId,
            email: email,
            role: role,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation envoyée.')),
        );
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }

  Future<void> _remove(MemberInfo member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer ce membre ?'),
        content: Text('${member.fullName} (${member.email}) perdra l’accès.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final tenantId = ref.read(authControllerProvider).tenantId;
    if (tenantId == null) {
      return;
    }
    try {
      await ref.read(authRepositoryProvider).removeMember(
            tenantId: tenantId,
            membershipId: member.membershipId,
          );
      await _load();
    } on ApiFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membres')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _invite,
        icon: const Icon(Icons.person_add),
        label: const Text('Inviter'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(AppTokens.space4),
            children: [
              const Text(
                'Rôles, accès par ferme et invitations.',
                style: TextStyle(color: AppTokens.textMuted),
              ),
              const SizedBox(height: AppTokens.space4),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Column(
                  children: [
                    Text(_error!, style: const TextStyle(color: AppTokens.danger)),
                    const SizedBox(height: AppTokens.space2),
                    OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
                  ],
                )
              else
                for (final member in _members)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          member.fullName.isEmpty
                              ? '?'
                              : member.fullName.substring(0, 1).toUpperCase(),
                        ),
                      ),
                      title: Text(member.fullName),
                      subtitle: Text('${member.email} · ${member.role}'),
                      trailing: member.role == 'OWNER'
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.person_remove),
                              tooltip: 'Retirer',
                              onPressed: () => _remove(member),
                            ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
