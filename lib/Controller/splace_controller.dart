import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/online_status_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';

class SplaceController extends GetxController {
  final auth = FirebaseAuth.instance;

  @override
  void onInit() async {
    super.onInit();
    await splaceHandle();
  }

  Future<void> splaceHandle() async {
    await Future.delayed(const Duration(seconds: 1));
    if (auth.currentUser == null) {
      Get.offAllNamed("/welcome");
    } else {
      final ProfileController profileController = Get.put(ProfileController());
      await profileController.initialize();
      Get.put(OnlineStatusController(), permanent: true);
      Get.offAllNamed("/mainHome");
    }
  }
}
