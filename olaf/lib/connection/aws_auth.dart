import 'package:flutter_riverpod/flutter_riverpod.dart';

final authAWSRepositoryProvider =
    Provider<AWSAuthRepository>((ref) => AWSAuthRepository());

class testclass {
  Future<void> testfunc() async {
    var test = await AWSAuthRepository().signUp("test1", "test3");
    return test;
  }
}

/// Provides all necessary methods to manage user authentification, account creation/deletion and log out.
class AWSAuthRepository {
  Future<String?> get user async {
    try {
      return null;
    } catch (e) {
      print("not signed in");
      return null;
    }
  }

  /// Creates a new user with the provided [email] and [password]
  Future<void> signUp(String email, String password) async {
    try {} on Exception {
      rethrow;
    }
  }

  /// Confirms the creation of a new user by confirming the [confirmationCode] is the same as the one sent to the user's [email]
  Future<void> confirmSignUp(String email, String confirmationCode) async {
    try {} on Exception {
      rethrow;
    }
  }

  /// Authenticates an existing user with the provided [email] and [password]
  Future<void> signIn(String email, String password) async {
    try {} on Exception {
      rethrow;
    }
  }

  /// Signs out the current user which will make the current [user] empty
  Future<void> logOut() async {
    try {} on Exception {
      rethrow;
    }
  }
}
