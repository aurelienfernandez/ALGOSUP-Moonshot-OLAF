import 'dart:convert';

import 'package:flutter/services.dart';

//------------------------ LEXICA PARSER ------------------------
Future<void> loadLexica() async {
  final String jsonString = await rootBundle.loadString('assets/lexica.json');
  var data = jsonDecode(jsonString);

  // Get version
  var version = data['version'] ?? '';
  // Get all plants
  var plantsJson = (data['plants'] as Map<String, dynamic>)
      .values
      .map((x) => LexPlant.fromJson(x))
      .toList();
  // Get all diseases
  var diseaseJson =
      (data['diseases'] as List).map((json) => Disease.fromJson(json)).toList();

  // Initialize lexica
  Lexica.initialize(
    version: version,
    plants: plantsJson,
    diseases: diseaseJson,
  );
}

//---------------------- PLANT DISEASE ---------------------
class PlantDisease {
  final String name;
  final String image;

  PlantDisease({required this.name, required this.image});
  factory PlantDisease.fromJson(Map<String, dynamic> json) {
    return PlantDisease(name: json['name'], image: json['image']);
  }
}

//---------------------- LEXICA PLANT ----------------------
class LexPlant {
  final String name;
  final String image;
  final String howTo;
  final List<String> tips;
  final List<PlantDisease> diseases;

  LexPlant({
    required this.name,
    required this.image,
    required this.howTo,
    required this.tips,
    required this.diseases,
  });

  factory LexPlant.fromJson(Map<String, dynamic> json) {
    List<String> tips = (json['tips'] as List<dynamic>).cast<String>().toList();

    List<PlantDisease> diseases = [];
    List<dynamic> diseasesJson = json['diseases'];
    for (var diseaseData in diseasesJson) {
      diseases.add(PlantDisease(
        name: diseaseData['name'],
        image: diseaseData['image'],
      ));
    }

    return LexPlant(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      howTo: json['howTo'] ?? '',
      tips: tips,
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
  final List<Disease> diseases;

  // Private constructor
  Lexica._({
    required this.version,
    required this.plants,
    required this.diseases,
  });

  // Static instance field
  static Lexica? _instance;

  // Static method to access the single instance
  static Lexica getInstance() {
    if (_instance == null) {
      throw Exception("Lexica not initialized. Call initialize() first.");
    }
    return _instance!;
  }

  static void initialize({
    required String version,
    required List<LexPlant> plants,
    required List<Disease> diseases,
  }) {
    if (_instance != null) {
      throw Exception("Lexica already initialized.");
    }
    {
      _instance = Lexica._(
        version: version,
        plants: plants,
        diseases: diseases,
      );
    }
  }

  Disease findDiseaseByName(String diseaseName) {
    return diseases.firstWhere(
      (disease) => disease.name.toLowerCase() == diseaseName.toLowerCase(),
      orElse: () => throw ("Error: Disease:\"$diseaseName\"not found"),
    );
  }

  static void reset() {
    _instance = null;
  }
}
