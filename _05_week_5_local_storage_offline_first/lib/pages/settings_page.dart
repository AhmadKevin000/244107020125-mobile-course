import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: darkModeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Gagal memuat pengaturan: $error')),
        data: (darkMode) => ListView(
          children: [
            SwitchListTile(
              title: const Text('Mode gelap'),
              subtitle: const Text('Preferensi tema disimpan lokal'),
              value: darkMode,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Simulasi offline'),
              subtitle: const Text(
                  'Paksa mode offline untuk demo & testing cache-first'),
              value: forceOffline,
              onChanged: (value) =>
                  ref.read(forceOfflineProvider.notifier).set(value),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Terakhir dibuka'),
              subtitle: Text(
                lastOpenedAsync.value ?? 'Belum pernah dicatat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
