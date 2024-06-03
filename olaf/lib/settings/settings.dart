//------------------- FLUTTER IMPORTS -------------------
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/app_localization.dart';
import 'package:olaf/main.dart';

//--------------------- PLANT STATE ---------------------
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

//---------------------- PLANT TAB ----------------------
class _SettingsState extends ConsumerState<SettingsPage> {
  final DropDownFlags = {
    'en': 'assets/uk.png',
    'fr': 'assets/fr.png',
    'de': 'assets/de.png',
  };
  final Languages = [
    const Locale('en'),
    const Locale('fr'),
    const Locale('de'),
  ];
  @override
  Widget build(BuildContext context) {
    final currentFlag = DropDownFlags[ref.watch(localeProvider).languageCode] ??
        DropDownFlags.values.first;
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 25);

    final mediaQuery = MediaQuery.sizeOf(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Colors.transparent,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Padding(
                  padding: EdgeInsets.only(bottom: mediaQuery.height * 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          //---------- TITLE ----------
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: mediaQuery.width * 0.15),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('settings'),
                                style: style,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          //--------- VERSION ---------
                          Padding(
                            padding:
                                EdgeInsets.only(right: mediaQuery.width * 0.02),
                            child: Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)
                                          .translate('version') +
                                      ':',
                                  style: style.copyWith(fontSize: 15),
                                ),
                                Text(
                                  "0.01",
                                  style: style.copyWith(fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      //---------- SPACE ----------
                      SizedBox(
                        height: mediaQuery.height * 0.05,
                      ),

                      //--------- GENERAL ---------
                      Text(
                        AppLocalizations.of(context).translate('general'),
                        style: style,
                      ),

                      //----------- LINE ----------
                      Container(
                        height: MediaQuery.of(context).size.height * 0.02,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white,
                              width: 2, // the line's size
                            ),
                          ),
                        ),
                      ),

                      //---------- SPACE ----------
                      SizedBox(
                        height: mediaQuery.height * 0.02,
                      ),

                      //--------- LANGUAGE --------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('language') +
                                ':',
                            style: style.copyWith(fontSize: 20),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: mediaQuery.width * 0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              width: mediaQuery.width * 0.2,
                              height: mediaQuery.width * 0.15,
                              child: DropdownButton<String>(
                                padding: EdgeInsets.only(
                                    left: mediaQuery.width * 0.05),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                itemHeight: mediaQuery.height * 0.1,
                                value: currentFlag,
                                dropdownColor: theme.colorScheme.secondary,
                                iconEnabledColor: Colors.grey.shade200,
                                items: DropDownFlags.values.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(
                                      child: Image.asset(
                                        value,
                                        width: mediaQuery.width * 0.1,
                                        alignment: Alignment.center,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                selectedItemBuilder: (BuildContext context) {
                                  return DropDownFlags.values
                                      .map((String value) {
                                    return Center(
                                      child: Image.asset(
                                        value,
                                        width: mediaQuery.width * 0.08,
                                        height: mediaQuery.width * 0.08,
                                        alignment: Alignment.center,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  }).toList();
                                },
                                onChanged: (String? newValue) {
                                  final List<String> temp =
                                      DropDownFlags.values.toList();
                                  ref.read(localeProvider.notifier).state =
                                      Languages[temp.indexOf(newValue!)];
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
