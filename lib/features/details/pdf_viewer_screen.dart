import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/services/translation_service.dart';
import '../../data/services/ocr_service.dart';

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
  final TranslationService _translationService = TranslationService();
  final OcrService _ocrService = OcrService();
  bool _isTranslating = false;

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

  Future<void> _translateCurrentPage() async {
    setState(() => _isTranslating = true);
    
    try {
      final pattern = ref.read(patternProvider).firstWhere((p) => p.id == widget.patternId);
      final document = await PdfDocument.openFile(pattern.localFilePath);
      
      // Pobieramy aktualną stronę (indeks zaczyna się od 1 w pdfx)
      final int currentPage = _pdfController.page;
      final page = await document.getPage(currentPage);
      
      // Renderujemy stronę do obrazu wysokiej jakości dla lepszego OCR
      final pageImage = await page.render(
        width: page.width * 2, 
        height: page.height * 2,
        format: PdfPageImageFormat.jpg,
        quality: 100,
      );

      if (pageImage == null) throw Exception("Nie udało się wyrenderować strony");

      // Zapisujemy tymczasowo
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_ocr_page.jpg');
      await tempFile.writeAsBytes(pageImage.bytes);

      // Rozpoznajemy tekst (OCR)
      final recognizedText = await _ocrService.recognizeText(tempFile.path);
      
      if (recognizedText.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nie znaleziono tekstu na tej stronie.')),
          );
        }
        return;
      }

      // Tłumaczymy rozpoznany tekst
      final translated = await _translationService.translate(recognizedText);
      
      if (mounted) {
        _showTranslationDialog(recognizedText, translated);
      }

      await page.close();
      await document.close();
      if (await tempFile.exists()) await tempFile.delete();
      
    } catch (e) {
      debugPrint('Błąd OCR/Tłumaczenia: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wystąpił błąd: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  void _showTranslationDialog(String original, String translated) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.translate, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Szybkie tłumaczenie',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('TEKST ORYGINALNY:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(original, style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
            const Text('TŁUMACZENIE (PL):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 8),
            Text(
              translated,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Zamknij'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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

    if (pattern.id.isEmpty) return const Scaffold(body: Center(child: Text('Błąd pliku')));

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(pattern.customName, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.black.withOpacity(0.5),
        foregroundColor: Colors.white,
        actions: [
          if (_isTranslating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.translate),
              tooltip: 'Tłumacz stronę',
              onPressed: _translateCurrentPage,
            ),
        ],
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
