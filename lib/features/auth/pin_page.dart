import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/pin_service.dart';
import '../../core/theme/app_tokens.dart';

class PinPage extends ConsumerStatefulWidget {
  const PinPage({super.key});

  @override
  ConsumerState<PinPage> createState() => _PinPageState();
}

class _PinPageState extends ConsumerState<PinPage> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = true;
  bool _setupMode = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _detectMode();
  }

  Future<void> _detectMode() async {
    final hasPin = await ref.read(pinServiceProvider).hasPin();
    if (mounted) {
      setState(() {
        _setupMode = !hasPin;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    final pin = _pinController.text;
    if (pin.length < 4 || pin.length > 8) {
      setState(() => _error = 'Le PIN doit contenir 4 à 8 chiffres.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final service = ref.read(pinServiceProvider);
    try {
      if (_setupMode) {
        if (pin != _confirmController.text) {
          setState(() => _error = 'Les deux PIN ne correspondent pas.');
          return;
        }
        await service.setPin(pin);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN configuré.')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        final valid = await service.verifyPin(pin);
        if (!valid) {
          if (mounted) {
            setState(() => _error = 'PIN incorrect.');
          }
          return;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN vérifié.')),
          );
          Navigator.of(context).pop(true);
        }
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
      appBar: AppBar(title: Text(_setupMode ? 'Configurer le PIN' : 'Déverrouiller')),
      body: SafeArea(
        child: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTokens.space6),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _setupMode
                              ? 'Choisissez un code PIN pour déverrouiller l’application hors ligne.'
                              : 'Saisissez votre code PIN.',
                          style: const TextStyle(color: AppTokens.textMuted),
                        ),
                        const SizedBox(height: AppTokens.space6),
                        TextField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 8,
                          decoration: const InputDecoration(labelText: 'Code PIN'),
                        ),
                        if (_setupMode) ...[
                          const SizedBox(height: AppTokens.space3),
                          TextField(
                            controller: _confirmController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 8,
                            decoration: const InputDecoration(
                              labelText: 'Confirmer le PIN',
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTokens.space4),
                        FilledButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_setupMode ? 'Enregistrer' : 'Déverrouiller'),
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
    );
  }
}
