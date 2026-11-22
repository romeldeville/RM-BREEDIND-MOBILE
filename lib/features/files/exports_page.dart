import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/files/file_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

const exportTypeLabels = <String, String>{
  'ANIMALS_XLSX': 'Liste des animaux (Excel)',
  'LOTS_XLSX': 'Liste des lots (Excel)',
  'FINANCIALS_XLSX': 'Finances (Excel)',
  'ANIMAL_SHEET': 'Fiche animal (PDF)',
  'HEALTH_BOOKLET': 'Carnet sanitaire (PDF)',
  'SALE_RECEIPT': 'Reçu de vente (PDF)',
  'SALES_REGISTER': 'Registre des ventes (PDF)',
  'LOT_BALANCE': 'Bilan de lot (PDF)',
};

const _idTypes = {
  'ANIMAL_SHEET': 'animalId',
  'HEALTH_BOOKLET': 'animalId',
  'SALE_RECEIPT': 'saleId',
  'LOT_BALANCE': 'lotId',
};

const _dateTypes = {'SALES_REGISTER', 'FINANCIALS_XLSX'};

class ExportsPage extends ConsumerStatefulWidget {
  const ExportsPage({super.key});

  @override
  ConsumerState<ExportsPage> createState() => _ExportsPageState();
}

class _ExportsPageState extends ConsumerState<ExportsPage> {
  final _idController = TextEditingController();
  final _searchController = TextEditingController();
  final _statusController = TextEditingController();

  String _type = 'ANIMALS_XLSX';
  DateTime? _from;
  DateTime? _to;
  List<ExportJobInfo> _jobs = const [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  String? _actionError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _idController.dispose();
    _searchController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final jobs = await ref.read(fileRepositoryProvider).exportJobs();
      if (mounted) {
        setState(() => _jobs = jobs);
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() => _error = failure.message);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _submit() async {
    final idKey = _idTypes[_type];
    if (idKey != null && _idController.text.trim().isEmpty) {
      setState(() => _actionError = 'Renseignez l’identifiant requis pour cet export.');
      return;
    }
    setState(() {
      _submitting = true;
      _actionError = null;
    });
    try {
      final job = await ref.read(fileRepositoryProvider).createExportJob(
            type: _type,
            params: _params(idKey),
          );
      if (mounted) {
        setState(() => _jobs = [job, ..._jobs]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export lancé.')),
        );
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() => _actionError = failure.message);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Map<String, dynamic> _params(String? idKey) {
    final params = <String, dynamic>{};
    if (idKey != null) {
      params[idKey] = _idController.text.trim();
    }
    if (_dateTypes.contains(_type)) {
      if (_from != null) {
        params['from'] = _isoDate(_from!);
      }
      if (_to != null) {
        params['to'] = _isoDate(_to!);
      }
    }
    if (_type == 'ANIMALS_XLSX' && _searchController.text.trim().isNotEmpty) {
      params['search'] = _searchController.text.trim();
    }
    if ((_type == 'ANIMALS_XLSX' || _type == 'LOTS_XLSX') &&
        _statusController.text.trim().isNotEmpty) {
      params['status'] = _statusController.text.trim().toUpperCase();
    }
    return params;
  }

  Future<void> _pickDate({required bool from}) async {
    final now = DateTime.now();
    final initial = (from ? _from : _to) ?? now;
    final value = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (value != null) {
      setState(() {
        if (from) {
          _from = value;
        } else {
          _to = value;
        }
      });
    }
  }

  Future<void> _showDownload(ExportJobInfo job) async {
    try {
      final url = await ref.read(fileRepositoryProvider).exportDownloadUrl(job.id);
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Lien de téléchargement'),
          content: SelectableText(url),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fermer'),
            ),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copier'),
            ),
          ],
        ),
      );
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() => _actionError = failure.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final idKey = _idTypes[_type];
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: [
        SectionCard(
          title: 'Nouvel export',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type d’export'),
                items: exportTypeLabels.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                      _actionError = null;
                    });
                  }
                },
              ),
              if (idKey != null) ...[
                const SizedBox(height: AppTokens.space3),
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: idKey == 'animalId'
                        ? 'Identifiant de l’animal'
                        : idKey == 'saleId'
                            ? 'Identifiant de la vente'
                            : 'Identifiant du lot',
                  ),
                ),
              ],
              if (_dateTypes.contains(_type)) ...[
                const SizedBox(height: AppTokens.space3),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(from: true),
                        icon: const Icon(Icons.event),
                        label: Text('Du ${_dateLabel(_from)}'),
                      ),
                    ),
                    const SizedBox(width: AppTokens.space2),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(from: false),
                        icon: const Icon(Icons.event),
                        label: Text('Au ${_dateLabel(_to)}'),
                      ),
                    ),
                  ],
                ),
              ],
              if (_type == 'ANIMALS_XLSX') ...[
                const SizedBox(height: AppTokens.space3),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Recherche (facultatif)',
                  ),
                ),
              ],
              if (_type == 'ANIMALS_XLSX' || _type == 'LOTS_XLSX') ...[
                const SizedBox(height: AppTokens.space3),
                TextField(
                  controller: _statusController,
                  decoration: const InputDecoration(
                    labelText: 'Statut (facultatif, ex. ACTIVE)',
                  ),
                ),
              ],
              if (_actionError != null) ...[
                const SizedBox(height: AppTokens.space3),
                Text(
                  _actionError!,
                  style: const TextStyle(color: AppTokens.danger),
                ),
              ],
              const SizedBox(height: AppTokens.space4),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_download_outlined),
                label: Text(_submitting ? 'Génération…' : 'Générer l’export'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        SectionCard(
          title: 'Mes exports',
          trailing: IconButton(
            tooltip: 'Rafraîchir',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
          child: _buildJobs(),
        ),
      ],
    );
  }

  Widget _buildJobs() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.space6),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Text(_error!, style: const TextStyle(color: AppTokens.danger));
    }
    if (_jobs.isEmpty) {
      return const EmptyState(
        message: 'Aucun export pour le moment.',
        icon: Icons.folder_open_outlined,
      );
    }
    return Column(
      children: [
        for (final job in _jobs) ...[
          _JobTile(
            job: job,
            onDownload: () => _showDownload(job),
            onShare: () => context.go('/files/share?export=${job.id}'),
          ),
          if (job != _jobs.last) const Divider(),
        ],
      ],
    );
  }

  static String _isoDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static String _dateLabel(DateTime? date) {
    if (date == null) {
      return 'jj/mm/aaaa';
    }
    return _isoDate(date);
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile({
    required this.job,
    required this.onDownload,
    required this.onShare,
  });

  final ExportJobInfo job;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final isPdf = (job.mimeType ?? '').contains('pdf');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isPdf ? Icons.picture_as_pdf_outlined : Icons.table_chart_outlined,
        color: AppTokens.primary,
      ),
      title: Text(job.filename ?? exportTypeLabels[job.type] ?? job.type),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_statusLabel(job.status)),
          if (job.rowCount != null)
            Text(
              '${job.rowCount} ligne(s)',
              style: const TextStyle(color: AppTokens.textMuted),
            ),
          if (job.errorMessage != null)
            Text(
              job.errorMessage!,
              style: const TextStyle(color: AppTokens.danger),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (job.isDone)
            IconButton(
              tooltip: 'Télécharger',
              onPressed: onDownload,
              icon: const Icon(Icons.download_outlined),
            ),
          if (job.isDone)
            IconButton(
              tooltip: 'Partager',
              onPressed: onShare,
              icon: const Icon(Icons.share_outlined),
            ),
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    return switch (status) {
      'PENDING' => 'En attente',
      'RUNNING' => 'En cours',
      'DONE' => 'Terminé',
      'FAILED' => 'Échec',
      _ => status,
    };
  }
}
