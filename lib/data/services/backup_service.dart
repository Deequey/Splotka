import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/models/pattern_model.dart';

class BackupService {
  /// Generuje plik kopii zapasowej w katalogu tymczasowym i zwraca ścieżkę do niego.
  Future<File?> generateBackupFile() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();
      final patternsDir = Directory('${appDir.path}/patterns');
      final thumbnailsDir = Directory('${appDir.path}/thumbnails');

      final archive = Archive();

      // 1. Pakujemy plik bazy Hive bezpośrednio
      final hiveFile = File('${appDir.path}/patterns.hive');
      if (await hiveFile.exists()) {
        final bytes = await hiveFile.readAsBytes();
        archive.addFile(ArchiveFile('patterns.hive', bytes.length, bytes));
      }

      // 2. Pakujemy PDFy
      if (await patternsDir.exists()) {
        for (var entity in patternsDir.listSync()) {
          if (entity is File) {
            final bytes = await entity.readAsBytes();
            archive.addFile(ArchiveFile('patterns/${entity.uri.pathSegments.last}', bytes.length, bytes));
          }
        }
      }

      // 3. Pakujemy miniaturki
      if (await thumbnailsDir.exists()) {
        for (var entity in thumbnailsDir.listSync()) {
          if (entity is File) {
            final bytes = await entity.readAsBytes();
            archive.addFile(ArchiveFile('thumbnails/${entity.uri.pathSegments.last}', bytes.length, bytes));
          }
        }
      }

      // 4. Kodujemy do ZIP
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);
      
      if (zipData == null) return null;

      final String fileName = 'splotka_backup_${DateTime.now().millisecondsSinceEpoch}.splotka';
      final File tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(zipData);

      return tempFile;
    } catch (e) {
      debugPrint('Błąd generowania pliku kopii: $e');
      return null;
    }
  }

  Future<bool> restoreBackup() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'Splotka Backup',
        extensions: <String>['splotka'],
      );
      final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
      
      if (file == null) return false;

      // Zamykamy bazę przed nadpisaniem plików
      await Hive.close();

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final appDir = await getApplicationDocumentsDirectory();

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final localFile = File('${appDir.path}/$filename');
          await localFile.create(recursive: true);
          await localFile.writeAsBytes(data);
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Błąd przywracania kopii: $e');
      return false;
    }
  }
}
