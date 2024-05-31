import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/connection/login_page.dart';
import 'package:olaf/home/home_page.dart';
import 'package:olaf/lexica/lexica_loader.dart';
import 'package:olaf/user_loader.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure that Flutter is initialized
  runApp(ProviderScope(child: MyApp()));
}

Future<void> loadAllData() async {
  try {
    await Future.wait([
      login("empty", "empty"),
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
                  primary: Color.fromARGB(255, 60, 90, 45),
                  background: Color.fromARGB(255, 200, 240, 150),
                  secondary: Color.fromARGB(255, 80, 130, 60),
                ),
              ),
              onGenerateRoute: RouteGenerator().generateRoute);
        } else {
          return CircularProgressIndicator(); // Show a loading indicator while user data is being loaded
        }
      },
    );
  }
}

class RouteGenerator {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => loginPage());
      case 'Home':
        return MaterialPageRoute(builder: (_) => HomePage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
