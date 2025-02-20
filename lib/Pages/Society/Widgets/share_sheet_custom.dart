import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_edit_model.dart';

class ShareSheetCustom extends StatelessWidget {
  final ScrollController scrollController;
  final UserModel currentUser;
  final VoidCallback onPressed;
  const ShareSheetCustom(
      {super.key,
      required this.scrollController,
      required this.currentUser,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final FirestoreController firestoreController = Get.find();
    final ThemeData theme = Theme.of(context);
    RxString audienceMode = "Public".obs;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 300,
              width: double.maxFinite,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(currentUser.image!),
                        radius: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser.name!,
                              style: theme.textTheme.bodyLarge!
                                  .copyWith(color: Colors.blueAccent),
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
                                            color:
                                                audienceMode.value == "Private"
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
                                                style: theme
                                                    .textTheme.bodyMedium!
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
                                            color:
                                                audienceMode.value == "Friends"
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
                                                style: theme
                                                    .textTheme.bodyMedium!
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
                                            color:
                                                audienceMode.value == "Public"
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
                                                color: audienceMode.value ==
                                                        "Public"
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                "Public",
                                                style: theme
                                                    .textTheme.bodyMedium!
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
                  const Expanded(
                      child: TextField(
                    minLines: null,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                    ),
                  )),
                  ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.redAccent,
                        elevation: 5,
                      ),
                      child: const Text("Share now")),
                ],
              ),
            ),
            const Text(
              "Send in Messenger",
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
              () {
                if (firestoreController.friendsList.isEmpty) {
                  return const SizedBox();
                }
                var friends = firestoreController.friendsList.toList();
                return SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      var friend = friends[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      CachedNetworkImageProvider(friend.image!),
                                  radius: 35,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              friend.name!,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const Text(
              "Share to",
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: PostEditModel.listPostEditModels.length,
                  itemBuilder: (context, index) {
                    var option = PostEditModel.listPostEditModels[index];
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(100),
                            splashColor: Colors.lightBlueAccent,
                            onTap: onPressed,
                            child: Ink(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                option.icon,
                                size: 35,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            option.title,
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
