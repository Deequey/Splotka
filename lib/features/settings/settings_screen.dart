import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // --- NOWA METODA: Wyślij opinię ---
  void _sendFeedback(BuildContext context) async {
    const String email = 'dawidjarczyk1@gmail.com';
    const String subject = 'Opinia o aplikacji Crofty';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie można otworzyć aplikacji email.')),
      );
    }
  }

  // --- NOWA METODA: Pokaż "O aplikacji" ---
  void _showAboutDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    showAboutDialog(
      context: context,
      applicationName: 'Crofty',
      applicationVersion: packageInfo.version,
      applicationLegalese: '© 2025 Deequey. Wszelkie prawa zastrzeżone.',
      children: <Widget>[
        const SizedBox(height: 16),
        const Text('Twoja osobista biblioteka wzorów dziewiarskich.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _buildSectionTitle(context, 'Wygląd'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Tryb ciemny'),
            subtitle: Text(isDarkMode ? 'Włączony' : 'Wyłączony'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
            ),
          ),
          const Divider(),
          _buildSectionTitle(context, 'Informacje'),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Wyślij opinię'),
            onTap: () => _sendFeedback(context),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('O aplikacji'),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  // Metoda pomocnicza do tworzenia tytułów sekcji
  Padding _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
      ),
    );
  }
}
