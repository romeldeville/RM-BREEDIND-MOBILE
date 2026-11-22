import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/sales/sales_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'sales_shared.dart';

class ClientsPage extends ConsumerStatefulWidget {
  const ClientsPage({super.key});

  @override
  ConsumerState<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends ConsumerState<ClientsPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();

  List<Customer> _customers = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final customers = await ref.read(salesRepositoryProvider).customers();
      if (mounted) {
        setState(() => _customers = customers);
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

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Le nom est obligatoire.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(salesRepositoryProvider).createCustomer({
        'name': name,
        if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
        if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
        if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
      });
      _name.clear();
      _phone.clear();
      _email.clear();
      _address.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client enregistré')),
        );
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Nouveau client',
              child: Column(
                children: [
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(color: AppTokens.danger),
                    ),
                    const SizedBox(height: AppTokens.space2),
                  ],
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  TextField(
                    controller: _address,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Clients',
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _customers.isEmpty
                  ? const EmptyState(
                      message: 'Aucun client',
                      icon: Icons.people_outline,
                    )
                  : Column(
                      children: [
                        for (final customer in _customers)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.person_outline),
                            ),
                            title: Text(customer.name),
                            subtitle: Text(
                              customer.phone ?? customer.email ?? '-',
                            ),
                            trailing: Text(
                              formatAmount(customer.balance),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
