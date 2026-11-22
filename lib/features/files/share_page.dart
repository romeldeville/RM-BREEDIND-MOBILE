import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/files/file_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

const _ttlChoices = <int, String>{
  24: '24 heures',
  72: '3 jours',
  168: '7 jours',
  720: '30 jours',
};

/// P14-10 / P14-11 - creation, copy and revocation of signed share links.
class SharePage extends ConsumerStatefulWidget {
  const SharePage({
    super.key,
    this.exportJobId,
    this.attachmentId,
    this.entityType,
    this.entityId,
  });

  final String? exportJobId;
  final String? attachmentId;
  final String? entityType;
  final String? entityId;

  @override
  ConsumerState<SharePage> createState() => _SharePageState();
}

class _SharePageState extends ConsumerState<SharePage> {
  late final TextEditingController _attachmentController =
      TextEditingController(text: widget.attachmentId ?? '');
  late final TextEditingController _exportController =
      TextEditingController(text: widget.exportJobId ?? '');
  late final TextEditingController _entityTypeController =
      TextEditingController(text: widget.entityType ?? '');
  late final TextEditingController _entityIdController =
      TextEditingController(text: widget.entityId ?? '');

  int _ttlHours = 168;
  List<ShareLinkInfo> _links = const [];
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
    _attachmentController.dispose();
    _exportController.dispose();
    _entityTypeController.dispose();
    _entityIdController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final links = await ref.read(fileRepositoryProvider).shareLinks();
      if (mounted) {
        setState(() => _links = links);
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

  Future<void> _create() async {
    final attachmentId = _attachmentController.text.trim();
    final exportJobId = _exportController.text.trim();
    if (attachmentId.isEmpty && exportJobId.isEmpty) {
      setState(() => _actionError =
          'Renseignez un identifiant de pièce jointe ou d’export.');
      return;
    }
    setState(() {
      _submitting = true;
      _actionError = null;
    });
    try {
      final link = await ref.read(fileRepositoryProvider).createShare(
            attachmentId: attachmentId.isEmpty ? null : attachmentId,
            exportJobId: exportJobId.isEmpty ? null : exportJobId,
            entityType:
                _entityTypeController.text.trim().isEmpty
                    ? null
                    : _entityTypeController.text.trim(),
            entityId: _entityIdController.text.trim().isEmpty
                ? null
                : _entityIdController.text.trim(),
            ttlHours: _ttlHours,
          );
      if (mounted) {
        setState(() => _links = [link, ..._links]);
        await Clipboard.setData(ClipboardData(text: link.url));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lien créé et copié.')),
          );
        }
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

  Future<void> _copy(ShareLinkInfo link) async {
    await Clipboard.setData(ClipboardData(text: link.url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lien copié.')),
      );
    }
  }

  Future<void> _revoke(ShareLinkInfo link) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Révoguer le lien ?'),
        content: Text(
          'Le lien « ${link.filename} » ne sera plus accessible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Révoquer'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      final revoked = await ref.read(fileRepositoryProvider).revokeShare(link.id);
      if (mounted) {
        setState(() => _links = [
              for (final existing in _links)
                if (existing.id == revoked.id) revoked else existing,
            ]);
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() => _actionError = failure.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: [
        SectionCard(
          title: 'Nouveau lien de partage',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _attachmentController,
                decoration: const InputDecoration(
                  labelText: 'Identifiant de pièce jointe (facultatif)',
                ),
              ),
              const SizedBox(height: AppTokens.space3),
              TextField(
                controller: _exportController,
                decoration: const InputDecoration(
                  labelText: 'Identifiant d’export (facultatif)',
                ),
              ),
              const SizedBox(height: AppTokens.space3),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _entityTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Type lié (ex. ANIMAL)',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTokens.space2),
                  Expanded(
                    child: TextField(
                      controller: _entityIdController,
                      decoration: const InputDecoration(
                        labelText: 'Identifiant lié',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space3),
              DropdownButtonFormField<int>(
                initialValue: _ttlHours,
                decoration: const InputDecoration(labelText: 'Durée de validité'),
                items: _ttlChoices.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _ttlHours = value);
                  }
                },
              ),
              if (_actionError != null) ...[
                const SizedBox(height: AppTokens.space3),
                Text(
                  _actionError!,
                  style: const TextStyle(color: AppTokens.danger),
                ),
              ],
              const SizedBox(height: AppTokens.space4),
              FilledButton.icon(
                onPressed: _submitting ? null : _create,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link_outlined),
                label: Text(_submitting ? 'Création…' : 'Créer le lien'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        SectionCard(
          title: 'Liens partagés',
          trailing: IconButton(
            tooltip: 'Rafraîchir',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
          child: _buildLinks(),
        ),
      ],
    );
  }

  Widget _buildLinks() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppTokens.space6),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Text(_error!, style: const TextStyle(color: AppTokens.danger));
    }
    if (_links.isEmpty) {
      return const EmptyState(
        message: 'Aucun lien de partage pour le moment.',
        icon: Icons.link_off_outlined,
      );
    }
    return Column(
      children: [
        for (final link in _links) ...[
          _ShareTile(
            link: link,
            onCopy: () => _copy(link),
            onRevoke: link.isActive ? () => _revoke(link) : null,
          ),
          if (link != _links.last) const Divider(),
        ],
      ],
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.link,
    required this.onCopy,
    required this.onRevoke,
  });

  final ShareLinkInfo link;
  final VoidCallback onCopy;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    final status = link.isRevoked
        ? 'Révoqué'
        : link.isExpired
            ? 'Expiré'
            : 'Actif';
    final color = link.isActive ? AppTokens.success : AppTokens.danger;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.insert_drive_file_outlined),
      title: Text(link.filename.isEmpty ? 'Document' : link.filename),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$status • ${link.accessCount} accès',
            style: TextStyle(color: color),
          ),
          if (link.expiresAt != null)
            Text(
              'Expire le ${_formatDate(link.expiresAt!)}',
              style: const TextStyle(color: AppTokens.textMuted),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Copier le lien',
            onPressed: onCopy,
            icon: const Icon(Icons.copy),
          ),
          if (onRevoke != null)
            IconButton(
              tooltip: 'Révoquer',
              onPressed: onRevoke,
              icon: const Icon(Icons.link_off),
            ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}
