import 'package:flutter/material.dart';
import 'package:olaf/user_loader.dart';
import 'package:olaf/lexica/lexica_loader.dart';
import 'home/home_page.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure that Flutter is initialized

  runApp(MyApp());
}

Future<void> loadAllData() async {
  try {
    await Future.wait([
      loadUser(),
      loadLexica(),
    ]);
    print("Data loaded successfully");
  } catch (error) {
    throw ("Error: couldn't load data from json files");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadAllData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'OLAF',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color.fromARGB(255, 60, 90, 40),
                primary: Color.fromARGB(255, 40, 90, 45),
                background: Color.fromARGB(255, 197, 255, 175),
                secondary: Color.fromARGB(255, 50, 160, 65),
              ),
            ),
            home: MyHomePage(),
          );
        } else {
          return CircularProgressIndicator(); // Show a loading indicator while user data is being loaded
        }
      },
    );
  }
}
