//------------------- CUSTOM IMPORTS --------------------
import 'package:olaf/app_localization.dart';
import 'package:olaf/LayoutManager.dart';
import 'package:olaf/main.dart';

//------------------- FLUTTER IMPORTS -------------------
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//------------------- AMPLIFY IMPORTS -------------------
import 'package:amplify_authenticator/amplify_authenticator.dart';

class connectionState extends ConsumerStatefulWidget {
  @override
  _connectionPage createState() => _connectionPage();
}
final ThemeData theme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Color.fromRGBO(116,193,79,1.0),
    background: Color.fromRGBO(247, 247, 247, 1.0),
    secondary: Color.fromRGBO(83, 205, 66, 0.25),
  ),
);

class _connectionPage extends ConsumerState<connectionState> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return Authenticator(
      child: Consumer(
        builder: (context, ref, child) {
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
            home: LayoutManager(),
          );
        },
      ),
    );
  }
}
