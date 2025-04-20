//------------------- FLUTTER IMPORTS -------------------

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/app_localization.dart';
import 'package:olaf/main.dart';
import 'package:olaf/classes.dart';
import 'package:olaf/settings/account_management.dart';
import 'package:olaf/settings/save_settings.dart';

//--------------------- SETTINGS STATE ---------------------
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

//---------------------- SETTINGS TAB ----------------------
class _SettingsState extends ConsumerState<SettingsPage> {
  final Languages = [
    const Locale('en'),
    const Locale('fr'),
    const Locale('de'),
  ];

  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize username controller with current value
    _usernameController.text = cacheData.getInstance().user.username;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: AutoSizeText(
          AppLocalizations.of(context).translate('settings'),
          style: TextStyle(
            color: Colors.black,
            fontSize: mediaQuery.size.width * 0.07,
          ),
          minFontSize: 14,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
              size: mediaQuery.size.width * 0.1,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: mediaQuery.size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //------------- SPACE -------------
              SizedBox(
                height: mediaQuery.size.height * 0.03,
              ),
              //--------- ACCESSIBILITY ---------
              Container(
                width: mediaQuery.size.width * 0.9,
                height: mediaQuery.size.height * 0.05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: theme.colorScheme.secondary,
                ),
                child: Center(
                  child: AutoSizeText(
                    AppLocalizations.of(context).translate('accessibility'),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: mediaQuery.size.width * 0.07,
                    ),
                    textAlign: TextAlign.center,
                    minFontSize: 14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              //------------- SPACE -------------
              SizedBox(
                height: mediaQuery.size.height * 0.03,
              ),
              //--------- LANGUAGE --------
              Container(
                width: mediaQuery.size.width * 0.6,
                height: mediaQuery.size.height * 0.05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: theme.colorScheme.secondary,
                ),
                child: Center(
                  child: AutoSizeText(
                    AppLocalizations.of(context).translate('language'),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: mediaQuery.size.width * 0.05,
                    ),
                    textAlign: TextAlign.center,
                    minFontSize: 12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              //------------- SPACE -------------
              SizedBox(
                height: mediaQuery.size.height * 0.03,
              ),
              //------- LANGUAGE SELECTION ------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //----- ENGLISH -----
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    onTap: () {
                      saveUserSettings('language', 'en');
                      ref.read(localeProvider.notifier).state = Languages[0];
                    },
                    child: Container(
                      width: mediaQuery.size.width * 0.15,
                      height: mediaQuery.size.width * 0.15,
                      decoration: BoxDecoration(
                        color: ref.watch(localeProvider).languageCode == 'en'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/images/en.png",
                          width: mediaQuery.size.width * 0.1,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  //----- FRENCH -----
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    onTap: () {
                      saveUserSettings('language', 'fr');
                      ref.read(localeProvider.notifier).state = Languages[1];
                    },
                    child: Container(
                      width: mediaQuery.size.width * 0.15,
                      height: mediaQuery.size.width * 0.15,
                      decoration: BoxDecoration(
                        color: ref.watch(localeProvider).languageCode == 'fr'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/images/fr.png",
                          width: mediaQuery.size.width * 0.1,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  //----- GERMAN -----
                  InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    onTap: () {
                      saveUserSettings('language', 'de');
                      ref.read(localeProvider.notifier).state = Languages[2];
                    },
                    child: Container(
                      width: mediaQuery.size.width * 0.15,
                      height: mediaQuery.size.width * 0.15,
                      decoration: BoxDecoration(
                        color: ref.watch(localeProvider).languageCode == 'de'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/images/de.png",
                          width: mediaQuery.size.width * 0.1,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //------------- SPACE -------------
              SizedBox(
                height: mediaQuery.size.height * 0.03,
              ),
              //------------ ACCOUNT ------------
              Container(
                width: mediaQuery.size.width * 0.9,
                height: mediaQuery.size.height * 0.05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: theme.colorScheme.secondary,
                ),
                child: Center(
                  child: AutoSizeText(
                    AppLocalizations.of(context)
                        .translate('account_management'),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: mediaQuery.size.width * 0.07,
                    ),
                    textAlign: TextAlign.center,
                    minFontSize: 14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              //------------- SPACE -------------
              SizedBox(
                height: mediaQuery.size.height * 0.03,
              ),
              //------------ USERNAME ------------
              Container(
                width: mediaQuery.size.width * 0.6,
                height: mediaQuery.size.height * 0.05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: theme.colorScheme.secondary,
                ),
                child: Center(
                  child: AutoSizeText(
                    AppLocalizations.of(context).translate('username'),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: mediaQuery.size.width * 0.05,
                    ),
                    textAlign: TextAlign.center,
                    minFontSize: 12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              //------------- SPACE -------------
              SizedBox(
                height: mediaQuery.size.height * 0.03,
              ),
              //--------- USERNAME EDIT ---------
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                // ------- TEXTFIELD -------
                Container(
                  width: mediaQuery.size.width * 0.5,
                  height: mediaQuery.size.height * 0.05,
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: Colors.green.shade300, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                            color: Colors.green.shade300, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Colors.green.shade300, width: 2),
                      ),
                      hintText: cacheData.getInstance().user.username,
                      hintStyle: TextStyle(color: Colors.black),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    ),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: mediaQuery.size.width * 0.05,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                // -------- SPACE ---------
                SizedBox(
                  width: mediaQuery.size.width * 0.02,
                ),
                //-------- CONFIRM --------
                InkWell(
                  onTap: () {
                    // Get and save the new username from controller
                    final newUsername = _usernameController.text.trim();
                    if (newUsername.isNotEmpty) {
                      saveUserSettings('username', newUsername);
                      updateUsername(username: newUsername);
                    }
                  },
                  child: Container(
                    width: mediaQuery.size.width * 0.12,
                    height: mediaQuery.size.height * 0.05,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: theme.colorScheme.primary,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: mediaQuery.size.width * 0.05,
                      ),
                    ),
                  ),
                ),
              ]),
              //------------- SPACE -------------
              SizedBox(
                height: mediaQuery.size.height * 0.03,
              ),
              //---------- DISCONNECT -----------
              InkWell(
                onTap: () {
                  // Store translations ahead of time to prevent localization issues
                  final confirmText = AppLocalizations.of(context).translate('confirm_disconnect');
                  final promptText = AppLocalizations.of(context).translate('disconnect_prompt');
                  final cancelText = AppLocalizations.of(context).translate('cancel');
                  final yesText = AppLocalizations.of(context).translate('yes');
                  
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text(confirmText),
                        content: Text(promptText),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // Close dialog
                            },
                            child: Text(cancelText),
                          ),
                          TextButton(
                            onPressed: () {
                              signOutCurrentUser();
                            },
                            child: Text(
                              yesText,
                              style: TextStyle(
                                color: Colors.red,
                              )
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  width: mediaQuery.size.width * 0.6,
                  height: mediaQuery.size.height * 0.05,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.red,
                  ),
                  child: Center(
                    child: AutoSizeText(
                      AppLocalizations.of(context).translate('sign_out'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: mediaQuery.size.width * 0.05,
                      ),
                      textAlign: TextAlign.center,
                      minFontSize: 12,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              //------------- SPACE -------------
              SizedBox(
                height: mediaQuery.size.height * 0.03,
              ),
              //---------- DELETE ACCOUNT -------
              InkWell(
                onTap: () {
                  // Store translations ahead of time to prevent localization issues
                  final confirmText = AppLocalizations.of(context).translate('confirm');
                  final promptText = AppLocalizations.of(context).translate('delete_account_prompt');
                  final cancelText = AppLocalizations.of(context).translate('cancel');
                  final yesText = AppLocalizations.of(context).translate('yes');
                  
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text(confirmText),
                        content: Text(promptText),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // Close dialog
                            },
                            child: Text(cancelText),
                          ),
                          TextButton(
                            onPressed: () {
                              deleteUser();
                              Navigator.of(dialogContext).pop(); // Close dialog
                            },
                            child: Text(
                              yesText,
                              style: TextStyle(
                                color: Colors.red,
                              )
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  width: mediaQuery.size.width * 0.6,
                  height: mediaQuery.size.height * 0.05,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.red,
                  ),
                  child: Center(
                    child: AutoSizeText(
                      AppLocalizations.of(context).translate('delete_account'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: mediaQuery.size.width * 0.05,
                      ),
                      textAlign: TextAlign.center,
                      minFontSize: 12,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              //------------- SPACE -------------
              SizedBox(
                height: mediaQuery.size.height * 0.03,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
