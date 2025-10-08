import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/pattern_model.dart';
import '../../providers/pattern_providers.dart';

// Riverpod: Provider do wstrzykiwania serwisu.
final fileServiceProvider = Provider((ref) => FileService(ref));

class FileService {
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  FileService(this._ref);

  /// Otwiera dialog wyboru pliku PDF, kopiuje plik do pamięci aplikacji
  /// i dodaje nowy PatternModel do bazy Hive.
  Future<void> pickAndSavePdf() async {
    // 1. Definicja akceptowanych typów (tylko PDF)
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'PDF Wzory',
      extensions: <String>['pdf'],
    );

    // 2. Otwarcie dialogu wyboru pliku (file_selector)
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file == null) {
      // Anulowano przez użytkownika
      return;
    }

    // 3. Określenie ścieżki docelowej w pamięci aplikacji
    final appDir = await getApplicationDocumentsDirectory();
    final uniqueId = _uuid.v4();

    // Tworzenie folderu "patterns"
    final patternsDir = Directory('${appDir.path}/patterns');
    if (!await patternsDir.exists()) {
      await patternsDir.create(recursive: true);
    }

    final newFilePath = '${appDir.path}/patterns/$uniqueId.pdf';


    // 4. Kopiowanie pliku (kluczowy krok, aby plik był bezpiecznie przechowywany)
    try {
      await file.saveTo(newFilePath);
    } catch (e) {
      debugPrint('Błąd kopiowania pliku do pamięci aplikacji: $e');
      // Możesz dodać tu logikę wyświetlenia SnackBar
      return;
    }

    // 5. Utworzenie PatternModel i zapis do Hive
    final newPattern = PatternModel.createNew(
      id: uniqueId,
      fileName: file.name,
      path: newFilePath,
    );

    // Dodanie do bazy danych za pomocą PatternProvider
    _ref.read(patternProvider.notifier).addPattern(newPattern);
  }
}