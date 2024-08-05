//------------------- CUSTOM IMPORTS --------------------
import 'package:olaf/amplifyconfiguration.dart';
import 'package:olaf/app_localization.dart';
import 'package:olaf/home/home_page.dart';
import 'package:olaf/lexica/lexica_loader.dart';
import 'package:olaf/user_loader.dart';

//------------------- FLUTTER IMPORTS -------------------
import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

//---------------------- PROVIDERS ----------------------
final localeProvider = StateProvider<Locale>((ref) => Locale('en'));

final themeChangerProvider = ChangeNotifierProvider<ThemeChanger>((ref) {
  return ThemeChanger(authTheme);
});

final CamerasProvider = StateProvider<List<CameraDescription>>(((ref) => []));

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();
    final cameras = await availableCameras();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) => runApp(ProviderScope(overrides: [
              CamerasProvider.overrideWith((ref) => cameras),
            ], child: MyApp())));
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
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

final ThemeData authTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color.fromARGB(255, 60, 90, 40),
    primary: Color.fromARGB(255, 0, 0, 0),
    background: Color.fromARGB(255, 255, 255, 255),
    secondary: Color.fromARGB(255, 80, 130, 60),
  ),
);

final ThemeData stdTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color.fromARGB(255, 60, 90, 40),
    primary: Color.fromARGB(255, 60, 90, 45),
    background: Color.fromARGB(255, 200, 240, 150),
    secondary: Color.fromARGB(255, 80, 130, 60),
  ),
);

class ThemeChanger extends ChangeNotifier {
  ThemeData _themeData;
  ThemeChanger(this._themeData);

  ThemeData get getTheme => _themeData;
  void setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }
}

class MyApp extends ConsumerStatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return FutureBuilder<void>(
      future: loadAllData(),
      builder: (context, snapshot) {
        return Authenticator(
          child: Consumer(
            builder: (context, ref, child) {
              final theme = ref.watch(themeChangerProvider).getTheme;

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                builder: Authenticator.builder(),
                locale: locale,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: [
                  Locale('en', ''), // English
                  Locale('fr', ''), // French
                  Locale('de', ''), // German
                ],
                title: 'OLAF',
                theme: theme,
                home: HomePage(),
              );
            },
          ),
        );
      },
    );
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyConfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}
