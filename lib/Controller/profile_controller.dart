import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Models/queue_model.dart';
import '../Configs/messages.dart';

class ProfileController extends GetxController {
  final _box = GetStorage();
  final ImagePicker picker = ImagePicker();
  final store = FirebaseStorage.instance;
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;
  Rx<UserModel> user = UserModel().obs;

  Future<void> updateProfile(String name, String imagePath) async {
    isLoading.value = true;
    try {
      if (imagePath != "" && name != "") {
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
        //store in local storage
        final jsonString = jsonEncode(newUser.toJson());
        await _box
            .write('newUser', jsonString)
            .catchError((e) => errorMessage(e.toString()));

        successMessage("Profile Updated");
        Get.offAllNamed("/mainHome");
      } else {
        errorMessage("Please fill all the fields");
      }
    } catch (e) {
      errorMessage("Profile Update Failed");
    }
    isLoading.value = false;
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
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      return image.path;
    } else {
      return "";
    }
  }

  Future<XFile?> pickFileX(ImageSource source) async {
    final XFile? image = await picker.pickImage(source: source);
    return image;
  }

  Future<void> fetchUserProfile() async {
    try {
      String userId = auth.currentUser?.uid ?? "";
      if (userId.isEmpty) {
        errorMessage("User ID is empty.");
        return;
      }
      DocumentSnapshot userDoc = await db.collection('users').doc(userId).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        user.value = UserModel.fromJson(userData);
      } else {
        errorMessage("Not found 404");
      }
    } catch (e) {
      errorMessage("Failed to fetch user profile: $e");
    }
  }

  UserModel readProfileNewUser() {
    //read in local storage
    final storedString = _box.read('newUser');
    final storedUser = UserModel.fromJson(jsonDecode(storedString));
    return storedUser;
  }

  Future<void> removeProfileNewUser() async {
    await _box.remove('newUser');
  }
}
