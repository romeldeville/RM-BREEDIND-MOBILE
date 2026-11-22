import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class LotClosePage extends ConsumerStatefulWidget {
  const LotClosePage({super.key, required this.lotId});

  final String lotId;

  @override
  ConsumerState<LotClosePage> createState() => _LotClosePageState();
}

class _LotClosePageState extends ConsumerState<LotClosePage> {
  Lot? _lot;
  LotClosure? _closure;
  bool _loading = true;
  bool _closing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lot = await ref.read(herdRepositoryProvider).lot(widget.lotId);
      if (mounted) {
        setState(() => _lot = lot);
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

  Future<void> _close() async {
    setState(() {
      _closing = true;
      _error = null;
    });
    try {
      final closure = await ref.read(herdRepositoryProvider).closeLot(widget.lotId);
      if (mounted) {
        setState(() => _closure = closure);
        await _load();
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _closing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lot = _lot;
    return Scaffold(
      appBar: AppBar(title: const Text('Clôture du lot')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppTokens.space4),
              children: [
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: AppTokens.danger)),
                  const SizedBox(height: AppTokens.space3),
                ],
                SectionCard(
                  title: lot?.name ?? 'Lot',
                  child: Column(
                    children: [
                      _row('Statut', lot?.status ?? '-'),
                      _row('Effectif actuel', lot?.currentCount.toString() ?? '-'),
                      _row('Effectif initial', lot?.initialCount.toString() ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                if (lot != null && lot.status == 'CLOSED')
                  const SectionCard(
                    title: 'Lot clôturé',
                    child: Text('Ce lot est déjà clôturé.'),
                  )
                else if (lot != null)
                  SectionCard(
                    title: 'Clôturer',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (lot.currentCount > 0)
                          const Text(
                            "L'effectif doit être nul avant la clôture.",
                            style: TextStyle(color: AppTokens.danger),
                          )
                        else
                          const Text(
                            'La clôture calcule le bilan du lot.',
                            style: TextStyle(color: AppTokens.textMuted),
                          ),
                        const SizedBox(height: AppTokens.space3),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _closing || lot.currentCount > 0 ? null : _close,
                            icon: const Icon(Icons.lock_outline),
                            label: const Text('Clôturer le lot'),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_closure != null) ...[
                  const SizedBox(height: AppTokens.space4),
                  SectionCard(
                    title: 'Bilan',
                    child: Column(
                      children: [
                        _row(
                          'Taux de mortalité',
                          _closure!.mortalityRate?.toString() ?? '-',
                        ),
                        _row('Coût', _closure!.cost?.toString() ?? '-'),
                        _row('Clôturé le', _closure!.closedAt),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: AppTokens.textMuted)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
