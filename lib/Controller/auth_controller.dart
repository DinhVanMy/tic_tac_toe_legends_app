import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Enums/firebase_exception.dart';

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
    if (auth.currentUser != null) {
      return auth.currentUser!.uid;
    } else {
      return "A2ABTw0gGsPGH14XWiRU50p1u1y2";
    }
  }

  //log in
  Future<AuthStatus> signInWithEmailPassword(
      String email, String password) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // Kiểm tra thông tin user sau khi đăng nhập thành công
      final userId = auth.currentUser?.uid;
      if (userId != null) {
        final userSnapshot =
            await firestore.collection('users').doc(userId).get();

        if (userSnapshot.exists) {
          final userData = userSnapshot.data() as Map<String, dynamic>;

          // Kiểm tra các trường name và image
          final name = userData['name'];
          final image = userData['image'];

          if (name == null || image == null) {
            // Chuyển hướng đến trang UpdateProfileScreen
            Get.offAllNamed('/updateProfile');
          } else {
            Get.find<ProfileController>();
            Get.offAllNamed('/mainHome');
          }
        } else {
          // Trường hợp user không tồn tại trên Firestore
          errorMessage("User document not found.");
          return AuthStatus.unknown;
        }
      }

      return AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      return AuthExceptionHandler.handleAuthException(e);
    } catch (e) {
      errorMessage("Error during sign-in: $e");
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
}
