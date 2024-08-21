//------------------- CUSTOM IMPORTS --------------------
import 'package:olaf_admin/cache/shared_preferences.dart';
import 'package:olaf_admin/classes.dart';

//------------------- AMPLIFY IMPORTS -------------------
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:olaf_admin/amplifyconfiguration.dart';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

Future<void> configureAmplify() async {
  try {
    await Amplify.addPlugins([AmplifyAuthCognito(), AmplifyStorageS3()]);
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
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
      sessionToken: awsCredentials.value.sessionToken
    ),
  );
  return dynamoDb;
}


Future<Lexica> getLexica(DynamoDB dynamoDb) async {
  List<Plant> plants = [];
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

          plants.add(Plant(
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
    throw('Error while retrieving the lexica: $e');
  }
  return Lexica(plants: plants, diseases: diseases);
}


Future<void> awsToCache(DynamoDB dynamoDb) async {
  Lexica lexica = await getLexica(dynamoDb);
  await saveData(lexica);
}
