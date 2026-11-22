import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/i18n/locale_controller.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) {
        final memberships = ref.read(authControllerProvider).memberships;
        context.go(memberships.length > 1 ? '/select-tenant' : '/dashboard');
      }
    } on MfaRequiredException catch (error) {
      if (mounted) {
        context.go(
          '/otp?challenge=${Uri.encodeQueryComponent(error.challengeId)}',
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

  Future<void> _enterDemo() async {
    await ref.read(authControllerProvider.notifier).loginDemo();
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTokens.primary,
                            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                          ),
                          child: const Text(
                            'RM',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              ref.read(localeControllerProvider.notifier).toggle(),
                          child: Text(locale.languageCode == 'fr' ? 'EN' : 'FR'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space6),
                    Text(
                      l10n.loginTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppTokens.space1),
                    Text(
                      l10n.loginSubtitle,
                      style: const TextStyle(color: AppTokens.textMuted),
                    ),
                    const SizedBox(height: AppTokens.space6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username],
                      decoration: InputDecoration(labelText: l10n.email),
                      validator: (value) =>
                          value == null || !value.contains('@') ? l10n.email : null,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(labelText: l10n.password),
                      validator: (value) => value == null || value.length < 8
                          ? '8 caractères minimum'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppTokens.space3),
                      Text(
                        _error!,
                        style: const TextStyle(color: AppTokens.danger),
                      ),
                    ],
                    const SizedBox(height: AppTokens.space6),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.signIn),
                    ),
                    const SizedBox(height: AppTokens.space3),
                    TextButton(
                      onPressed: _submitting
                          ? null
                          : () => context.go(
                                '/otp?destination=${Uri.encodeQueryComponent(
                                  _emailController.text.trim(),
                                )}',
                              ),
                      child: const Text('Recevoir un code de connexion'),
                    ),
                    const SizedBox(height: AppTokens.space1),
                    OutlinedButton(
                      onPressed: _submitting ? null : _enterDemo,
                      child: Text(l10n.demoMode),
                    ),
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
