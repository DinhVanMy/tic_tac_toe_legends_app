import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/theme/colors.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';

final AuthController authController = Get.find();
final ProfileController profileController = Get.find();

void successMessage(String message) {
  Get.showSnackbar(
    GetSnackBar(
      title: 'Success',
      message: message,
      icon: Image.asset("assets/icons/check.png"),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
      borderRadius: 20,
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // Dismiss the snackbar
        },
        child: const Text(
          'DISMISS',
          style: TextStyle(color: Colors.deepPurple),
        ),
      ),
      overlayBlur: 1,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeInOut,
      leftBarIndicatorColor: Colors.greenAccent,
    ),
  );
}

void errorMessage(String message) {
  Get.showSnackbar(
    GetSnackBar(
      title: 'Error',
      message: message,
      icon: Image.asset(
        "assets/icons/warning.png",
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: primaryColor,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
      borderRadius: 20,
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // Dismiss the snackbar
        },
        child: const Text(
          'DISMISS',
          style: TextStyle(color: Colors.white),
        ),
      ),
      overlayBlur: 1,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeInOutCubicEmphasized,
    ),
  );
}

void logoutMessage(BuildContext context) {
  Get.dialog(Dialog(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: Colors.redAccent, width: 3.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.red,
            offset: Offset(-5, 10),
            blurRadius: 2,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Image.asset(GifsPath.chatbotGif),
          ),
          const SizedBox(
            height: 10,
          ),
          Image.asset(
            "assets/icons/question-mark.png",
            width: 40,
          ),
          const SizedBox(
            height: 0,
          ),
          Text(
            "Are you sure you want to log out?",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.red, fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () {
                  Get.back();
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  await authController.auth.signOut();
                  Get.offAllNamed("/auth");
                  successMessage("Logout successful!");
                  await profileController.removeProfileNewUser();
                },
                child: const Text("LogOut"),
              ),
            ],
          ),
        ],
      ),
    ),
  ));
}
