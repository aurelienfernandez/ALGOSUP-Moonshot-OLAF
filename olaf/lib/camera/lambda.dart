import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:aws_lambda_api/lambda-2015-03-31.dart';
import 'package:olaf/classes.dart';

void invoke(List<int> payload) async {
  try {
    // Invoke lambda and wait for a response
    final userAttributes = await Amplify.Auth.fetchAuthSession();
    final session = userAttributes as CognitoAuthSession;

    AwsClientCredentials cred = AwsClientCredentials(
        accessKey: session.credentialsResult.value.accessKeyId,
        secretKey: session.credentialsResult.value.secretAccessKey,
        sessionToken: session.credentialsResult.value.sessionToken);
    final service = Lambda(region: "eu-west-3", credentials: cred);
    InvocationResponse lambdaResponse = await service.invoke(
        functionName:
            "arn:aws:lambda:eu-west-3:905418080111:function:image-analyzer",
        invocationType: InvocationType.requestResponse,
        payload: Uint8List.fromList(payload));
    final responseString =
        String.fromCharCodes(lambdaResponse.payload as Iterable<int>);
    final responseMap = jsonDecode(responseString);
    final bodyString = responseMap['body'];
    final bodyMap = jsonDecode(bodyString);
    final message = bodyMap['message'];

    final String lowercasedMessage = message.toLowerCase();
    cacheData.getInstance().updateImageStatus(lowercasedMessage);
    safePrint("result retrieved");
  } catch (e) {
    throw ("error: ${e}");
  }
}

void deleteAnalyzedPicture(String name) async {
  final user = await Amplify.Auth.getCurrentUser();
  try {
    await Amplify.Storage.remove(
      path: StoragePath.fromString('users/${user.userId}/analyzed/$name'),
    );
  } on StorageException catch (e) {
    safePrint(e.message);
  }
}
