import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Tryb ciemny'),
            subtitle: Text(isDarkMode ? 'Włączony' : 'Wyłączony'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
            ),
          ),
          // Tutaj można dodać więcej opcji w przyszłości
        ],
      ),
    );
  }
}
