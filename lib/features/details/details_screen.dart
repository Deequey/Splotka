import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/models/pattern_model.dart';
import '../../data/services/file_service.dart';
import '../../providers/pattern_providers.dart';

class DetailsScreen extends ConsumerWidget {
  final String patternId;

  const DetailsScreen({super.key, required this.patternId});

  void _showEditNameDialog(BuildContext context, WidgetRef ref, PatternModel pattern) {
    final textController = TextEditingController(text: pattern.customName);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Zmień nazwę wzoru'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Wpisz nową nazwę'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Zapisz'),
              onPressed: () {
                final newName = textController.text.trim();
                if (newName.isNotEmpty) {
                  final updatedPattern = pattern.copyWith(customName: newName);
                  ref.read(patternProvider.notifier).updatePattern(updatedPattern);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePattern(BuildContext context, WidgetRef ref, PatternModel pattern) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Potwierdź usunięcie'),
          content: Text('Czy na pewno chcesz usunąć wzór \"${pattern.customName}\"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Usuń'),
              onPressed: () async {
                await ref.read(fileServiceProvider).deletePattern(pattern);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patterns = ref.watch(patternProvider);
    final pattern = patterns.firstWhere((p) => p.id == patternId, orElse: () => PatternModel.empty());

    if (pattern.id.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Wzór nie został znaleziony.')),
      );
    }

    // Formatowanie daty
    final formattedDate = DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.parse(pattern.dateAdded));

    return Scaffold(
      appBar: AppBar(
        title: Text(pattern.customName),
        actions: [
          IconButton(
            icon: Icon(pattern.isFavourite ? Icons.star : Icons.star_border),
            onPressed: () {
              final updatedPattern = pattern.copyWith(isFavourite: !pattern.isFavourite);
              ref.read(patternProvider.notifier).updatePattern(updatedPattern);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditNameDialog(context, ref, pattern),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deletePattern(context, ref, pattern),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Podgląd miniaturki ---
          if (pattern.thumbnailPath.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(
                File(pattern.thumbnailPath),
                fit: BoxFit.cover,
                height: 250,
              ),
            ),
          const SizedBox(height: 24),

          // --- Sekcja z informacjami ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Oryginalna nazwa pliku'),
                    subtitle: Text(pattern.originalFileName, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Data dodania'),
                    subtitle: Text(formattedDate),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => OpenFilex.open(pattern.localFilePath),
        label: const Text('Otwórz PDF'),
        icon: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}
