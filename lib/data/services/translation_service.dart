import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter/foundation.dart';

class TranslationService {
  final OnDeviceTranslator _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.polish,
  );

  Future<String> translate(String text) async {
    if (text.trim().isEmpty) return '';
    
    try {
      // ML Kit pobierze pakiet językowy przy pierwszym uruchomieniu
      final String translation = await _translator.translateText(text);
      return translation;
    } catch (e) {
      debugPrint('Błąd tłumaczenia: $e');
      return 'Błąd tłumaczenia. Upewnij się, że masz połączenie z internetem przy pierwszym użyciu.';
    }
  }

  void dispose() {
    _translator.close();
  }
}
