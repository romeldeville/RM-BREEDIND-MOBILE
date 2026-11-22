import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_tokens.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key, this.challengeId, this.destination});

  final String? challengeId;
  final String? destination;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _destinationController;
  final _codeController = TextEditingController();
  bool _submitting = false;
  bool _codeSent = false;
  String? _error;

  bool get _isMfa => widget.challengeId != null && widget.challengeId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController(text: widget.destination ?? '');
    _codeSent = _isMfa;
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty || _submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).requestOtp(destination);
      if (mounted) {
        setState(() => _codeSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code envoyé. Vérifiez votre boîte de réception.')),
        );
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

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate() || _submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final controller = ref.read(authControllerProvider.notifier);
      if (_isMfa) {
        await controller.verifyMfa(
          challengeId: widget.challengeId!,
          code: _codeController.text.trim(),
        );
      } else {
        await controller.verifyOtp(
          destination: _destinationController.text.trim(),
          code: _codeController.text.trim(),
        );
      }
      if (mounted) {
        final memberships = ref.read(authControllerProvider).memberships;
        context.go(memberships.length > 1 ? '/select-tenant' : '/dashboard');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isMfa ? 'Vérification en deux étapes' : 'Connexion par code'),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isMfa
                          ? 'Saisissez le code à 6 chiffres de votre application d’authentification.'
                          : 'Recevez un code à 6 chiffres par e-mail.',
                      style: const TextStyle(color: AppTokens.textMuted),
                    ),
                    const SizedBox(height: AppTokens.space6),
                    if (!_isMfa) ...[
                      TextFormField(
                        controller: _destinationController,
                        enabled: !_codeSent,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail ou téléphone',
                        ),
                        validator: (value) => value == null || !value.contains('@')
                            ? 'Adresse invalide'
                            : null,
                      ),
                      const SizedBox(height: AppTokens.space3),
                      if (!_codeSent)
                        FilledButton(
                          onPressed: _submitting ? null : _sendCode,
                          child: const Text('Envoyer le code'),
                        ),
                    ],
                    if (_codeSent) ...[
                      const SizedBox(height: AppTokens.space3),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Code à 6 chiffres',
                        ),
                        validator: (value) => value == null || value.trim().length != 6
                            ? 'Code invalide'
                            : null,
                      ),
                      const SizedBox(height: AppTokens.space4),
                      FilledButton(
                        onPressed: _submitting ? null : _verify,
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Vérifier'),
                      ),
                    ],
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
