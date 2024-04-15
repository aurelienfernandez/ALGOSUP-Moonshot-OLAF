import 'dart:convert';

import 'package:flutter/services.dart';

//------------------------- PARSER -------------------------
Future<void> loadUser() async {
  final String jsonString = await rootBundle.loadString('assets/data.json');
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
