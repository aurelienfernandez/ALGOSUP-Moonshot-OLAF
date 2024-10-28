//------------------- CUSTOM IMPORTS --------------------
import 'package:olaf/app_localization.dart';
import 'package:olaf/home/home_page.dart';
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

class _connectionPage extends ConsumerState<connectionState> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
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
  }
}
