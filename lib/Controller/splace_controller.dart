import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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
      Get.offAllNamed("/mainHome");
    }
  }
}
