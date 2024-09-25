import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  successful,
  wrongPassword,
  emailAlreadyExists,
  invalidEmail,
  weakPassword,
  userNotFound,
  userDisabled,
  tooManyRequests,
  operationNotAllowed,
  networkRequestFailed,
  invalidCredential,
  unknown,
}

class AuthExceptionHandler {
  static AuthStatus handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-email":
        return AuthStatus.invalidEmail;
      case "wrong-password":
        return AuthStatus.wrongPassword;
      case "weak-password":
        return AuthStatus.weakPassword;
      case "email-already-in-use":
        return AuthStatus.emailAlreadyExists;
      case "user-not-found":
        return AuthStatus.userNotFound;
      case "user-disabled":
        return AuthStatus.userDisabled;
      case "too-many-requests":
        return AuthStatus.tooManyRequests;
      case "operation-not-allowed":
        return AuthStatus.operationNotAllowed;
      case "network-request-failed":
        return AuthStatus.networkRequestFailed;
      case "invalid-credential":
        return AuthStatus.invalidCredential;
      default:
        return AuthStatus.unknown;
    }
  }

  static String generateErrorMessage(AuthStatus status) {
    switch (status) {
      case AuthStatus.invalidEmail:
        return "Your email address appears to be malformed.";
      case AuthStatus.weakPassword:
        return "Your password should be at least 6 characters.";
      case AuthStatus.wrongPassword:
        return "Your email or password is wrong.";
      case AuthStatus.emailAlreadyExists:
        return "The email address is already in use by another account.";
      case AuthStatus.userNotFound:
        return "No user found with this email.";
      case AuthStatus.userDisabled:
        return "This user has been disabled.";
      case AuthStatus.tooManyRequests:
        return "Too many requests. Try again later.";
      case AuthStatus.operationNotAllowed:
        return "Operation not allowed. Please contact support.";
      case AuthStatus.networkRequestFailed:
        return "Network error. Please check your connection.";
      case AuthStatus.invalidCredential:
        return "The supplied auth credential is incorrect, malformed, or has expired.";
      default:
        return "An unknown error occurred. Please try again.";
    }
  }
}
