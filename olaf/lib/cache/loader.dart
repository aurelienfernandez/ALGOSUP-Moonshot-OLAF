import 'dart:convert';
import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter/material.dart';
import 'package:olaf/cache/shared_preferences%20.dart';
import 'package:olaf/classes.dart';
import 'package:path_provider/path_provider.dart';



Future<void> loadAllData() async {
  // Check if user is connected
  try {
    await Amplify.Auth.getCurrentUser();
  } on AuthException {
    return;
  }
  try {
    // Initialize AWS DynamoDB and login sequentially
    final dynamoDb = await initializeDynamoDB();

    // Fetch data from AWS and save to cache, then retrieve cached data
    await AWStoCache(dynamoDb);

    debugPrint("Data loaded successfully");
  } catch (error) {
    debugPrint("Error: couldn't load data");
    throw (error);
  }

  await GetCachedData();
  return;
}


Future<DynamoDB> initializeDynamoDB() async {
  final userAttributes = await Amplify.Auth.fetchAuthSession();
  final cognitoSession = userAttributes as CognitoAuthSession;

  final awsCredentials = cognitoSession.credentialsResult;

  final dynamoDb = DynamoDB(
    region: 'eu-west-3',
    credentials: AwsClientCredentials(
        accessKey: awsCredentials.value.accessKeyId,
        secretKey: awsCredentials.value.secretAccessKey,
        sessionToken: awsCredentials.value.sessionToken),
  );
  return dynamoDb;
}

Future<Lexica> getLexica(DynamoDB dynamoDb) async {
  List<LexPlant> plants = [];
  List<Disease> diseases = [];

  // Map to keep track of the highest version of each item by name
  Map<String, Map<String, AttributeValue>> highestVersionMap = {};

  try {
    final scanResponse = await dynamoDb.scan(
      tableName: "olaf-lexica",
    );

    // Check if items are returned
    if (scanResponse.items != null && scanResponse.items!.isNotEmpty) {
      for (final item in scanResponse.items!) {
        // Extract item attributes
        String itemName = item['name']!.s!;
        int itemVersion = int.parse(
            item['version']!.n!); // Ensure your table has a version attribute

        // Check if this item name is already in the map
        if (highestVersionMap.containsKey(itemName)) {
          // Get the existing item and its version
          var existingItem = highestVersionMap[itemName]!;
          int existingVersion = int.parse(existingItem['version']!.n!);

          // Compare versions and update if the current item has a higher version
          if (itemVersion > existingVersion) {
            highestVersionMap[itemName] = item;
          }
        } else {
          // Add new item to the map
          highestVersionMap[itemName] = item;
        }
      }

      // Now process the items with the highest versions
      for (final item in highestVersionMap.values) {
        // Access the nested details map (if present)
        final details = item['details']?.m;

        if (details != null && details['howTo'] != null) {
          // Handle LexPlant items
          List<PlantDisease> newDiseases = [];
          List<AttributeValue> diseasesList = details['diseases']!.l!;

          for (int i = 0; i < diseasesList.length; i++) {
            var disease = diseasesList[i].m!;
            String diseaseName = disease['name']!.s!;
            String diseaseImage = disease['image']!.s!;

            newDiseases
                .add(PlantDisease(name: diseaseName, image: diseaseImage));
          }
          List<String> tips = details['tips']!.l!.map((tip) => tip.s!).toList();

          plants.add(LexPlant(
            name: item['name']!.s!,
            image: details['image']!.s!,
            howTo: details['howTo']!.s!,
            tips: tips,
            diseases: newDiseases,
          ));
        } else if (details != null && details['prevent'] != null) {
          // Handle Disease items
          diseases.add(Disease(
            name: item['name']!.s!,
            image: details['image']!.s!,
            icon: details['icon']!.s!,
            description: details['description']!.s!,
            prevent: details['prevent']!.s!,
            cure: details['cure']!.s!,
          ));
        }
      }
    }
  } catch (e) {
    throw ('Error while retrieving the lexica: $e');
  }
  return Lexica(plants: plants, diseases: diseases);
}

Future<String> GetProfilePicture(AuthUser user) async {
  final directory = await getApplicationDocumentsDirectory();
  final filepath = '${directory.path}/${user.userId}.png';
  final downloadResult = await Amplify.Storage.downloadFile(
          path: StoragePath.fromString(
              "users/${user.userId}/profile-picture/${user.userId}.png"),
          localFile: AWSFile.fromPath(filepath))
      .result;

  if (downloadResult != null && File(filepath).existsSync()) {
    return "${directory.path}/${user.userId}.png";
  } else {
    return "assets/images/no-image.png";
  }
}

Future<User> getUser() async {
  Map<String, String> attributeMap = {};

  try {
    // Fetch the user's attributes
    List<AuthUserAttribute> userAttributes =
        await Amplify.Auth.fetchUserAttributes();

    // Create a map of attributes
    for (var attribute in userAttributes) {
      attributeMap[attribute.userAttributeKey.key] = attribute.value;
    }
  } catch (e) {
    throw ('Failed to fetch user attributes: $e');
  }
  final user = await Amplify.Auth.getCurrentUser();
  late dynamic picture;
  if (attributeMap[AuthUserAttributeKey.picture.key] == null) {
    picture = "assets/images/no-image.png";
  } else {
    try {
      picture = await GetProfilePicture(user);
    } catch (e) {
      picture = "assets/images/no-image.png";
    }
  }

  return User(
      username: attributeMap[AuthUserAttributeKey.preferredUsername.key]!,
      profilePicture: picture,
      email: attributeMap[AuthUserAttributeKey.email.key]!);
}

Future<List<analyzedImages>> getImages() async {
  final user = await Amplify.Auth.getCurrentUser();

  try {
    var path = StoragePath.fromString("users/${user.userId}/analyzed/");
    final results = await Amplify.Storage.list(path: path).result;

    List<analyzedImages> images = [];
    final directory = await getApplicationDocumentsDirectory();
    for (var item in results.items) {
      path = StoragePath.fromString(item.path);
      final itemName = "${item.path.split(RegExp(r'/')).last}";
      // Step 2: Retrieve the object and its metadata
      await Amplify.Storage.downloadFile(
              path: path,
              localFile: AWSFile.fromPath('${directory.path}/$itemName'))
          .result;

      final newfile = File('${directory.path}/$itemName');

      final fileString = await newfile.readAsString();

      final Map<String, dynamic> jsonData = jsonDecode(fileString);
      images.add(analyzedImages.fromJson(jsonData, itemName));

      // Step 5: Delete the file from local storage
      await File(newfile.path.toString()).delete();
    }
    return images;
  } on StorageException catch (e) {
    debugPrint("$e");
  }
  return [];
}

List<Plant> getSavedPlants() {
  return [];
}

Future<void> AWStoCache(DynamoDB dynamoDb) async {
  Future<User> user = getUser();
  Future<List<analyzedImages>> images = getImages();
  List<Plant> plants = getSavedPlants();
  Future<Lexica> lexica = getLexica(dynamoDb);
  // Ensure to await saveData to complete
  await saveData(await user, plants, await images, await lexica);
}
