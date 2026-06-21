import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:restart_app/restart_app.dart';
import '../../core/theme.dart';
import '../../data/services/backup_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // --- Wyślij opinię z informacją o wersji i systemie ---
  void _sendFeedback(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    const String email = 'dawidjarczyk1@gmail.com';
    final String subject = 'Opinia o aplikacji Splotka (v${packageInfo.version})';
    
    final String body = '\n\n---\nSystem: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}\nWersja apki: ${packageInfo.version}+${packageInfo.buildNumber}';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } else {
      // Spróbujmy wymusić otwarcie, jeśli canLaunchUrl zawiedzie (częste na Androidzie 11+)
      try {
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Błąd: Nie znaleziono aplikacji e-mail.')),
          );
        }
      }
    }
  }

  // --- Pokaż "O aplikacji" w ładniejszej formie ---
  void _showAboutDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    
    if (!context.mounted) return;

    showAboutDialog(
      context: context,
      applicationName: 'Splotka',
      applicationVersion: '${packageInfo.version} (${packageInfo.buildNumber})',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 40),
      ),
      applicationLegalese: '© 2025 Deequey.\nWszystkie prawa zastrzeżone.',
      children: <Widget>[
        const SizedBox(height: 16),
        const Text(
          'Splotka to prosty i przejrzysty organizer Twoich wzorów dziewiarskich i szydełkowych. '
          'Została stworzona, abyś mogła cieszyć się swoim hobby bez chaosu w plikach PDF.',
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 12),
        const Text('Dziękuję za korzystanie z aplikacji! ❤️'),
      ],
    );
  }

  void _handleExport(BuildContext context, WidgetRef ref) async {
    if (ref.read(hapticNotifierProvider)) HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Wybierz sposób eksportu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Zapisz na telefonie'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await BackupService().generateBackupFile();
                if (file != null) {
                  final params = SaveFileDialogParams(sourceFilePath: file.path);
                  await FlutterFileDialog.saveFile(params: params);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Udostępnij plik'),
              subtitle: const Text('Discord, WhatsApp, Email...'),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await BackupService().generateBackupFile();
                if (file != null) {
                  await Share.shareXFiles([XFile(file.path)], text: 'Moja kopia zapasowa ze Splotki');
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleImport(BuildContext context, WidgetRef ref) async {
    if (ref.read(hapticNotifierProvider)) HapticFeedback.mediumImpact();

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importowanie danych'),
        content: const Text(
          'Wszystkie obecne wzory zostaną zastąpione danymi z pliku. '
          'Po zakończeniu aplikacja zostanie uruchomiona ponownie. Czy kontynuować?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Anuluj')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Importuj i restartuj', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await BackupService().restoreBackup();
      if (success) {
        Restart.restartApp();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Błąd podczas importowania pliku.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeNotifierProvider);
    final isHapticEnabled = ref.watch(hapticNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _buildSectionTitle(context, 'Wygląd i haptyka'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Tryb ciemny'),
            subtitle: Text(isDarkMode ? 'Włączony' : 'Wyłączony'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                if (isHapticEnabled) HapticFeedback.lightImpact();
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.vibration),
            title: const Text('Wibracje (Haptyka)'),
            subtitle: const Text('Delikatne wibracje przy klikaniu'),
            trailing: Switch(
              value: isHapticEnabled,
              onChanged: (value) {
                if (!isHapticEnabled) HapticFeedback.mediumImpact();
                ref.read(hapticNotifierProvider.notifier).toggleHaptic();
              },
            ),
          ),
          const Divider(),
          _buildSectionTitle(context, 'Kopia zapasowa'),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('Eksportuj dane'),
            subtitle: const Text('Zapisz wszystkie wzory do jednego pliku'),
            onTap: () => _handleExport(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.download_for_offline_outlined),
            title: const Text('Importuj dane'),
            subtitle: const Text('Przywróć wzory z pliku kopii'),
            onTap: () => _handleImport(context, ref),
          ),
          const Divider(),
          _buildSectionTitle(context, 'Informacje'),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Wyślij opinię'),
            subtitle: const Text('Podziel się sugestiami lub zgłoś błąd'),
            onTap: () {
              if (isHapticEnabled) HapticFeedback.lightImpact();
              _sendFeedback(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('O aplikacji'),
            subtitle: const Text('Wersja, licencja i autor'),
            onTap: () {
              if (isHapticEnabled) HapticFeedback.lightImpact();
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

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
