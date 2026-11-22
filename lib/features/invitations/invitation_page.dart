import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_tokens.dart';

class InvitationPage extends ConsumerStatefulWidget {
  const InvitationPage({super.key, this.token});

  final String? token;

  @override
  ConsumerState<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends ConsumerState<InvitationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    final token = widget.token;
    if (token == null || token.isEmpty) {
      setState(() => _error = 'Lien d’invitation invalide ou incomplet.');
      return;
    }
    if (!_formKey.currentState!.validate() || _submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).acceptInvitation(
            token: token,
            fullName: _nameController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation acceptée, vous pouvez vous connecter.')),
        );
        context.go('/login');
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final missingToken = widget.token == null || widget.token!.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre l’exploitation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.space6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: missingToken
                  ? const Text(
                      'Lien d’invitation invalide ou incomplet.',
                      style: TextStyle(color: AppTokens.danger),
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Créez votre compte pour accepter l’invitation.',
                            style: TextStyle(color: AppTokens.textMuted),
                          ),
                          const SizedBox(height: AppTokens.space6),
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(labelText: 'Nom complet'),
                            validator: (value) =>
                                value == null || value.trim().length < 2
                                    ? 'Nom requis'
                                    : null,
                          ),
                          const SizedBox(height: AppTokens.space4),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Mot de passe (12 caractères minimum)',
                            ),
                            validator: (value) =>
                                value == null || value.length < 12
                                    ? '12 caractères minimum'
                                    : null,
                          ),
                          const SizedBox(height: AppTokens.space6),
                          FilledButton(
                            onPressed: _submitting ? null : _accept,
                            child: _submitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Accepter l’invitation'),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: AppTokens.space4),
                            Text(
                              _error!,
                              style: const TextStyle(color: AppTokens.danger),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
