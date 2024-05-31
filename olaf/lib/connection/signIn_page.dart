import 'package:amazon_cognito_identity_dart_2/cognito.dart';

class SignIn {
  Future CreateNewRecord(
    email,
    password,
    name,
  ) async {
    final userPool = CognitoUserPool(
      "POOLID",
      'xxxxxxxxxxxxxxxxxxxxxxxxxx',
    );
    final userAttributes = [
      AttributeArg(name: 'first_name', value: 'Jimmy'),
      AttributeArg(name: 'last_name', value: 'Wong'),
    ];

    var data;
    try {
      data = await userPool.signUp(
        'email@inspire.my',
        'Password001',
        userAttributes: userAttributes,
      );
    } catch (e) {
      print(e);
    }
  }
}
