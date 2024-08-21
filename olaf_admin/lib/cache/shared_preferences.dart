import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:olaf_admin/classes.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Function to create the JSON structure
String createJson(Lexica lexica) {
  // Convert everything to JSON
  Map<String, dynamic> data = {
    'lexica': {
      'plants': lexica.plants.map((plant) => plant.toJson()).toList(),
      'diseases': lexica.diseases.map((disease) => disease.toJson()).toList(),
    },
  };

  // Convert the map to a JSON string
  return jsonEncode(data);
}

Future<void> saveData(Lexica lexica) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('Creating JSON...');

    String jsonString;
    try {
      // Updated to pass `user` instead of `username`
      jsonString = createJson(lexica);
    } catch (e) {
      throw ('Error creating JSON: $e');
    }

    try {
      await prefs.setString('olaf', jsonString);
    } catch (e) {
      throw ('Error saving data to SharedPreferences: $e');
    }

    debugPrint('Data saved to SharedPreferences');
  } catch (e) {
    throw ('Error in saveData: $e');
  }
}

Future<void> getCachedData() async {
  try {
    // Retrieve the JSON string from SharedPreferences using the key 'olaf'
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('olaf');

    if (jsonString == null) {
      throw Exception("No data found in cache.");
    }

    // Decode the JSON string into a map
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    // Parse lexica
    Map<String, dynamic> lexicaMap = jsonMap['lexica'] ?? {};

    // Parse plants from lexica
    List<dynamic> plantsJson = lexicaMap['plants'] ?? [];
    List<Plant> plants = plantsJson
        .map((plantJson) => Plant.fromJson(plantJson as Map<String, dynamic>))
        .toList();

    // Parse diseases from lexica
    List<dynamic> diseasesJson = lexicaMap['diseases'] ?? [];
    List<Disease> diseases = diseasesJson
        .map((diseaseJson) =>
            Disease.fromJson(diseaseJson as Map<String, dynamic>))
        .toList();

    // Create Lexica object
    Lexica lexica = Lexica(plants: plants, diseases: diseases);

    // If CacheData is not initialized, initialize it, else update it
    if (CacheData.isInitialized()) {
      CacheData.update(lexica: lexica);
    } else {
      CacheData.initialize(
        lexica: lexica,
      );
    }

    debugPrint("Data successfully retrieved and cached.");
  } catch (e) {
    throw ('Error decoding JSON or initializing cacheData: $e');
  }
}
