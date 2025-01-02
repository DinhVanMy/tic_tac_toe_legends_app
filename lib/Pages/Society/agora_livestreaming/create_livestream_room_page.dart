import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Models/live_sream_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/optional_tile_custom.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/agora_livestreaming_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/livestream_doc_service.dart';
import 'package:uuid/uuid.dart';

class CreateLivestreamRoomPage extends StatelessWidget {
  final UserModel currentUser;
  const CreateLivestreamRoomPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    RxString titleContent = "".obs;
    RxString descriptionContent = "".obs;
    RxString audienceMode = "Public".obs;
    RxString imagePath = "".obs;
    XFile? image;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back,
              size: 40,
              color: Colors.deepPurple,
            ),
          ),
          centerTitle: false,
          title: Text(
            "Create a new live room",
            style: theme.textTheme.headlineSmall!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            Obx(
              () => titleContent.value.isEmpty ||
                      descriptionContent.value.isEmpty ||
                      imagePath.value.isEmpty
                  ? Container(
                      height: 50,
                      width: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "LIVE",
                        style: theme.textTheme.bodyLarge!
                            .copyWith(color: Colors.black45),
                      ),
                    )
                  : InkWell(
                      onTap: () async {
                        await Get.showOverlay(
                            asyncFunction: () async {
                              var uuid = const Uuid();
                              final String channelId =
                                  uuid.v4().substring(0, 12);
                              final String streamId = uuid.v4().substring(0, 8);
                              List<int> imageBytes = await image!.readAsBytes();
                              String? base64String = base64Encode(imageBytes);
                              LiveStreamService liveStreamService =
                                  LiveStreamService();
                              LiveStreamModel liveStreamModel = LiveStreamModel(
                                streamId: streamId,
                                channelId: channelId,
                                streamer: currentUser,
                                title: titleContent.value,
                                description: descriptionContent.value,
                                thumbnailUrl: base64String,
                                category: audienceMode.value,
                                viewerCount: 1,
                                likeCount: 0,
                                emotes: [],
                                createdAt: DateTime.now(),
                              );
                              await liveStreamService
                                  .createLiveStream(liveStreamModel);
                              Get.to(() => AgoraLivestreamingPage(
                                    currentUser: currentUser,
                                    liveStreamModel: liveStreamModel,
                                    channelId: channelId,
                                    isStreamer: true,
                                  ));
                            },
                            loadingWidget: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  GifsPath.loadingGif,
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ));
                      },
                      child: Ink(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "LIVE",
                            style: theme.textTheme.bodyLarge!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(currentUser.image!),
                      radius: 35,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.name!,
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      audienceMode.value = "Private";
                                    },
                                    child: Obx(
                                      () => Container(
                                        height: 40,
                                        width: 100,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: audienceMode.value == "Private"
                                              ? Colors.blueAccent
                                              : Colors.grey.shade400,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: audienceMode.value ==
                                                      "Private"
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Private",
                                              style: theme.textTheme.bodyMedium!
                                                  .copyWith(
                                                color: audienceMode.value ==
                                                        "Private"
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                                GestureDetector(
                                  onTap: () {
                                    audienceMode.value = "Friends";
                                  },
                                  child: Obx(() => Container(
                                        height: 40,
                                        width: 100,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: audienceMode.value == "Friends"
                                              ? Colors.blueAccent
                                              : Colors.grey.shade400,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.people_alt_rounded,
                                              color: audienceMode.value ==
                                                      "Friends"
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Friends",
                                              style: theme.textTheme.bodyMedium!
                                                  .copyWith(
                                                color: audienceMode.value ==
                                                        "Friends"
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    audienceMode.value = "Public";
                                  },
                                  child: Obx(() => Container(
                                        height: 40,
                                        width: 100,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: audienceMode.value == "Public"
                                              ? Colors.blueAccent
                                              : Colors.grey.shade400,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.public,
                                              color:
                                                  audienceMode.value == "Public"
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Public",
                                              style: theme.textTheme.bodyMedium!
                                                  .copyWith(
                                                color: audienceMode.value ==
                                                        "Public"
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 100,
                  child: TextField(
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        titleContent.value = text;
                      } else {
                        titleContent.value = "";
                      }
                    },
                    minLines: null,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.left,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      labelText: 'Title for live',
                      alignLabelWithHint: true,
                      labelStyle: theme.textTheme.bodyLarge!
                          .copyWith(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 150,
                  child: TextField(
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        descriptionContent.value = text;
                      } else {
                        descriptionContent.value = "";
                      }
                    },
                    minLines: null,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.left,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      labelText: 'Description for live',
                      alignLabelWithHint: true,
                      labelStyle: theme.textTheme.bodyLarge!
                          .copyWith(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    const Text(
                      "Thumbnail",
                      style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final ProfileController profileController =
                                Get.find();

                            image = await profileController
                                .pickFileX(ImageSource.camera);
                            if (image != null) {
                              imagePath.value = image!.path;
                            } else {
                              imagePath.value = "";
                            }
                          },
                          icon: const Icon(
                            Icons.camera_alt_rounded,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final ProfileController profileController =
                                Get.find();

                            image = await profileController
                                .pickFileX(ImageSource.gallery);
                            if (image != null) {
                              imagePath.value = image!.path;
                            } else {
                              imagePath.value = "";
                            }
                          },
                          icon: const Icon(
                            Icons.image_rounded,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            imagePath.value = "";
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    Obx(() => Container(
                          height: 250,
                          width: 200,
                          alignment: Alignment.center,
                          decoration: imagePath.value.isNotEmpty
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(
                                      File(
                                        imagePath.value,
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                  ))
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blueGrey.shade300,
                                ),
                        )),
                    OptionalTileWidget(
                      onTap: () {},
                      title: "Tag people",
                      icon: Icons.person_add_alt_1_sharp,
                      color: Colors.blue,
                    ),
                    Container(
                      height: 50,
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "LIVE",
                        style: theme.textTheme.bodyLarge!
                            .copyWith(color: Colors.black45),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
