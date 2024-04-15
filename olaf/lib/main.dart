import 'package:flutter/material.dart';
import 'package:olaf/json_parser.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter is initialized
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'OLAF',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color.fromARGB(255, 57, 91, 41),
                primary: Color.fromARGB(255, 57, 91, 41),
                background: Color.fromARGB(255, 206, 255, 183),
                secondary: Color.fromARGB(255, 99, 157, 72),
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
