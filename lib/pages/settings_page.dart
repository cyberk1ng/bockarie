import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Rate Tables'),
            subtitle: const Text('Manage carrier rates'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to rate tables
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology),
            title: const Text('AI Providers'),
            subtitle: const Text('Configure AI models'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to AI providers
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Bockaire v1.0.0'),
          ),
        ],
      ),
    );
  }
}
