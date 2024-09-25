import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Components/primary_with_icon_button.dart';
import 'package:tictactoe_gameapp/Configs/theme/colors.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/draws.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import '../../Configs/assets_path.dart';

class UpdateProfile extends StatelessWidget {
  const UpdateProfile({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.find<ProfileController>();
    RxString imagePath = "".obs;
    TextEditingController nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ConfettiController confettiController =
        ConfettiController(duration: const Duration(seconds: 5));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.person,
            color: primaryColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5, right: 20, left: 20),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        // const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Obx(
                              () => imagePath == ""
                                  ? Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(40),
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
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Image.file(
                                          File(
                                            imagePath.value,
                                          ),
                                          fit: BoxFit.cover,
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
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
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: nameController,
                          validator: nameProfile.call,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            hintText: "Enter your name",
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "You can change these details later  from profile page. don’t worry",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                    Obx(
                      () => profileController.isLoading.value
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.asset(
                                GifsPath.loadingGif,
                                height: 200,
                                width: 200,
                              ),
                            )
                          : PrimaryIconWithButton(
                              color: Theme.of(context).colorScheme.primary,
                              buttonText: "Save",
                              onTap: () async {
                                if (formKey.currentState!.validate()) {
                                  //if namecontroller =
                                  confettiController.play();
                                  await profileController.updateProfile(
                                      nameController.text, imagePath.value);
                                } else {
                                  errorMessage("Bro, enter your name clearly!");
                                }
                              },
                              iconPath: IconsPath.save,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality
                  .explosive, // Nổ theo mọi hướng từ trung tâm
              shouldLoop: false, // Không lặp lại
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
                Colors.pink,
                Colors.teal,
                Colors.cyan,
                Colors.amber
              ],
              createParticlePath: (size) {
                // Tạo hạt với các hình dạng khác nhau
                return DrawPath.drawStarOfficial(size);
              },
              numberOfParticles: 100, // Số lượng hạt nổ ra
              emissionFrequency: 0.05, // Tần suất nổ
              gravity: 1, // Lực hấp dẫn, tốc độ rơi của các hạt
              minBlastForce: 10, // Lực nổ nhỏ nhất
              maxBlastForce: 100, // Lực nổ lớn nhất
              particleDrag: 0.05, // Lực cản khi các hạt rơi xuống
            ),
          ),
        ],
      ),
    );
  }
}
