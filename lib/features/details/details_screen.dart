import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/models/pattern_model.dart';
import '../../data/services/file_service.dart';
import '../../providers/pattern_providers.dart';

class DetailsScreen extends ConsumerWidget {
  final String patternId;

  const DetailsScreen({super.key, required this.patternId});

  // --- Metoda do pokazywania dialogu edycji nazwy ---
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

  // --- Metoda do usuwania wzoru ---
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
                await ref.read(fileServiceProvider).deletePattern(pattern.id, pattern.localFilePath);
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
        body: Center(
          child: Text('Wzór nie został znaleziony.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pattern.customName),
        actions: [
          // --- Przycisk Edytuj ---
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditNameDialog(context, ref, pattern),
          ),
          // --- Przycisk Usuń ---
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deletePattern(context, ref, pattern),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('To są szczegóły wzoru: ${pattern.customName}'),
            const SizedBox(height: 20),
            Text('Oryginalna nazwa pliku: ${pattern.originalFileName}'),
            Text('Data dodania: ${pattern.dateAdded}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => OpenFilex.open(pattern.localFilePath),
        label: const Text('Otwórz PDF'),
        icon: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}
