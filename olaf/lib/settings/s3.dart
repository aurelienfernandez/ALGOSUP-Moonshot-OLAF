import 'dart:io';
import 'dart:typed_data';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

///This function creates a stream from a given file
///
///[image] is a file containing an image and [name] is a string used to name the image.
Future<Stream<List<int>>> createFileStream(
  File image,
  String name,
) async {
  try {
    // Read the file data as bytes
    Uint8List fileData = await image.readAsBytes();

    // Create a stream from the file data
    Stream<List<int>> fileStream = Stream.fromIterable([fileData]);

    // Define the path for the copied file
    String newPath = '${image.parent.path}/$name';
    File copiedFile = File(newPath);

    // Write the file data to the new file
    await copiedFile.writeAsBytes(fileData);

    // Return a tuple containing the stream and the copied file
    return fileStream;
  } catch (e) {
    throw ('Error creating file stream: $e');
  }
}

///This function creates a copy of a given image to the directory used to contain the profile picture,
///allowing the app to update the new picture as the download needs a reload to be used.
///
///[image] is a file containing an image and [user] is the connected AWS AuthUser.
Future<String> ChangePictureLocal(File image, AuthUser user) async {
  final directory = await getApplicationDocumentsDirectory();
  final newPath = '${directory.path}/${user.userId}.png';

  try {
    final newFile = await image.copy(newPath);

    return newFile.path;
  } catch (e) {
    return "assets/images/no-image.png";
  }
}

///This function changes the picture of the user by uploading it to the olaf-user S3 in the user's dedicated folder.
///
///[image] is a file containing an image.
void changePicture(File image) async {
  try {
    final user = await Amplify.Auth.getCurrentUser();

    Map<String, String> metadata = {
      'name': user.userId,
    };

    final options = StorageUploadFileOptions(
      metadata: metadata,
    );

    final Stream<List<int>> newFile =
        await createFileStream(image, user.userId);

    // Get the size of the file
    final fileSize = await image.length();

    await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromStream(newFile, size: fileSize),
        options: options,
        path: StoragePath.fromString(
          'users/${user.userId}/profile-picture/${user.userId}.png',
        ));
  } catch (e) {
    debugPrint('Upload failed: $e');
  }
}
