//---------------------- PLANT DISEASE ---------------------
class PlantDisease {
  String name;
  String image;

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
class Plant {
  String name;
  String image;
  String howTo;
  List<String> tips;
  List<PlantDisease> diseases;

  Plant({
    required this.name,
    required this.image,
    required this.howTo,
    required this.tips,
    required this.diseases,
  });

  // Convert a Plant object into a map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'howTo': howTo,
      'tips': tips,
      'diseases': diseases.map((disease) => disease.toJson()).toList(),
    };
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    List<String> tips = (json['tips'] as List<dynamic>).cast<String>().toList();

    List<PlantDisease> diseases = [];
    List<dynamic> diseasesJson = json['diseases'];
    for (var diseaseData in diseasesJson) {
      diseases.add(PlantDisease.fromJson(diseaseData as Map<String, dynamic>));
    }

    return Plant(
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
  String name;
  String image;
  String icon;
  String description;
  String prevent;
  String cure;

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
  final List<Plant> plants;
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

class CacheData {
  final Lexica lexica;

  CacheData._({required this.lexica});
  static CacheData? _instance;

  static CacheData getInstance() {
    if (_instance == null) {
      throw Exception("CacheData not initialized. Call initialize() first.");
    }
    return _instance!;
  }

  static void initialize({required Lexica lexica}) {
    if (_instance != null) {
      throw Exception("CacheData already initialized.");
    }
    _instance = CacheData._(
      lexica: lexica,
    );
  }

  static void update({required Lexica lexica}) {
    _instance = CacheData._(
      lexica: lexica,
    );
  }

  static bool isInitialized() {
    return _instance != null;
  }
}
