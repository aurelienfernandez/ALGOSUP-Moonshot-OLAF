import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:olaf/classes.dart';

//------------------------- USER PARSER -------------------------
Future<void> login(String email, String password) async {
  final String jsonString = await rootBundle.loadString('assets/user.json');
  var data = jsonDecode(jsonString);

  // Parse user data
  var userJson = data['user'];

  // Create user instance
  User.initialize(
    username: userJson['name'] ?? '',
    email: userJson['email'] ?? '',
    profilePicture: userJson['profilePicture'] ?? '',
    plants: List<Plant>.from(userJson['plants'].map((x) => Plant.fromJson(x))),
  );
}

