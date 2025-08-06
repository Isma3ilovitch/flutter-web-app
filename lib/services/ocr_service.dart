import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  static Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    
    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('Failed to extract text: ${e.toString()}');
    } finally {
      textRecognizer.close();
    }
  }
}
