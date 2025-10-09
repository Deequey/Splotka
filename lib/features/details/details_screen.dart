import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/models/pattern_model.dart';
import '../../data/services/file_service.dart';
import '../../providers/pattern_providers.dart';

class DetailsScreen extends ConsumerWidget {
  final String patternId;

  const DetailsScreen({super.key, required this.patternId});

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
