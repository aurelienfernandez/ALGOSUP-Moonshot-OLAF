import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Removes a plant pot by pot_name from the user's plant-pots.json in S3.
Future<bool> removePlantFromS3(String potName) async {
  try {
    final user = await Amplify.Auth.getCurrentUser();
    final directory = await getApplicationDocumentsDirectory();
    final s3Path = "users/${user.userId}/plant-pots.json";
    final localPath = '${directory.path}/plant-pots.json';

    // Download the file
    await Amplify.Storage.downloadFile(
      path: StoragePath.fromString(s3Path),
      localFile: AWSFile.fromPath(localPath),
    ).result;

    final file = File(localPath);
    if (!await file.exists()) return false;

    // Parse JSON
    final jsonData = jsonDecode(await file.readAsString());
    List<dynamic> pots = jsonData['pots'] ?? [];

    // Remove the pot with the given name
    pots.removeWhere((pot) => pot['pot_name'] == potName);

    // Update JSON and write back
    jsonData['pots'] = pots;
    await file.writeAsString(jsonEncode(jsonData));

    // Upload the updated file
    await Amplify.Storage.uploadFile(
      localFile: AWSFile.fromPath(localPath),
      path: StoragePath.fromString(s3Path),
    ).result;

    await file.delete();
    return true;
  } catch (e) {
    // Handle errors as needed
    return false;
  }
}
