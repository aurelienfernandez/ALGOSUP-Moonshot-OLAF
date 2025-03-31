import 'dart:convert';
import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter/material.dart';
import 'package:olaf/cache/shared_preferences%20.dart';
import 'package:olaf/classes.dart';
import 'package:path_provider/path_provider.dart';

/// Loads all user data from AWS into local cache
Future<void> loadAllData() async {
  try {
    // Check if user is connected
    await Amplify.Auth.getCurrentUser();
  } on AuthException {
    return;
  }

  try {
    // Initialize AWS DynamoDB and fetch + cache data
    final dynamoDb = await initializeDynamoDB();
    await awsToCache(dynamoDb);
    await GetCachedData();
    debugPrint("Data loaded successfully");
  } catch (error) {
    debugPrint("Error loading data: $error");
    rethrow;
  }
}

/// Initializes DynamoDB with current user credentials
Future<DynamoDB> initializeDynamoDB() async {
  try {
    final userAttributes = await Amplify.Auth.fetchAuthSession();
    final cognitoSession = userAttributes as CognitoAuthSession;
    final awsCredentials = cognitoSession.credentialsResult;

    return DynamoDB(
      region: 'eu-west-3',
      credentials: AwsClientCredentials(
        accessKey: awsCredentials.value.accessKeyId,
        secretKey: awsCredentials.value.secretAccessKey,
        sessionToken: awsCredentials.value.sessionToken,
      ),
    );
  } catch (e) {
    throw Exception('Failed to initialize DynamoDB: $e');
  }
}

/// Fetches lexica data from DynamoDB, filtering for highest version of each item
Future<Lexica> getLexica(DynamoDB dynamoDb) async {
  List<LexPlant> plants = [];
  List<Disease> diseases = [];
  Map<String, Map<String, AttributeValue>> highestVersionMap = {};

  try {
    final scanResponse = await dynamoDb.scan(tableName: "olaf-lexica");
    
    // Process items and keep only highest version
    if (scanResponse.items != null && scanResponse.items!.isNotEmpty) {
      _processItems(scanResponse, highestVersionMap);
      _buildLexica(highestVersionMap, plants, diseases);
    }
  } catch (e) {
    throw Exception('Error retrieving lexica: $e');
  }
  return Lexica(plants: plants, diseases: diseases);
}

/// Processes items and keeps track of highest version for each item
void _processItems(ScanOutput scanResponse, Map<String, Map<String, AttributeValue>> highestVersionMap) {
  for (final item in scanResponse.items!) {
    String itemName = item['name']!.s!;
    int itemVersion = int.parse(item['version']!.n!);

    if (highestVersionMap.containsKey(itemName)) {
      int existingVersion = int.parse(highestVersionMap[itemName]!['version']!.n!);
      if (itemVersion > existingVersion) {
        highestVersionMap[itemName] = item;
      }
    } else {
      highestVersionMap[itemName] = item;
    }
  }
}

/// Builds plants and diseases lists from filtered items
void _buildLexica(Map<String, Map<String, AttributeValue>> highestVersionMap,
    List<LexPlant> plants, List<Disease> diseases) {
  for (final item in highestVersionMap.values) {
    final details = item['details']?.m;

    if (details != null && details['howTo'] != null) {
      // Process plant item
      plants.add(_buildLexPlant(item, details));
    } else if (details != null && details['prevent'] != null) {
      // Process disease item
      diseases.add(_buildDisease(item, details));
    }
  }
}

/// Builds a LexPlant object from DynamoDB item
LexPlant _buildLexPlant(Map<String, AttributeValue> item, Map<String, AttributeValue> details) {
  List<String> tips = details['tips']!.l!.map((tip) => tip.s!).toList();

  return LexPlant(
    name: item['name']!.s!,
    image: details['image']!.s!,
    howTo: details['howTo']!.s!,
    tips: tips,
    soilHumidityRange: details['soilHumidityRange']!.l!.map((e) => int.parse(e.n!)).toList(),
    airHumidityRange: details['airHumidityRange']!.l!.map((e) => int.parse(e.n!)).toList(),
    temperatureRange: details['temperatureRange']!.l!.map((e) => int.parse(e.n!)).toList(),
  );
}

/// Builds a Disease object from DynamoDB item
Disease _buildDisease(Map<String, AttributeValue> item, Map<String, AttributeValue> details) {
  return Disease(
    name: item['name']!.s!,
    image: details['image']!.s!,
    icon: details['icon']!.s!,
    description: details['description']!.s!,
    prevent: details['prevent']!.s!,
    cure: details['cure']!.s!,
  );
}

/// Downloads user profile picture or returns default if not available
Future<String> getProfilePicture(AuthUser user) async {
  final directory = await getApplicationDocumentsDirectory();
  final filepath = '${directory.path}/${user.userId}.png';
  
  try {
    await Amplify.Storage.downloadFile(
      path: StoragePath.fromString(
          "users/${user.userId}/profile-picture/${user.userId}.png"),
      localFile: AWSFile.fromPath(filepath)
    ).result;

    if (File(filepath).existsSync()) {
      return filepath;
    }
  } catch (e) {
    debugPrint("Failed to download profile picture: $e");
  }
  
  return "assets/images/no-image.png";
}

/// Retrieves current user information
Future<User> getUser() async {
  Map<String, String> attributeMap = {};

  try {
    // Fetch the user's attributes
    final userAttributes = await Amplify.Auth.fetchUserAttributes();
    for (var attribute in userAttributes) {
      attributeMap[attribute.userAttributeKey.key] = attribute.value;
    }

    final user = await Amplify.Auth.getCurrentUser();
    String picture;
    
    if (attributeMap[AuthUserAttributeKey.picture.key] == null) {
      picture = "assets/images/no-image.png";
    } else {
      try {
        picture = await getProfilePicture(user);
      } catch (e) {
        picture = "assets/images/no-image.png";
      }
    }

    return User(
      username: attributeMap[AuthUserAttributeKey.preferredUsername.key]!,
      profilePicture: picture,
      email: attributeMap[AuthUserAttributeKey.email.key]!,
    );
  } catch (e) {
    throw Exception('Failed to fetch user data: $e');
  }
}

/// Retrieves analyzed images from AWS storage
Future<List<analyzedImages>> getImages() async {
  List<analyzedImages> images = [];
  final directory = await getApplicationDocumentsDirectory();
  
  try {
    final user = await Amplify.Auth.getCurrentUser();
    var path = StoragePath.fromString("users/${user.userId}/analyzed/");
    final results = await Amplify.Storage.list(path: path).result;

    for (var item in results.items) {
      final itemPath = StoragePath.fromString(item.path);
      final itemName = item.path.split(RegExp(r'/')).last;
      final localPath = '${directory.path}/$itemName';
      
      // Download file
      await Amplify.Storage.downloadFile(
        path: itemPath,
        localFile: AWSFile.fromPath(localPath)
      ).result;

      // Process file
      final file = File(localPath);
      final fileContent = await file.readAsString();
      final jsonData = jsonDecode(fileContent);
      
      images.add(analyzedImages.fromJson(jsonData, itemName));
      
      // Cleanup
      await file.delete();
    }
  } catch (e) {
    debugPrint("Failed to get images: $e");
  }
  
  return images;
}

/// Get user's saved plants (to be implemented)
List<Plant> getSavedPlants() {
  // TODO: Implement fetching saved plants
  return [];
}

/// Fetches all data from AWS and saves to local cache
Future<void> awsToCache(DynamoDB dynamoDb) async {
  try {
    // Fetch all data concurrently
    final userFuture = getUser();
    final imagesFuture = getImages();
    final lexicaFuture = getLexica(dynamoDb);
    final plants = getSavedPlants();
    
    // Wait for all futures to complete
    final results = await Future.wait([userFuture, lexicaFuture, imagesFuture]);
    
    // Save all data to cache
    await saveData(
      results[0] as User,
      plants,
      results[2] as List<analyzedImages>,
      results[1] as Lexica,
    );
  } catch (e) {
    throw Exception('Failed to fetch and cache data: $e');
  }
}
