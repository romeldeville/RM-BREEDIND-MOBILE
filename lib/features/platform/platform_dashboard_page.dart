import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlatformDashboardPage extends ConsumerWidget {
  const PlatformDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Console Plateforme Admin'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(context, 'Exploitations', '42', Colors.indigo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(context, 'Animaux', '3 450', Colors.teal),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetricTile(context, 'MRR Plateforme', '1 045 800 XOF', Colors.deepPurple),
          const SizedBox(height: 24),
          const Text(
            'Derniers Tenants Inscrits',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(child: Text('FD')),
            title: const Text('Ferme Démo'),
            subtitle: const Text('Actif • Forfait PRO'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const CircleAvatar(child: Text('EB')),
            title: const Text('Élevage Bélier'),
            subtitle: const Text('Actif • Forfait STARTER'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 22)),
        ],
      ),
    );
  }
}
