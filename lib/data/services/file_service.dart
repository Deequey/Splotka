import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/pattern_model.dart';
import '../../providers/pattern_providers.dart';

final fileServiceProvider = Provider((ref) => FileService(ref));

class FileService {
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  FileService(this._ref);

  Future<void> pickAndSavePdf() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'PDF Wzory',
      extensions: <String>['pdf'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file == null) {
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final uniqueId = _uuid.v4();

    final patternsDir = Directory('${appDir.path}/patterns');
    if (!await patternsDir.exists()) {
      await patternsDir.create(recursive: true);
    }

    final newFilePath = '${patternsDir.path}/$uniqueId.pdf';

    try {
      await file.saveTo(newFilePath);
    } catch (e) {
      debugPrint('Błąd kopiowania pliku: $e');
      return;
    }

    final newPattern = PatternModel.createNew(
      id: uniqueId,
      fileName: file.name,
      path: newFilePath,
    );

    await _ref.read(patternProvider.notifier).addPattern(newPattern);
  }

  Future<void> deletePattern(String patternId, String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Błąd usuwania pliku: $e');
      // Nawet jeśli plik się nie usunie, kontynuujemy usuwanie z bazy
    }
    
    await _ref.read(patternProvider.notifier).removePattern(patternId);
  }
}
