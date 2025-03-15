import 'dart:io';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Components/primary_with_icon_button.dart';
import 'package:tictactoe_gameapp/Configs/theme/colors.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Models/Functions/color_string_reverse_function.dart';
import 'package:tictactoe_gameapp/Pages/UpdateProfile/border_frame_controller.dart';
import '../../Configs/assets_path.dart';

class UpdateProfile extends StatelessWidget {
  const UpdateProfile({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.put(ProfileController());
    RxString imagePath = "".obs;
    TextEditingController nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ConfettiController confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    final BorderFrameController frameController =
        Get.put(BorderFrameController());
    RxList<Color> avatarFrame = <Color>[].obs;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryColor,
            size: 35,
          ),
        ),
        title: const Text(
          "Update Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 5, right: 20, left: 20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      "Avatar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Obx(
                          () => avatarFrame.toList().isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: avatarFrame.toList(),
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Obx(
                                    () => imagePath.isEmpty
                                        ? Container(
                                            width: 200,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                            child: const Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Container(
                                            width: 200,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              // color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              child: Image.file(
                                                File(
                                                  imagePath.value,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                  ),
                                )
                              : Obx(
                                  () => imagePath.isEmpty
                                      ? Container(
                                          width: 200,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                          child: const Icon(
                                            Icons.add_a_photo_outlined,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Container(
                                          width: 200,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            // color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            child: Image.file(
                                              File(
                                                imagePath.value,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                imagePath.value = await profileController
                                    .pickImage(ImageSource.gallery);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: SvgPicture.asset(
                                  IconsPath.gallery,
                                  width: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            InkWell(
                              onTap: () async {
                                imagePath.value = await profileController
                                    .pickImage(ImageSource.camera);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: SvgPicture.asset(
                                  IconsPath.camera,
                                  width: 40,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Nickname",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      maxLength: 20,
                      validator: nameProfile.call,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        hintText: "Enter your name",
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Border Frame",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 400,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (!frameController.isLoading.value &&
                              scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent * 0.9) {
                            frameController.loadMoreGradients();
                          }
                          return true;
                        },
                        child: Obx(() => GridView.builder(
                              controller: frameController.scrollController,
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: frameController.gradients.length +
                                  (frameController.isLoading.value ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < frameController.gradients.length) {
                                  var colors = frameController.gradients[index];
                                  return InkWell(
                                    splashColor: Colors.blue,
                                    onTap: () => avatarFrame.value = colors,
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: colors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Obx(
                                        () => imagePath.isEmpty
                                            ? const DecoratedBox(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 35,
                                                  color: Colors.blueGrey,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: Image.file(
                                                  File(
                                                    imagePath.value,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                PrimaryIconWithButton(
                  color: Theme.of(context).colorScheme.primary,
                  buttonText: "Save",
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      Get.showOverlay(
                          asyncFunction: () async {
                            await profileController.updateProfile(
                              nameController.text,
                              imagePath.value,
                              confettiController,
                              avatarFrame
                                  .toList()
                                  .map((color) =>
                                      ColorStringReverseFunction.colorToHex(
                                          color))
                                  .toList(),
                            );
                            await profileController.initialize();
                          },
                          loadingWidget: Center(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 5.0, sigmaY: 5.0),
                                    child: const SizedBox(),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.asset(
                                    GifsPath.loadingGif,
                                    height: 200,
                                    width: 200,
                                  ),
                                ),
                              ],
                            ),
                          )).then((_) => Get.toNamed("/mainHome"));
                    } else {
                      errorMessage("Bro, enter your name clearly!");
                    }
                  },
                  iconPath: IconsPath.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
