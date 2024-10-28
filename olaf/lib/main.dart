//------------------- CUSTOM IMPORTS --------------------
import 'package:olaf/amplifyconfiguration.dart';
import 'package:olaf/cache/shared_preferences%20.dart';
import 'package:olaf/cache/loader.dart';
import 'package:olaf/home/connection_page.dart';
import 'package:olaf/settings/save_settings.dart';

//------------------- FLUTTER IMPORTS -------------------
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

//------------------- AMPLIFY IMPORTS -------------------
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

//---------------------- PROVIDERS ----------------------
final languageProvider = FutureProvider<String>((ref) async {
  return await getLanguage();
});
final localeProvider = StateProvider<Locale>((ref) {
  final asyncLanguage = ref.watch(languageProvider);

  return asyncLanguage.when(
    data: (language) => Locale(language),
    loading: () => Locale('en'),
    error: (error, stack) => Locale('en'),
  );
});

final themeChangerProvider = ChangeNotifierProvider<ThemeChanger>((ref) {
  return ThemeChanger(authTheme);
});

final CamerasProvider = StateProvider<List<CameraDescription>>(((ref) => []));

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  FlutterNativeSplash.remove();

  try {
    await _configureAmplify();
    final cameras = await availableCameras();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) => runApp(ProviderScope(overrides: [
              CamerasProvider.overrideWith((ref) => cameras),
            ], child: MaterialApp(home: MyApp()))));
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
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

class _MyAppState extends ConsumerState<MyApp> with TickerProviderStateMixin {
  late AnimationController lottieController;
  @override
  void initState() {
    super.initState();

    lottieController = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadAllData(),
      builder: (context, snapshot) {
        var mediaQuery = MediaQuery.sizeOf(context);
        return Lottie.asset(
          controller: lottieController,
          "assets/splash_anim.json",
          fit: BoxFit.cover,
          width: mediaQuery.width / 4,
          onLoaded: (composition) {
            lottieController
              ..duration = composition.duration
              ..forward().whenComplete(() => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => connectionState(),
                    ),
                  ));
          },
        );
      },
    );
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugins([AmplifyAuthCognito(), AmplifyStorageS3()]);
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}
