import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/dashboard/dashboard_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  late DateTime _from;
  late DateTime _to;
  List<IndicatorValue> _indicators = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _from = DateTime(today.year, today.month, 1);
    _to = today;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final indicators = await ref.read(dashboardRepositoryProvider).indicators(
            from: _date(_from),
            to: _date(_to),
          );
      if (mounted) {
        setState(() => _indicators = indicators);
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

  Future<void> _pickDate({required bool start}) async {
    final initial = start ? _from : _to;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (start) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: [
        const Text(
          'Rapports détaillés par période.',
          style: TextStyle(color: AppTokens.textMuted),
        ),
        const SizedBox(height: AppTokens.space4),
        SectionCard(
          title: 'Période',
          child: Wrap(
            spacing: AppTokens.space3,
            runSpacing: AppTokens.space2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickDate(start: true),
                icon: const Icon(Icons.event_outlined),
                label: Text('Du ${_date(_from)}'),
              ),
              OutlinedButton.icon(
                onPressed: () => _pickDate(start: false),
                icon: const Icon(Icons.event_outlined),
                label: Text('Au ${_date(_to)}'),
              ),
              FilledButton(onPressed: _load, child: const Text('Appliquer')),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        SectionCard(
          title: 'Indicateurs',
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Column(
                      children: [
                        Text(_error!, style: const TextStyle(color: AppTokens.danger)),
                        const SizedBox(height: AppTokens.space2),
                        OutlinedButton(
                          onPressed: _load,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    )
                  : _indicators.isEmpty
                      ? const EmptyState(message: 'Aucun indicateur')
                      : Column(
                          children: [
                            for (final indicator in _indicators)
                              _indicatorTile(indicator),
                          ],
                        ),
        ),
      ],
    );
  }

  Widget _indicatorTile(IndicatorValue indicator) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(indicator.label),
      subtitle: Text(
        indicator.code,
        style: const TextStyle(color: AppTokens.textMuted, fontSize: 14),
      ),
      trailing: Text(
        _value(indicator),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: indicator.value == null ? AppTokens.textMuted : AppTokens.text,
        ),
      ),
    );
  }

  String _value(IndicatorValue indicator) {
    if (indicator.value == null) {
      return 'Indisponible';
    }
    final value = indicator.value!;
    final formatted = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    return indicator.unit.isEmpty ? formatted : '$formatted ${indicator.unit}';
  }

  String _date(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
