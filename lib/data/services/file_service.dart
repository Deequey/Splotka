import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/pattern_model.dart';
import '../../providers/pattern_providers.dart';

final fileServiceProvider = Provider((ref) => FileService(ref));

class FileService {
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  FileService(this._ref);

  Future<bool> pickAndSavePdf() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'PDF Wzory',
      extensions: <String>['pdf'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file == null) {
      return false;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final uniqueId = _uuid.v4();

    // Tworzenie dedykowanych folderów
    final patternsDir = Directory('${appDir.path}/patterns');
    final thumbnailsDir = Directory('${appDir.path}/thumbnails');
    if (!await patternsDir.exists()) await patternsDir.create(recursive: true);
    if (!await thumbnailsDir.exists()) await thumbnailsDir.create(recursive: true);

    final newFilePath = '${patternsDir.path}/$uniqueId.pdf';
    final newThumbnailPath = '${thumbnailsDir.path}/$uniqueId.png';

    try {
      await file.saveTo(newFilePath);

      // --- Generowanie miniaturki ---
      final pdfDoc = await PdfDocument.openFile(newFilePath);
      final page = await pdfDoc.getPage(1);
      final pageImage = await page.render(width: page.width, height: page.height);
      
      if (pageImage != null) {
        await File(newThumbnailPath).writeAsBytes(pageImage.bytes);
      }
      
      await page.close();
      await pdfDoc.close();
      // -----------------------------

    } catch (e) {
      debugPrint('Błąd przetwarzania pliku PDF: $e');
      // W razie błędu usuń niekompletne pliki
      final pdfFile = File(newFilePath);
      if (await pdfFile.exists()) await pdfFile.delete();
      return false;
    }

    final newPattern = PatternModel.createNew(
      id: uniqueId,
      fileName: file.name,
      path: newFilePath,
      thumbnailPath: newThumbnailPath,
    );

    await _ref.read(patternProvider.notifier).addPattern(newPattern);
    
    return true;
  }

  Future<void> deletePattern(PatternModel pattern) async {
    // 1. Usuwanie pliku PDF lokalnie
    try {
      final pdfFile = File(pattern.localFilePath);
      if (await pdfFile.exists()) {
        await pdfFile.delete();
      }
    } catch (e) {
      debugPrint('Błąd usuwania pliku PDF: $e');
    }

    // 3. Usuwanie miniaturki lokalnie
    try {
      final thumbnailFile = File(pattern.thumbnailPath);
      if (await thumbnailFile.exists()) {
        await thumbnailFile.delete();
      }
    } catch (e) {
      debugPrint('Błąd usuwania miniaturki: $e');
    }

    await _ref.read(patternProvider.notifier).removePattern(pattern.id);
  }
}
