import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/primary_button.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/Animations/dot_matching_animation_controller.dart';
import 'package:tictactoe_gameapp/Controller/Music/music_controller.dart';
import 'package:tictactoe_gameapp/Controller/room_controller.dart';
import 'package:tictactoe_gameapp/Controller/matching_controller.dart';

class RoomPage extends StatelessWidget {
  const RoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    RoomController roomController = Get.put(RoomController());
    final MatchingController matchingController = Get.put(MatchingController());
    final MatchingAnimationController matchingAnimationController =
        Get.put(MatchingAnimationController());
    TextEditingController roomId = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final MusicController musicController = Get.find();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                        onTap: () {
                          matchingController.cancelMatching();
                          musicController.stopMusicOnScreen8(1.0);
                          Get.back();
                        },
                        child: SvgPicture.asset(IconsPath.backIcon)),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Play With Private Room",
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  ],
                ),
                const Spacer(
                  flex: 1,
                ),
                Text(
                  "Enter Private And Join With your Friends",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: roomId,
                  textAlign: TextAlign.center,
                  validator: roomCodeValidator.call,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                      fillColor: Theme.of(context).colorScheme.primaryContainer,
                      filled: true,
                      hintText: "Enter Room Code",
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20))),
                ),
                const SizedBox(
                  height: 20,
                ),
                Obx(
                  () => roomController.isLoading.value
                      ? const CircularProgressIndicator()
                      : PrimaryButton(
                          buttonText: "Join Now",
                          onTap: () {
                            // notificationController.registerDeviceToken();
                            if (formKey.currentState!.validate()) {
                              if (roomId.text.isNotEmpty) {
                                roomController.joinRoom(roomId.text);
                              }
                            } else {
                              errorMessage("Bro, enter room code clearly!");
                            }
                          }),
                ),
                const Spacer(
                  flex: 5,
                ),
                Obx(() {
                  if (roomController.isLoading.value) {
                    return const CircularProgressIndicator(
                      color: Colors.red,
                    );
                  } else if (matchingController.isSearching.value) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            GifsPath.loadingGif,
                            height: 200,
                            width: 200,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Matching",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(color: Colors.lightBlueAccent),
                            ),
                            const SizedBox(width: 5),
                            Obx(
                              () {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Transform.translate(
                                      offset: Offset(
                                          0,
                                          matchingAnimationController
                                              .dotsOffset1.value),
                                      child: const Icon(
                                        Icons.square_outlined,
                                        color: Colors.lightBlueAccent,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Transform.translate(
                                      offset: Offset(
                                          0,
                                          matchingAnimationController
                                              .dotsOffset2.value),
                                      child: const Icon(
                                        Icons.square_outlined,
                                        color: Colors.lightBlueAccent,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Transform.translate(
                                      offset: Offset(
                                          0,
                                          matchingAnimationController
                                              .dotsOffset3.value),
                                      child: const Icon(
                                        Icons.square_outlined,
                                        color: Colors.lightBlueAccent,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (matchingController.isLoading.value) {
                    return const CircularProgressIndicator(
                      color: Colors.blue,
                    );
                  } else {
                    return Text(
                      "Create Private Room",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    );
                  }
                }),
                const Spacer(
                  flex: 4,
                ),
                Obx(
                  () => matchingController.isSearching.value
                      ? PrimaryButton(
                          buttonText: "Cancel",
                          onTap: () {
                            musicController.stopMusicOnScreen8(1.0);
                            matchingController.cancelMatching();
                          },
                        )
                      : PrimaryButton(
                          buttonText: "Matching",
                          onTap: () {
                            musicController.playMusicOnScreen8();
                            matchingController.startMatching();
                          },
                        ),
                ),
                const Spacer(
                  flex: 1,
                ),
                PrimaryButton(
                  buttonText: "Create Room",
                  onTap: () {
                    roomController.createRoom();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
