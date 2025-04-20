import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

Future<void> signOutCurrentUser() async {
  final result = await Amplify.Auth.signOut();
  if (result is CognitoCompleteSignOut) {
    safePrint('Sign out completed successfully');
  } else if (result is CognitoFailedSignOut) {
    safePrint('Error signing user out: ${result.exception.message}');
  }
}

Future<void> deleteUser() async {
  try {
    final user = await Amplify.Auth.getCurrentUser();

    await Amplify.Storage.remove(
        path: StoragePath.fromString(
      'users/${user.userId}',
    ));
  } catch (e) {
    debugPrint('Deletion of S3 failed: $e');
  }
  try {
    await Amplify.Auth.deleteUser();
    safePrint('Delete user succeeded');
  } on AuthException catch (e) {
    safePrint('Delete user failed with error: $e');
  }
}

Future<void> updateUsername({
  required String username,
}) async {
  try {
    final result = await Amplify.Auth.updateUserAttribute(
      userAttributeKey: AuthUserAttributeKey.preferredUsername,
      value: username,
    );
    _handleUpdateUserAttributeResult(result);
  } on AuthException catch (e) {
    safePrint('Error updating user attribute: ${e.message}');
  }
}

void _handleUpdateUserAttributeResult(
  UpdateUserAttributeResult result,
) {
  switch (result.nextStep.updateAttributeStep) {
    case AuthUpdateAttributeStep.confirmAttributeWithCode:
      final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
      _handleCodeDelivery(codeDeliveryDetails);
      break;
    case AuthUpdateAttributeStep.done:
      safePrint('Successfully updated attribute');
      break;
  }
}

void _handleCodeDelivery(AuthCodeDeliveryDetails codeDeliveryDetails) {
  safePrint(
    'A confirmation code has been sent to ${codeDeliveryDetails.destination}. '
    'Please check your ${codeDeliveryDetails.deliveryMedium.name} for the code.',
  );
}
