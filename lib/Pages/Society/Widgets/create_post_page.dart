import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/optional_tile_custom.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/society_gaming_page.dart';

class CreatePostPage extends StatelessWidget {
  final PostController postController;
  final UserModel userModel;
  const CreatePostPage(
      {super.key, required this.userModel, required this.postController});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    RxString postContent = "".obs;
    RxString audienceMode = "Public".obs;
    RxList<Color> backgroundPost = <Color>[].obs;
    RxList<String>? imagePath = <String>[].obs;
    List<XFile>? images;
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
          "Create a new post",
          style: theme.textTheme.headlineMedium,
        ),
        actions: [
          Obx(
            () => postContent.value.isEmpty || postContent.value == ""
                ? Container(
                    height: 50,
                    width: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "POST",
                      style: theme.textTheme.bodyLarge!
                          .copyWith(color: Colors.black45),
                    ),
                  )
                : InkWell(
                    onTap: () async {
                      await Get.showOverlay(
                          asyncFunction: () async {
                            await postController.createPost(
                              content: postContent.value,
                              user: userModel,
                              backgroundPost: backgroundPost.toList(),
                              privacy: audienceMode.value,
                              imageFiles: images,
                            );
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
                          )).then((_) {
                        Get.to(const SocietyGamingPage());
                      });
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
                          "POST",
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
                        CachedNetworkImageProvider(userModel.image!),
                    radius: 35,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userModel.name!,
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
                                      margin: const EdgeInsets.only(right: 10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: audienceMode.value == "Private"
                                            ? Colors.blueAccent
                                            : Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color:
                                                audienceMode.value == "Private"
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
                                      margin: const EdgeInsets.only(right: 10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: audienceMode.value == "Friends"
                                            ? Colors.blueAccent
                                            : Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.people_alt_rounded,
                                            color:
                                                audienceMode.value == "Friends"
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
                                      margin: const EdgeInsets.only(right: 10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: audienceMode.value == "Public"
                                            ? Colors.blueAccent
                                            : Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(10),
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
                                              color:
                                                  audienceMode.value == "Public"
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
              Obx(() => Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: backgroundPost.isEmpty
                            ? [Colors.white, Colors.white]
                            // ignore: invalid_use_of_protected_member
                            : backgroundPost.value,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      onChanged: (text) {
                        if (text.isNotEmpty) {
                          postContent.value = text;
                        } else {
                          postContent.value = "";
                        }
                      },
                      minLines: null,
                      maxLines: null,
                      expands: true,
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        fillColor: Colors.transparent,
                        labelText: '  What\'s on your mind?',
                        alignLabelWithHint: true,
                        labelStyle: theme.textTheme.bodyLarge!.copyWith(
                            color: backgroundPost.isEmpty
                                ? Colors.grey
                                : Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: gradientColors.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              backgroundPost.value = gradientColors[index];
                            },
                            child: Ink(
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: gradientColors[index],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      );
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              Obx(() {
                if (imagePath.isEmpty) {
                  return const SizedBox();
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 150,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: imagePath.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(
                                          imagePath[index],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: -20,
                                      right: -20,
                                      child: IconButton(
                                        onPressed: () {
                                          imagePath.removeAt(index);
                                        },
                                        icon: const Icon(
                                          Icons.cancel,
                                          size: 28,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })),
                    IconButton(
                      onPressed: () {
                        imagePath.clear();
                      },
                      icon:
                          const Icon(Icons.delete, size: 40, color: Colors.red),
                    ),
                  ],
                );
              }),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  const Divider(
                    color: Colors.grey,
                  ),
                  OptionalTileWidget(
                    onTap: () async {
                      images = await postController.pickMultiImages();
                      if (images != null) {
                        imagePath.value =
                            images!.map((xFile) => xFile.path).toList();
                      } else {
                        imagePath.value = [];
                      }
                    },
                    title: "Image / Video",
                    icon: Icons.image,
                    color: Colors.green,
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  OptionalTileWidget(
                    onTap: () async {
                      image = await postController.pickImageCamera();
                      if (image != null) {
                        imagePath.add(image!.path);
                      } else {
                        imagePath.value = [];
                      }
                    },
                    title: "Catch up moments",
                    icon: Icons.camera_alt,
                    color: Colors.deepPurple,
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  OptionalTileWidget(
                    onTap: () {},
                    title: "Tag people",
                    icon: Icons.person_add_alt_1_sharp,
                    color: Colors.blue,
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  OptionalTileWidget(
                    onTap: () {},
                    title: "Feeling / Activity",
                    icon: Icons.emoji_emotions_outlined,
                    color: Colors.orange,
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  OptionalTileWidget(
                    onTap: () {},
                    title: "Check in",
                    icon: Icons.add_location_alt,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
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
                  "POST",
                  style: theme.textTheme.bodyLarge!
                      .copyWith(color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
