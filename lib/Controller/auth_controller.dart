import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tictactoe_gameapp/Models/firebase_exception.dart';
import 'package:twitter_login/twitter_login.dart';

import '../Configs/messages.dart';

class AuthController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool obscure = true.obs;

  // State for hidden and visible password fields
  void togglePasswordVisibility() {
    obscure.value = !obscure.value;
  }

  //sign in and sign up by email/password
  //register
  Future<AuthStatus> registerWithEmailPassword(
      String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      return AuthExceptionHandler.handleAuthException(e);
    } catch (e) {
      return AuthStatus.unknown;
    }
  }
  //get the user
  String getCurrentUserEmail() {
    return auth.currentUser!.email!;
  }
  //get the user id
  String getCurrentUserId() {
    return auth.currentUser!.uid;
  }

  //log in
  Future<AuthStatus> signInWithEmailPassword(
      String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      return AuthExceptionHandler.handleAuthException(e);
    } catch (e) {
      return AuthStatus.unknown;
    }
  }

  //change password when the user loged in
  Future<AuthStatus> changePasswordWhenUser(
      String currentPassword, String newPassword, String email) async {
    try {
      User? user = auth.currentUser;

      if (user == null) {
        return AuthStatus.userNotFound;
      }
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      UserCredential authResult =
          await user.reauthenticateWithCredential(credential);
      await authResult.user?.updatePassword(newPassword);
      // await auth.sendPasswordResetEmail(email: email);

      return AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      return AuthExceptionHandler.handleAuthException(e);
    } catch (e) {
      return AuthStatus.unknown;
    }
  }

//change password when the user did not log in
  Future<AuthStatus> changePasswordWhenNotUser(
      String currentPassword, String newPassword, String email) async {
    try {
      // Đăng nhập bằng email và mật khẩu cũ để xác thực người dùng
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: currentPassword,
      );
      await userCredential.user?.updatePassword(newPassword);
      // await auth.sendPasswordResetEmail(email: email);

      return AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      return AuthExceptionHandler.handleAuthException(e);
    } catch (e) {
      return AuthStatus.unknown;
    }
  }

  //reset password
  Future<AuthStatus> resetPassword({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      
      return AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      return AuthExceptionHandler.handleAuthException(e);
    } catch (e) {
      return AuthStatus.unknown;
    }
  }

  //log in with google
  Future<void> loginByGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await auth.signInWithCredential(credential);
      successMessage("Login Success");
      Get.offAllNamed("/updateProfile");
    } catch (e) {
      errorMessage("Login Failed");
      // print(e);
    }
  }

  //log in with twitter (X)
  Future<void> signInWithTwitter() async {
    try {
      final twitterLogin = TwitterLogin(
        apiKey: 'uElLfWtFdDPyyOPyeCJwVmbDW',
        apiSecretKey: 'X15aQdUpdljer6ZmuxLXt7Gte6O8LwlcMBvTP3X4ZsjZWZTJzW',
        redirectURI: 'tictactoeapp://',
      );

      final authResult = await twitterLogin.loginV2();

      final twitterAuthCredential = TwitterAuthProvider.credential(
        accessToken: authResult.authToken!,
        secret: authResult.authTokenSecret!,
      );

      // Once signed in, return the UserCredential
      await auth.signInWithCredential(twitterAuthCredential);
      successMessage("Login Success");
      Get.offAllNamed("/updateProfile");
    } catch (e) {
      errorMessage("Login Failed : ${e.toString()}");
    }
  }

  //TODO: sign in with github

  // Future<void> signInWithGitHub(BuildContext context) async {
  //   try {
  //     // Create a GitHubSignIn instance
  //     final GitHubSignIn gitHubSignIn = GitHubSignIn(
  //         clientId: 'Ov23lii7MlU8pe2ZTPDz',
  //         clientSecret: "04e91041eb445dac7790412b03e5c90b5e38880a",
  //         redirectUrl:
  //             'https://tictactoe-flutter-672ff.firebaseapp.com/__/auth/handler');

  //     // Trigger the sign-in flow
  //     final result = await gitHubSignIn.signIn(context);

  //     // Create a credential from the access token
  //     final githubAuthCredential = GithubAuthProvider.credential(result.token!);

  //     // Once signed in, return the UserCredential
  //     await auth.signInWithCredential(githubAuthCredential);
  //     successMessage("Login Success");
  //     Get.offAllNamed("/updateProfile");
  //   } catch (e) {
  //     errorMessage("Login Failed");
  //     // print(e);
  //   }
  // }
}
