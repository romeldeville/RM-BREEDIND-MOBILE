import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class BreedsPage extends ConsumerStatefulWidget {
  const BreedsPage({super.key, required this.speciesId});

  final String speciesId;

  @override
  ConsumerState<BreedsPage> createState() => _BreedsPageState();
}

class _BreedsPageState extends ConsumerState<BreedsPage> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  List<Breed> _breeds = const [];
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
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final breeds = await ref.read(referentialRepositoryProvider).breeds(widget.speciesId);
      if (mounted) {
        setState(() => _breeds = breeds);
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

  Future<void> _add() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Le nom de la race est obligatoire.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final breed = await ref.read(referentialRepositoryProvider).createBreed(
            widget.speciesId,
            {'name': _name.text.trim(), 'code': _code.text.trim()},
          );
      _name.clear();
      _code.clear();
      if (mounted) {
        setState(() => _breeds = [..._breeds, breed]);
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

  Future<void> _archive(Breed breed) async {
    try {
      await ref.read(referentialRepositoryProvider).archiveBreed(breed.id);
      if (mounted) {
        setState(() => _breeds = _breeds.where((b) => b.id != breed.id).toList());
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Races')),
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
                  title: 'Ajouter une race',
                  child: Column(
                    children: [
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Nom de la race'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _code,
                        decoration: const InputDecoration(labelText: 'Code'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _saving ? null : _add,
                          child: Text(_saving ? 'Enregistrement…' : 'Ajouter'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Races de l’espèce',
                  child: Column(
                    children: [
                      for (final breed in _breeds)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(breed.name),
                          subtitle: Text(breed.code ?? '—'),
                          trailing: IconButton(
                            icon: const Icon(Icons.archive_outlined),
                            tooltip: 'Archiver',
                            onPressed: () => _archive(breed),
                          ),
                        ),
                      if (_breeds.isEmpty)
                        const Text(
                          'Aucune race.',
                          style: TextStyle(color: AppTokens.textMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
