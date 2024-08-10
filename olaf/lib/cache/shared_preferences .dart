import 'dart:convert';
import 'package:olaf/classes.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Function to create the JSON structure
String createJson(
    String username, List<Plant> savedPlants, List<dynamic> lexica) {
  final Map<String, dynamic> jsonMap = {
    'username': username,
    'savedPlants': savedPlants.map((plant) => plant.toJson()).toList(),
    'lexica': {
      'plants':
          (lexica[0] as List<LexPlant>).map((plant) => plant.toJson()).toList(),
      'diseases': (lexica[1] as List<Disease>)
          .map((disease) => disease.toJson())
          .toList(),
    },
  };

  return jsonEncode(jsonMap);
}

// Function to save data to SharedPreferences
Future<void> saveData(
    String username, List<Plant> savedPlants, List<dynamic> lexica) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    print('Creating JSON...');

    String jsonString;
    try {
      jsonString = createJson(username, savedPlants, lexica);
    } catch (e) {
      print('Error creating JSON: $e');
      rethrow;
    }

    try {
      await prefs.setString('olaf', jsonString);
    } catch (e) {
      print('Error saving data to SharedPreferences: $e');
      rethrow;
    }

    print('Data saved to SharedPreferences');
  } catch (e) {
    print('Error in saveData: $e');
  }
}

Future<void> GetCachedData() async {
  try {
    // Retrieve the JSON string from SharedPreferences using the key 'olaf'
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('olaf');

    if (jsonString == null) {
      throw Exception("No data found in cache.");
    }

    // Decode the JSON string into a map
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    // Extract username
    String username = jsonMap['username'] ?? '';

    // Parse savedPlants
    List<dynamic> savedPlantsJson = jsonMap['savedPlants'] ?? [];
    List<Plant> savedPlants = savedPlantsJson
        .map((plantJson) => Plant.fromJson(plantJson as Map<String, dynamic>))
        .toList();

    // Parse lexica
    Map<String, dynamic> lexicaMap = jsonMap['lexica'] ?? {};

    // Parse plants from lexica
    List<dynamic> lexPlantsJson = lexicaMap['plants'] ?? [];
    List<LexPlant> lexPlants = lexPlantsJson
        .map((lexPlantJson) =>
            LexPlant.fromJson(lexPlantJson as Map<String, dynamic>))
        .toList();

    // Parse diseases from lexica
    List<dynamic> diseasesJson = lexicaMap['diseases'] ?? [];
    List<Disease> diseases = diseasesJson
        .map((diseaseJson) =>
            Disease.fromJson(diseaseJson as Map<String, dynamic>))
        .toList();

    // Create Lexica object
    Lexica lexica = Lexica(plants: lexPlants, diseases: diseases);
    // Initialize cacheData
    cacheData.initialize(
      username: username,
      savedPlants: savedPlants,
      lexica: lexica,
    );

    print("Data successfully retrieved and cached.");
  } catch (e) {
    print('Error decoding JSON or initializing cacheData: $e');
  }
}
