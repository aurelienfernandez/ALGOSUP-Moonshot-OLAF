import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:olaf/cache/shared_preferences%20.dart';
import 'package:olaf/classes.dart';

Future<DynamoDB> initializeDynamoDB() async {
  final dynamoDb = DynamoDB(
    region: 'eu-west-3',
    credentials: AwsClientCredentials(
      accessKey: 'HIDDEN', // Not recommended for production
      secretKey:
          'HIDDEN', // Use Cognito to fetch keys dynamically
    ),
  );
  return dynamoDb;
}

Future<List<dynamic>> getLexica(DynamoDB dynamoDb) async {
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
    } else {
      print('No items found.');
    }
  } catch (e) {
    print('Error while retrieving the lexica: $e');
  }
  return [plants, diseases];
}

String getUser() {
  return "admin";
}

List<Plant> getSavedPlants() {
  return [];
}

Future<void> AWStoCache(DynamoDB dynamoDb) async {
  String username = getUser();
  List<Plant> plants = getSavedPlants();
  List<dynamic> lexica = await getLexica(dynamoDb);
  // Ensure to await saveData to complete
  await saveData(username, plants, [lexica[0], lexica[1]]);
}
