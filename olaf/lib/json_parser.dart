import 'dart:convert';

import 'package:flutter/services.dart';

//------------------------- USER PARSER -------------------------
Future<void> loadUser() async {
  final String jsonString = await rootBundle.loadString('assets/user.json');
  var data = jsonDecode(jsonString);

  // Parse user data
  var userJson = data['user'];
  User.initialize(
    username: userJson['name'] ?? '',
    email: userJson['email'] ?? '',
    profilePicture: userJson['profilePicture'] ?? '',
    plants: List<Plant>.from(userJson['plants'].map((x) => Plant.fromJson(x))),
  );
}

//------------------------- PLANT -------------------------
class Plant {
  final String name;
  final String image;
  final String disease;
  final String maturation;
  final String soilHumidity;
  final String airHumidity;
  final String temperature;

  Plant({
    required this.name,
    required this.image,
    required this.disease,
    required this.maturation,
    required this.soilHumidity,
    required this.airHumidity,
    required this.temperature,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      disease: json['disease'] ?? '',
      maturation: json['maturation'] ?? '',
      soilHumidity: json['soilHumidity'] ?? '',
      airHumidity: json['airHumidity'] ?? '',
      temperature: json['temperature'] ?? '',
    );
  }
}

//------------------------- USER -------------------------
class User {
  final String username;
  final String profilePicture;
  final String email;
  final List<Plant> plants;

  // Private constructor
  User._({
    required this.username,
    required this.profilePicture,
    required this.email,
    required this.plants,
  });

  // Static instance field
  static User? _instance;

  // Static method to access the single instance
  static User getInstance() {
    if (_instance == null) {
      throw Exception("User not initialized. Call initialize() first.");
    }
    return _instance!;
  }

  // Static method to initialize the singleton instance
  static void initialize({
    required String username,
    required String profilePicture,
    required String email,
    required List<Plant> plants,
  }) {
    if (_instance != null) {
      throw Exception("User already initialized.");
    }
    _instance = User._(
      username: username,
      email: email,
      profilePicture: profilePicture,
      plants: plants,
    );
  }
}

//------------------------ LEXICA PARSER ------------------------
Future<void> loadLexica() async {
  final String jsonString = await rootBundle.loadString('assets/lexica.json');
  var data = jsonDecode(jsonString);

  // Parse version
  var version = data['version'] ?? '';

  // Parse plant data
  var plantsJson = data['plants'];
  var plants = plantsJson.entries.map((entry) {
    var plantJson = entry.value;
    return LexPlant.fromJson(plantJson, data['diseases']);
  }).toList();

  // Initialize user
  Lexica.initialize(
    version: version,
    plants: plants,
  );
}

//------------------------- PLANT -------------------------
class LexPlant {
  final String name;
  final String image;
  final String howTo;
  final List<String> tips;
  final List<Disease> diseases;

  LexPlant({
    required this.name,
    required this.image,
    required this.howTo,
    required this.tips,
    required this.diseases,
  });

  factory LexPlant.fromJson(
      Map<String, dynamic> json, Map<String, dynamic> allDiseases) {
    var diseasesJson = json['diseases'] as List<dynamic>? ?? [];
    var diseases = diseasesJson
        .map((diseaseJson) {
          var diseaseName = diseaseJson['name'] as String?;
          if (diseaseName != null) {
            var diseaseData = allDiseases[diseaseName];
            if (diseaseData != null) {
              return Disease.fromJson(diseaseData);
            }
          }
          return null;
        })
        .where((disease) => disease != null)
        .toList()
        .cast<Disease>();

    return LexPlant(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      howTo: json['HowTo'] ?? '',
      tips: List<String>.from(json['tips'] ?? []),
      diseases: diseases,
    );
  }
}

//------------------------- DISEASE -------------------------
class Disease {
  final String name;
  final String image;
  final String icon;
  final String description;
  final String prevent;
  final String cure;

  Disease({
    required this.name,
    required this.image,
    required this.icon,
    required this.description,
    required this.prevent,
    required this.cure,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      prevent: json['prevent'] ?? '',
      cure: json['cure'] ?? '',
    );
  }
}

//------------------------ LEXICA ------------------------
class Lexica {
  final String version;
  final List<LexPlant> plants;

  // Private constructor
  Lexica._({
    required this.version,
    required this.plants,
  });

  // Static instance field
  static Lexica? _instance;

  // Static method to access the single instance
  static Lexica getInstance() {
    if (_instance == null) {
      throw Exception("User not initialized. Call initialize() first.");
    }
    return _instance!;
  }

  static void initialize({
    required String version,
    required List<LexPlant> plants,
  }) {
    _instance = Lexica._(
      version: version,
      plants: plants,
    );
  }
}
