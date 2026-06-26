import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../data/services/translation_service.dart';
import '../../data/services/ocr_service.dart';
import '../../core/theme.dart';
import '../../core/models/pattern_model.dart';
import '../../providers/pattern_providers.dart';

class TranslatedBlock {
  final Rect rect;
  final String text;
  TranslatedBlock({required this.rect, required this.text});
}

class PdfViewerScreen extends ConsumerStatefulWidget {
  final String patternId;

  const PdfViewerScreen({super.key, required this.patternId});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  late PdfControllerPinch _pdfController;
  final TranslationService _translationService = TranslationService();
  final OcrService _ocrService = OcrService();
  
  bool _isTranslating = false;
  // Mapa przechowująca tłumaczenia dla poszczególnych stron (klucz to numer strony)
  final Map<int, List<TranslatedBlock>> _cachedTranslations = {};

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
    _translationService.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  void _showWipDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.construction, color: Colors.orange),
            SizedBox(width: 10),
            Text('Funkcja w budowie'),
          ],
        ),
        content: const Text(
          'Obecnie pracujemy nad ulepszeniem modułu tłumaczeń, aby zapewnić najwyższą jakość przekładu instrukcji szydełkowych. \n\nTa funkcja zostanie udostępniona wkrótce w pełnej wersji!',
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Rozumiem', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _translateCurrentPage() async {
    _showWipDialog();
    return;
    /*
    final int currentPage = _pdfController.page;
    ...
    */
  }

  void _updateRow(PatternModel pattern, int newVal) {
    if (ref.read(hapticNotifierProvider)) {
      HapticFeedback.lightImpact();
    }
    final updatedPattern = pattern.copyWith(currentRow: newVal);
    ref.read(patternProvider.notifier).updatePattern(updatedPattern);
  }

  @override
  Widget build(BuildContext context) {
    final patterns = ref.watch(patternProvider);
    final pattern = patterns.firstWhere((p) => p.id == widget.patternId, orElse: () => PatternModel.empty());
    
    // Bezpieczne pobieranie strony - zapobiega crashom przed załadowaniem
    int currentPage = 1;
    try {
      currentPage = _pdfController.page;
    } catch (_) {}

    final hasTranslation = _cachedTranslations.containsKey(currentPage);

    if (pattern.id.isEmpty) return const Scaffold(body: Center(child: Text('Błąd pliku')));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          pattern.customName, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)
        ),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
        elevation: 8,
        actions: [
          if (_isTranslating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.blueAccent)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.translate, 
                  color: Colors.redAccent,
                  size: 28,
                ),
                onPressed: _translateCurrentPage,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PdfViewPinch(
            controller: _pdfController,
            onPageChanged: (_) => setState(() {}), // Odśwież stan ikony przy zmianie strony
          ),
          
          // PŁYWAJĄCY PANEL KONTROLNY
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: pattern.currentRow > 0 ? () => _updateRow(pattern, pattern.currentRow - 1) : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('RZĄD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary.withOpacity(0.7))),
                      Text('${pattern.currentRow}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    iconSize: 40,
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

  void _showTranslationList(int pageIndex) {
    final blocks = _cachedTranslations[pageIndex] ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.description_outlined, color: Colors.blueAccent),
                  SizedBox(width: 12),
                  Text('Instrukcja po polsku (strona)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: blocks.length,
                itemBuilder: (context, index) {
                  final block = blocks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
                    ),
                    child: Text(
                      block.text, 
                      style: const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w500)
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
