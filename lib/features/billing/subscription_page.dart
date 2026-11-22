import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnement et Quotas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan Actuel : PRO',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Statut : Actif (Paiement mensuel validé)'),
                  const SizedBox(height: 4),
                  const Text('Quotas utilisés : 142 / 5 000 animaux'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Autres forfaits disponibles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildPlanCard(context, 'Starter', '9 900 XOF/mois', '1 ferme, 500 animaux'),
          _buildPlanCard(context, 'Professionnel', '24 900 XOF/mois', '5 fermes, 5 000 animaux'),
          _buildPlanCard(context, 'Entreprise', 'Sur devis', 'Fermes et cheptel illimités'),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String title, String price, String desc) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$price • $desc'),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text('Sélectionner'),
        ),
      ),
    );
  }
}
