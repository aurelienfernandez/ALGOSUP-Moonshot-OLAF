//---------------------- PLANT DISEASE ---------------------
import 'package:flutter/material.dart';

class PlantDisease {
  final String name;
  final String image;

  PlantDisease({
    required this.name,
    required this.image,
  });

  // Convert a PlantDisease object into a map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
    };
  }

  // Convert a json map into a PlantDisease object
  factory PlantDisease.fromJson(Map<String, dynamic> json) {
    return PlantDisease(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

//---------------------- LEXICA PLANT ----------------------
class LexPlant {
  final String name;
  final String image;
  final String howTo;
  final List<String> tips;
  final List<int> temperatureRange;
  final List<int> soilHumidityRange;
  final List<int> airHumidityRange;
  final String? season;

  LexPlant({
    required this.name,
    required this.image,
    required this.howTo,
    required this.tips,
    required this.temperatureRange,
    required this.soilHumidityRange,
    required this.airHumidityRange,
    this.season,
  });

  // Convert a lexPlant object into a map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'howTo': howTo,
      'tips': tips,
      'temperatureRange': temperatureRange,
      'soilHumidityRange': soilHumidityRange,
      'airHumidityRange': airHumidityRange,
      'season': season,
    };
  }

  factory LexPlant.fromJson(Map<String, dynamic> json) {
    List<String> tips = (json['tips'] as List<dynamic>).cast<String>().toList();

    return LexPlant(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      howTo: json['howTo'] ?? '',
      tips: tips,
      soilHumidityRange:
          (json['soilHumidityRange'] as List<dynamic>).cast<int>(),
      airHumidityRange: (json['airHumidityRange'] as List<dynamic>).cast<int>(),
      temperatureRange: (json['temperatureRange'] as List<dynamic>).cast<int>(),
      season: json['season'],
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

  // Convert a disease object into a map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'icon': icon,
      'description': description,
      'prevent': prevent,
      'cure': cure,
    };
  }

  // Convert a json map into a disease
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
  final List<LexPlant> plants;
  final List<Disease> diseases;

  // Private constructor
  Lexica({
    required this.plants,
    required this.diseases,
  });

  Disease findDiseaseByName(String diseaseName) {
    return diseases.firstWhere(
      (disease) => disease.name.toLowerCase() == diseaseName.toLowerCase(),
      orElse: () => throw ("Error: Disease:\"$diseaseName\"not found"),
    );
  }
}

//------------------------- PLANT -------------------------
class Plant {
  final String name;
  final String type;
  final String image;
  final String disease;
  final List<int> soilHumidity;
  final List<int> airHumidity;
  final List<double> temperature;

  Plant({
    required this.name,
    required this.type,
    required this.image,
    required this.disease,
    required this.soilHumidity,
    required this.airHumidity,
    required this.temperature,
  });

  // Convert a plant object into a map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'image': image,
      'disease': disease,
      'soilHumidity': soilHumidity,
      'airHumidity': airHumidity,
      'temperature': temperature,
    };
  }

  // Convert a json map into a plant
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      image: json['image'] ?? '',
      disease: json['disease'] ?? '',
      soilHumidity: json['soilHumidity'] ?? '',
      airHumidity: json['airHumidity'] ?? '',
      temperature: json['temperature'] ?? '',
    );
  }
}

//------------------------- USER -------------------------
class User {
  String username;
  String profilePicture;
  String email;

  User({
    required this.username,
    required this.profilePicture,
    required this.email,
  });

  // Convert a User object into a map
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'profilePicture': profilePicture,
      'email': email,
    };
  }

  // Convert a json map into a User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class cacheData with ChangeNotifier {
  final User user;
  final List<Plant> savedPlants;
  final Lexica lexica;
  final List<analyzedImages> images;
  cacheData._(
      {required this.user,
      required this.savedPlants,
      required this.lexica,
      required this.images});
  static cacheData? _instance;

  static cacheData getInstance() {
    if (_instance == null) {
      throw Exception("cacheData not initialized. Call initialize() first.");
    }
    return _instance!;
  }

  static void initialize(
      {required User user,
      required List<Plant> savedPlants,
      required Lexica lexica,
      required List<analyzedImages> images}) {
    _instance = cacheData._(
        user: user, savedPlants: savedPlants, lexica: lexica, images: images);
  }

  static bool isInitialized() {
    return _instance != null;
  }

  void addImages(analyzedImages newImage) {
    images.add(newImage);
    notifyListeners();
  }

  void removeImage(int imageIndex) {
    images.removeAt(imageIndex);
    notifyListeners();
  }

  void updateImageStatus(String status) {
    images.last.result = status;
    notifyListeners();
  }
}

//-------------------- ANALYZED IMAGES --------------------
class analyzedImages {
  final String name;
  final String image;
  String result;
  analyzedImages(
      {required this.name, required this.image, required this.result});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'result': result,
    };
  }

  factory analyzedImages.fromJson(Map<String, dynamic> json, name) {
    return analyzedImages(
      name: name,
      image: json['image'] ?? '',
      result: json['result'] ?? '',
    );
  }
}
