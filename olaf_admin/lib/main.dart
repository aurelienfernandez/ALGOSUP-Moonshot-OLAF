//------------------- CUSTOM IMPORTS --------------------
import 'package:olaf_admin/amplify.dart';
import 'package:olaf_admin/home.dart';

//------------------- FLUTTER IMPORTS -------------------
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

//------------------- AMPLIFY IMPORTS -------------------
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await configureAmplify();
    runApp(const ProviderScope(child: MyApp()));
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);

    return Authenticator(
      initialStep: AuthenticatorStep.signIn,
      authenticatorBuilder: (BuildContext context, AuthenticatorState state) {
        switch (state.currentStep) {
          case AuthenticatorStep.signIn:
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                height: mediaQuery.height * 0.7,
                width: mediaQuery.width * 0.37,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: -mediaQuery.height * 0.005,
                      child: Column(
                        children: [
                          Text(
                            "Sign in",
                            style: TextStyle(
                              fontSize: mediaQuery.width * 0.012,
                            ),
                          ),
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              color: Colors.purple.shade300,
                            ),
                            width: mediaQuery.width * 0.05,
                          ),
                          Container(
                              height: 1,
                              color: Colors.grey.shade400,
                              width: mediaQuery.width),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: mediaQuery.width * 0.1,
                          vertical: mediaQuery.height * 0.1),
                      child: SignInForm(),
                    )
                  ],
                ),
              ),
            );
          default:
            null;
        }
        return null;
      },
      child: Consumer(
        builder: (context, ref, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: Authenticator.builder(),
            home: const MyHomePage(),
            title: "OLAF administrator",
          );
        },
      ),
    );
  }
}
