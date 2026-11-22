import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_tokens.dart';

class SelectTenantPage extends ConsumerStatefulWidget {
  const SelectTenantPage({super.key});

  @override
  ConsumerState<SelectTenantPage> createState() => _SelectTenantPageState();
}

class _SelectTenantPageState extends ConsumerState<SelectTenantPage> {
  String? _pending;
  String? _error;

  Future<void> _select(String tenantId) async {
    if (_pending != null) {
      return;
    }
    setState(() {
      _pending = tenantId;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).switchTenant(tenantId);
      if (mounted) {
        context.go('/dashboard');
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _pending = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final memberships = auth.memberships;

    return Scaffold(
      appBar: AppBar(title: const Text('Choisir une exploitation')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            const Text(
              'Sélectionnez l’exploitation sur laquelle travailler.',
              style: TextStyle(color: AppTokens.textMuted),
            ),
            const SizedBox(height: AppTokens.space4),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppTokens.danger)),
              const SizedBox(height: AppTokens.space4),
            ],
            if (memberships.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppTokens.space4),
                  child: Text('Aucune exploitation disponible pour ce compte.'),
                ),
              ),
            for (final membership in memberships)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.agriculture)),
                  title: Text(membership.tenantName),
                  subtitle: Text(membership.role),
                  trailing: membership.tenantId == auth.tenantId
                      ? const Chip(label: Text('Active'))
                      : _pending == membership.tenantId
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TextButton(
                              onPressed: () => _select(membership.tenantId),
                              child: const Text('Basculer'),
                            ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
