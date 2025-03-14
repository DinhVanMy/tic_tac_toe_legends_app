import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/theme/colors.dart';
import 'package:tictactoe_gameapp/Controller/online_status_controller.dart';

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

void logoutMessage(
    BuildContext context, OnlineStatusController onlineStatusController) {
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
                  // await authController.auth.signOut();
                  await onlineStatusController.setOffline();
                  Get.offAllNamed("/auth");
                  successMessage("Logout successful!");
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

void showNoConnectionDialog({required Function() onPressed}) {
  if (Get.isDialogOpen == false) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Oops... No internet connection',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'You need to be connected to your network connection or Wi-Fi to make online activity.',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: onPressed,
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
        icon: const Icon(
          Icons.warning,
          size: 40,
        ),
        iconColor: Colors.red,
      ),
      barrierDismissible: false,
    );
  }
}

void winnerDialog(
    {required Function()? onPlayAgain, required Function()? onExit}) {
  // musicPlayController.playSoundWinner();
  Get.defaultDialog(
    barrierDismissible: false,
    title: "VICTORY",
    backgroundColor: Colors.white,
    titleStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.blue,
      fontSize: 30,
    ),
    content: Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent, width: 5),
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                IconsPath.wonIcon,
                width: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                "Congratulations",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueAccent,
                ),
              ),
              const Text(
                "You won the match",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: onPlayAgain,
                    child: const Text("Play Again"),
                  ),
                  ElevatedButton(
                    onPressed: onExit,
                    child: const Text("Exit"),
                  )
                ],
              )
            ],
          ),
        ),
        // const Center(
        //   child: ConfettiWidgetCustom(),
        // )
      ],
    ),
  );
}

Future<bool> showPermissionDeniedDialog() async {
    bool? retry;
    await Get.dialog(
      AlertDialog(
        title: const Text("Yêu Cầu Quyền Overlay"),
        content: const Text(
          "Ứng dụng cần quyền overlay để hiển thị bong bóng chat. Bạn có muốn cấp quyền không?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Đóng dialog
              retry = false; // Bỏ qua
            },
            child: const Text("Bỏ Qua"),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Đóng dialog
              retry = true; // Thử lại
            },
            child: const Text("Thử Lại"),
          ),
        ],
      ),
    );
    return retry ?? false; // Mặc định bỏ qua nếu không chọn
  }
