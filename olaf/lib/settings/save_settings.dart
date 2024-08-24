import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> _getLocalFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/olafSettings.json');
}

Future<void> saveUserSettings(String key, String value) async {
  try {
    final file = await _getLocalFile();

    // Check if file exists to read existing data
    Map<String, dynamic> existingData = {};
    await settingsExists();
    final contents = await file.readAsString();
    existingData = json.decode(contents);

    // Update with new settings
    existingData[key] = value;

    // Write updated data
    await file.writeAsString(json.encode(existingData));
  } catch (e) {
    throw Exception('Failed to save user settings: $e');
  }
}

Future<String> getLanguage() async {
  try {
    final file = await _getLocalFile();
    settingsExists();
    final contents = await file.readAsString();
    final Map<String, dynamic> data = json.decode(contents);
    return data['language'];
  } catch (e) {
    throw Exception('Failed to load JSON data: $e');
  }
}

Future<void> settingsExists() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/olafSettings.json');

    // Check if the file exists
    if (!await file.exists()) {
      // Create the file with default content
      final defaultContent = json.encode({'language': 'en'});

      await file.writeAsString(defaultContent);
    }
  } catch (e) {
    throw Exception('Failed to check or create file: $e');
  }
}
