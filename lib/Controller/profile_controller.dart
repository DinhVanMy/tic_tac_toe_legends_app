import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Models/queue_model.dart';
import '../Configs/messages.dart';

class ProfileController extends GetxController {
  final ImagePicker picker = ImagePicker();
  final store = FirebaseStorage.instance;
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final String userId = Get.find<AuthController>().getCurrentUserId();
  late final UserModel? user;

  // @override
  // void onInit() {
  //   super.onInit();
  //   initialize();
  // }

  Future<void> initialize() async {
    user = await getUserById();
  }

  Future<UserModel?> getUserById() async {
    try {
      // Thực hiện truy vấn Firestore để lấy document của user
      DocumentSnapshot userDoc = await db.collection('users').doc(userId).get();

      // Kiểm tra xem document có tồn tại không
      if (userDoc.exists) {
        // Nếu có, trả về UserModel từ document data
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      } else {
        errorMessage("User không tồn tại với id: $userId");
        return null;
      }
    } catch (e) {
      errorMessage("Lỗi khi lấy UserModel từ Firestore: $e");
      return null;
    }
  }

  Rx<UserModel?> rxUser = Rx<UserModel?>(null);
  void listenToUserByIdRealTime(String userId) {
    db
        .collection('users')
        .doc(userId)
        .snapshots() // Lắng nghe sự thay đổi theo thời gian thực
        .listen((documentSnapshot) {
      if (documentSnapshot.exists) {
        // Nếu document tồn tại, chuyển đổi dữ liệu thành UserModel và cập nhật vào Rx
        rxUser.value =
            UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
      } else {
        // Nếu không tồn tại, cập nhật Rx với giá trị null
        rxUser.value = null;
      }
    });
  }

  Future<void> updateProfile(String name, String imagePath,
      ConfettiController confettiController) async {
    try {
      bool exists = await isUserNameExists(name);
      if (imagePath != "" && name != "" && exists == false) {
        confettiController.play();
        var uploadedImageUrl = await uploadImageToFirebase(imagePath);
        var newQueue = QueueModel(
          userId: auth.currentUser!.uid,
          isSearching: false,
          createdAt: DateTime.now(),
          userEmail: auth.currentUser!.email,
        );
        var newUser = UserModel(
          id: auth.currentUser!.uid,
          name: name,
          image: uploadedImageUrl,
          email: auth.currentUser!.email,
          totalCoins: "0",
          totalWins: "0",
          status: "online",
        );
        await db
            .collection("users")
            .doc(auth.currentUser!.uid)
            .set(
              newUser.toJson(),
            )
            .catchError((e) => errorMessage(e.toString()));
        await db
            .collection('matchings')
            .doc(auth.currentUser!.uid)
            .set(newQueue.toJson())
            .catchError((e) => errorMessage(e.toString()));
      } else if (exists == true) {
        errorMessage("Username already exists");
      } else {
        errorMessage("Please fill all the fields");
      }
    } catch (e) {
      errorMessage("Profile Update Failed");
    }
  }

  Future<String> uploadImageToFirebase(String imagePath) async {
    final path = "files/$imagePath";
    final file = File(imagePath);
    if (imagePath != "") {
      try {
        final ref = store.ref().child(path).putFile(file);
        final uploadTask = await ref.whenComplete(() {});
        final downloadImageUrl = await uploadTask.ref.getDownloadURL();
        // print(downloadImageUrl);
        return downloadImageUrl;
      } catch (ex) {
        // print(ex);
        return "";
      }
    }
    return "";
  }

  Future<String> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
    );
    if (image != null) {
      return image.path;
    } else {
      return "";
    }
  }

  Future<XFile?> pickFileX(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      maxHeight: 240,
      maxWidth: 320,
    );
    return image;
  }

  Future<XFile?> pickImageGallery() async {
    final XFile? images = await picker.pickImage(
      maxHeight: 240,
      maxWidth: 320,
      source: ImageSource.gallery,
    );
    return images;
  }

  Future<XFile?> pickImageCamera() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 240,
      maxWidth: 320,
    );
    return image;
  }

  Future<bool> isUserNameExists(String name) async {
    try {
      final querySnapshot =
          await db.collection('users').where('name', isEqualTo: name).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      errorMessage("Error checking username: $e");
      return false;
    }
  }
}
