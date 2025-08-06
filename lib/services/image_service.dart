import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static Future<String> saveImageLocally(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(imagePath);
    final localPath = path.join(directory.path, fileName);
    
    await File(imagePath).copy(localPath);
    return localPath;
  }
}
