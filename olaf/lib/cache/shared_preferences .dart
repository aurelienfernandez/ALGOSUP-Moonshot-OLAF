import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:olaf/classes.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Function to create the JSON structure
String createJson(User user, List<Plant> savedPlants, Lexica lexica) {
  // Convert everything to JSON
  Map<String, dynamic> data = {
    'user': user.toJson(), // Convert user to JSON
    'savedPlants': savedPlants.map((plant) => plant.toJson()).toList(),
    'lexica': {
      'plants': lexica.plants.map((plant) => plant.toJson()).toList(),
      'diseases': lexica.diseases.map((disease) => disease.toJson()).toList(),
    },
  };

  // Convert the map to a JSON string
  return jsonEncode(data);
}

Future<void> saveData(User user, List<Plant> savedPlants, Lexica lexica) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('Creating JSON...');

    String jsonString;
    try {
      // Updated to pass `user` instead of `username`
      jsonString = createJson(user, savedPlants, lexica);
    } catch (e) {
      throw ('Error creating JSON: $e');
    }

    try {
      await prefs.setString('olaf', jsonString);
    } catch (e) {
      print('Error saving data to SharedPreferences: $e');
      rethrow;
    }

    debugPrint('Data saved to SharedPreferences');
  } catch (e) {
    throw ('Error in saveData: $e');
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

    // Extract user data and convert it to a User object
    Map<String, dynamic> userJson = jsonMap['user'] ?? {};
    User user = User.fromJson(userJson);

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
      user: user,
      savedPlants: savedPlants,
      lexica: lexica,
    );

    debugPrint("Data successfully retrieved and cached.");
  } catch (e) {
    throw('Error decoding JSON or initializing cacheData: $e');
  }
}
