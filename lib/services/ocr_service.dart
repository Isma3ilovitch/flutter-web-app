import 'dart:html' as html; // For web-specific File object
import 'package:js/js.dart'; // To allow Dart to call JS

// This allows us to call the JavaScript function `runTesseract`
@JS('runTesseract')
external dynamic _runTesseract(html.File file, String lang);

class OCRService {
  static Future<String> extractTextFromHtmlFile(html.File file) async {
    try {
      // Call the JavaScript function and wait for the Promise
      // The `allowInterop` wrapper is needed for the callback
      final result = await _runTesseract(file, 'eng').toDart;
      return result as String;
    } catch (e) {
      print("OCR Error: $e");
      throw Exception('Failed to extract text with Tesseract.js. ${e.toString()}');
    }
  }
}
