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
    
    // Log the payload size for debugging
    safePrint("Sending payload of size: ${payload.length}");
    
    InvocationResponse lambdaResponse = await service.invoke(
        functionName:
            "arn:aws:lambda:eu-west-3:905418080111:function:image-analyzer",
        invocationType: InvocationType.requestResponse,
        payload: Uint8List.fromList(payload));
    
    // Debug the raw response
    final responseString = String.fromCharCodes(lambdaResponse.payload as Iterable<int>);
    safePrint("Raw Lambda response: $responseString");
    
    // Parse the response with error handling
    Map<String, dynamic>? responseMap;
    try {
      responseMap = jsonDecode(responseString);
    } catch (e) {
      safePrint("Failed to parse Lambda response: $e");
      throw "Invalid Lambda response format";
    }
    
    // Check for status code
    final statusCode = responseMap?['statusCode'];
    if (statusCode != 200) {
      safePrint("Lambda returned error status: $statusCode");
      throw "Lambda returned error status: $statusCode";
    }
    
    // The body is a JSON string that needs to be parsed
    final bodyString = responseMap?['body'];
    if (bodyString == null) {
      safePrint("Missing body in Lambda response");
      throw "Missing body in Lambda response";
    }
    
    Map<String, dynamic>? bodyMap;
    try {
      bodyMap = jsonDecode(bodyString);
    } catch (e) {
      safePrint("Failed to parse response body: $e");
      throw "Invalid response body format";
    }
    
    final message = bodyMap?['message'];
    if (message == null) {
      safePrint("Missing message in response body");
      throw "Missing message in response body";
    }
    
    safePrint("Extracted message: $message");
    final String lowercasedMessage = message.toLowerCase();
    cacheData.getInstance().updateImageStatus(lowercasedMessage);
    safePrint("Result retrieved successfully");
  } catch (e) {
    safePrint("Lambda invoke error: $e");
    // Update with error status instead of throwing
    cacheData.getInstance().updateImageStatus("error");
    throw ("error: $e");
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
