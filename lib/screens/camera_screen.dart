import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:universal_html/html.dart' as html; // For FileReader
import '../services/ocr_service.dart';
import '../services/data_parser.dart';
import '../models/invoice_model.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    setState(() => _isProcessing = true);
    
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Convert XFile to a web File object
      final html.File file = html.File([await image.readAsBytes()], image.name);
      
      // Extract text from image using Tesseract.js
      final extractedText = await OCRService.extractTextFromHtmlFile(file);
      
      // Parse invoice data
      final parsedData = DataParser.parseInvoiceData(extractedText);

      // Convert image to Base64 for storage
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      await reader.onLoad.first;
      final base64String = reader.result as String;

      // Navigate to preview screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewScreen(
              imagePath: base64String, // Pass Base64 string
              extractedData: parsedData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Invoice'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Add a new invoice',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Choose an image from your device'),
            const SizedBox(height: 32),
            _isProcessing
                ? const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Processing image, this may take a moment..."),
                    ],
                  )
                : ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose Image'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
