//------------------- FLUTTER IMPORTS -------------------
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/app_localization.dart';
import 'package:olaf/main.dart';
import 'package:olaf/classes.dart';

//--------------------- PLANT STATE ---------------------
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

//---------------------- PLANT TAB ----------------------
class _SettingsState extends ConsumerState<SettingsPage> {
  final DropDownFlags = [
    'assets/images/uk.png',
    'assets/images/fr.png',
    'assets/images/de.png',
  ];
  final Languages = [
    const Locale('en'),
    const Locale('fr'),
    const Locale('de'),
  ];
  String currentFlag = "assets/uk.png";
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary, fontSize: 25);
    // Get current language and apply the corresponding flag to currentFlag
    final mediaQuery = MediaQuery.sizeOf(context);
    currentFlag = DropDownFlags[Languages.indexOf(ref.read(localeProvider))];

    return Scaffold(
      //------------- APPBAR -------------
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.secondary,
          centerTitle: true,
          //--------- VERSION ---------
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    AppLocalizations.of(context).translate('version') + ':',
                    style: style,
                    stepGranularity: 0.1,
                    maxFontSize: 10,
                    minFontSize: 1,
                  ),
                  Text(
                    "0.01",
                    style: style.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
          //---------- TITLE ----------
          title: Text(
            AppLocalizations.of(context).translate('settings'),
            style: style,
          ),
          actions: [
            //----------- BACK ----------
            IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: mediaQuery.width * 0.1,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ]),

      //------------ SETTINGS ------------
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.transparent,
                child: SizedBox(
                    width: mediaQuery.width * 0.9,
                    height: mediaQuery.height * 0.55,
                    child: Padding(
                      padding:
                          EdgeInsets.only(bottom: mediaQuery.height * 0.02),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            //---------- SPACE ----------
                            SizedBox(
                              height: mediaQuery.height * 0.02,
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
                                  AppLocalizations.of(context)
                                          .translate('language') +
                                      ':',
                                  style: style.copyWith(fontSize: 20),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: mediaQuery.width * 0.1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    width: mediaQuery.width * 0.2,
                                    height: mediaQuery.width * 0.15,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        padding: EdgeInsets.only(
                                            left: mediaQuery.width * 0.05),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        itemHeight: mediaQuery.height * 0.1,
                                        value: currentFlag,
                                        dropdownColor:
                                            theme.colorScheme.secondary,
                                        iconEnabledColor: Colors.grey.shade200,
                                        items:
                                            DropDownFlags.map((String value) {
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
                                        selectedItemBuilder:
                                            (BuildContext context) {
                                          return DropDownFlags.map(
                                              (String value) {
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
                                          ref
                                                  .read(localeProvider.notifier)
                                                  .state =
                                              Languages[DropDownFlags.indexOf(
                                                  newValue!)];
                                          currentFlag = newValue;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //---------- SPACE ----------
                            SizedBox(
                              height: mediaQuery.height * 0.02,
                            ),
                            //--- ACCOUNT MANAGEMENT ----
                            Text(
                              AppLocalizations.of(context)
                                  .translate('account_management'),
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
                            //----------- EMAIL -----------
                            Text(
                              AppLocalizations.of(context).translate('email') +
                                  ':',
                              style: style.copyWith(
                                  fontSize: mediaQuery.width * 0.05),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "${User.getInstance().email}" + ':',
                                  style: style.copyWith(),
                                  stepGranularity: 0.1,
                                  maxFontSize: 12,
                                  minFontSize: 10,
                                ),
                                SizedBox(
                                  width: mediaQuery.width * 0.02,
                                ),
                                Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: mediaQuery.width * 0.05,
                                )
                              ],
                            ),

                            //---------- SPACE ----------
                            SizedBox(
                              height: mediaQuery.height * 0.02,
                            ),

                            //---------- PASSWORD ---------
                            Text(
                              AppLocalizations.of(context)
                                  .translate('password'),
                              style: style.copyWith(
                                  fontSize: mediaQuery.width * 0.05),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  "${User.getInstance().email.replaceAll(RegExp(r"."), "*")}",
                                  style: style.copyWith(),
                                  stepGranularity: 0.1,
                                  maxFontSize: 12,
                                  minFontSize: 10,
                                ),
                                SizedBox(
                                  width: mediaQuery.width * 0.02,
                                ),
                                Icon(
                                  Icons.remove_red_eye_rounded,
                                  color: Colors.white,
                                  size: mediaQuery.width * 0.05,
                                ),
                                SizedBox(
                                  width: mediaQuery.width * 0.02,
                                ),
                                Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: mediaQuery.width * 0.05,
                                )
                              ],
                            ),

                            //---------- SPACE ----------
                            SizedBox(
                              height: mediaQuery.height * 0.02,
                            ),

                            //---------- GET DATA ---------
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        duration: Duration(seconds: 3),
                                        content: Text(
                                          "All data of your account should be visible in your mail.",
                                          style: TextStyle(
                                              fontSize:
                                                  mediaQuery.width * 0.04),
                                        )));
                              },
                              child: Text(
                                textAlign: TextAlign.center,
                                AppLocalizations.of(context)
                                    .translate('get_data'),
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blue.shade600),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //--------- SIGN OUT --------
                                ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(themeChangerProvider.notifier)
                                        .setTheme(authTheme);
                                    Amplify.Auth.signOut();
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('sign_out'),
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red),
                                  ),
                                ),
                                SizedBox(
                                  width: mediaQuery.width * 0.07,
                                ),
                                //---------- DELETE ---------
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40)),
                                            elevation: 16,
                                            child: SizedBox(
                                                width: mediaQuery.width * 0.8,
                                                height: mediaQuery.height * 0.3,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate('confirm'),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: style.copyWith(
                                                          color: Colors.black),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          mediaQuery.height *
                                                              0.05,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        ElevatedButton(
                                                          style: ButtonStyle(
                                                            minimumSize: MaterialStateProperty
                                                                .all<Size>(Size(
                                                                    mediaQuery
                                                                            .width *
                                                                        0.3,
                                                                    mediaQuery
                                                                            .height *
                                                                        0.075)),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'cancel'),
                                                            style: TextStyle(
                                                                fontSize: mediaQuery
                                                                        .width *
                                                                    0.05,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                            style: ButtonStyle(
                                                                minimumSize: MaterialStateProperty.all<Size>(Size(
                                                                    mediaQuery
                                                                            .width *
                                                                        0.3,
                                                                    mediaQuery
                                                                            .height *
                                                                        0.075)),
                                                                backgroundColor:
                                                                    MaterialStateProperty.all<
                                                                            Color>(
                                                                        Colors
                                                                            .red)),
                                                            onPressed: () {
                                                              ref
                                                                  .read(themeChangerProvider
                                                                      .notifier)
                                                                  .setTheme(
                                                                      authTheme);
                                                              Amplify.Auth
                                                                  .deleteUser();
                                                            },
                                                            child: Text(
                                                              AppLocalizations.of(
                                                                      context)
                                                                  .translate(
                                                                      'yes'),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      mediaQuery
                                                                              .width *
                                                                          0.05,
                                                                  color: Colors
                                                                      .black),
                                                            ))
                                                      ],
                                                    )
                                                  ],
                                                )),
                                          );
                                        });
                                  },
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    AppLocalizations.of(context)
                                        .translate('delete_account'),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
