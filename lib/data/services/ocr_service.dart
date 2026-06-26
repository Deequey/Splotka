import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<RecognizedText?> recognizeTextDetails(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    try {
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText;
    } catch (e) {
      debugPrint('Błąd OCR: $e');
      return null;
    }
  }

  Future<String> recognizeText(String imagePath) async {
    final result = await recognizeTextDetails(imagePath);
    return result?.text ?? '';
  }

  void dispose() {
    _textRecognizer.close();
  }
}
