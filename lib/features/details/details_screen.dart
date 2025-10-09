import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/models/pattern_model.dart';
import '../../data/services/file_service.dart';
import '../../providers/pattern_providers.dart';

// ZMIANA: Konwersja na ConsumerStatefulWidget, aby zarządzać notatkami
class DetailsScreen extends ConsumerStatefulWidget {
  final String patternId;

  const DetailsScreen({super.key, required this.patternId});

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  late final TextEditingController _notesController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final pattern = ref.read(patternProvider).firstWhere((p) => p.id == widget.patternId);
    _notesController = TextEditingController(text: pattern.userNotes);

    _notesController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 700), () {
        final currentPattern = ref.read(patternProvider).firstWhere((p) => p.id == widget.patternId);
        if (currentPattern.userNotes != _notesController.text) {
          final updatedPattern = currentPattern.copyWith(userNotes: _notesController.text);
          ref.read(patternProvider.notifier).updatePattern(updatedPattern);
        }
      });
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patterns = ref.watch(patternProvider);
    final pattern = patterns.firstWhere((p) => p.id == widget.patternId, orElse: () => PatternModel.empty());

    if (pattern.id.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Wzór nie został znaleziony.')),
      );
    }

    final formattedDate = DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.parse(pattern.dateAdded));

    return Scaffold(
      appBar: AppBar(
        title: Text(pattern.customName),
        actions: [
          IconButton(
            icon: Icon(pattern.isFavourite ? Icons.star : Icons.star_border),
            onPressed: () => _toggleFavourite(pattern),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditNameDialog(context, pattern),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deletePattern(context, pattern),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (pattern.thumbnailPath.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(File(pattern.thumbnailPath), fit: BoxFit.cover, height: 250),
            ),
          const SizedBox(height: 24),

          // --- NOWA SEKCJA NOTATEK ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _notesController,
                maxLines: null, // Pozwala na wiele linii tekstu
                decoration: const InputDecoration(
                  hintText: 'Dodaj własne notatki (np. rodzaj włóczki, rozmiar szydełka). Zapisują się automatycznie!',
                  border: InputBorder.none,
                  icon: Icon(Icons.edit_note_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

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

  // Metody pomocnicze przeniesione do State
  void _toggleFavourite(PatternModel pattern) {
    final updatedPattern = pattern.copyWith(isFavourite: !pattern.isFavourite);
    ref.read(patternProvider.notifier).updatePattern(updatedPattern);
  }

  void _showEditNameDialog(BuildContext context, PatternModel pattern) {
    final textController = TextEditingController(text: pattern.customName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zmień nazwę wzoru'),
        content: TextField(controller: textController, autofocus: true, decoration: const InputDecoration(hintText: 'Wpisz nową nazwę')),
        actions: [
          TextButton(child: const Text('Anuluj'), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text('Zapisz'),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                final updatedPattern = pattern.copyWith(customName: textController.text.trim());
                ref.read(patternProvider.notifier).updatePattern(updatedPattern);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _deletePattern(BuildContext context, PatternModel pattern) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Potwierdź usunięcie'),
        content: Text('Czy na pewno chcesz usunąć wzór \"${pattern.customName}\"?'),
        actions: [
          TextButton(child: const Text('Anuluj'), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text('Usuń'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              await ref.read(fileServiceProvider).deletePattern(pattern);
            },
          ),
        ],
      ),
    );
  }
}
