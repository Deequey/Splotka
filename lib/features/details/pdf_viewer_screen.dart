import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

import '../../core/models/pattern_model.dart';
import '../../providers/pattern_providers.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final String patternId;

  const PdfViewerScreen({super.key, required this.patternId});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  late PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    final pattern = ref.read(patternProvider).firstWhere((p) => p.id == widget.patternId);
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openFile(pattern.localFilePath),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  void _updateRow(PatternModel pattern, int newVal) {
    HapticFeedback.lightImpact();
    final updatedPattern = pattern.copyWith(currentRow: newVal);
    ref.read(patternProvider.notifier).updatePattern(updatedPattern);
  }

  @override
  Widget build(BuildContext context) {
    final patterns = ref.watch(patternProvider);
    final pattern = patterns.firstWhere((p) => p.id == widget.patternId, orElse: () => PatternModel.empty());

    if (pattern.id.isEmpty) return const Scaffold(body: Center(child: Text('Błąd pliku')));

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(pattern.customName, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.black.withOpacity(0.5),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          PdfViewPinch(
            controller: _pdfController,
          ),
          // --- PŁYWAJĄCY PANEL KONTROLNY ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: pattern.currentRow > 0 ? () => _updateRow(pattern, pattern.currentRow - 1) : null,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'RZĄD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        '${pattern.currentRow}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    iconSize: 36,
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => _updateRow(pattern, pattern.currentRow + 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
