import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/notify_in_main_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Friends/chat_with_friend_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/About/Widgets/post_section_widget.dart';
import 'package:tictactoe_gameapp/Pages/Society/About/user_about_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_edit_model.dart';

class UserAboutPage extends StatelessWidget {
  final String intdexString;
  final UserModel unknownableUser;
  final bool isCardTinder;

  const UserAboutPage({
    super.key,
    required this.unknownableUser,
    required this.intdexString,
    this.isCardTinder = false,
  });

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();
    UserModel currentUser = profileController.user!;
    final ThemeData theme = Theme.of(context);
    final ScrollController scrollController = ScrollController();
    final UserAboutController userAboutController =
        Get.put(UserAboutController(userId: unknownableUser.id!));
    final FirestoreController firestoreController =
        Get.find<FirestoreController>();

    final List<String> options = ["Favoritest", "Newest", "Oldest"];
    var selectedOption = 'Newest'.obs;

    return Scaffold(
        backgroundColor: isCardTinder ? Colors.transparent : null,
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            unknownableUser.name!,
            style: theme.textTheme.bodyLarge,
          ),
          leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 40,
              )),
          actions: [
            IconButton(
                onPressed: () {
                  scrollController.animateTo(0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOutCirc);
                },
                icon: const Icon(
                  Icons.refresh,
                  size: 35,
                  color: Colors.blueAccent,
                )),
          ],
        ),
        body: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Image.asset(
                          GifsPath.loadingGif,
                          fit: BoxFit.fitWidth,
                        )),
                    Positioned(
                      bottom: -100,
                      left: 20,
                      child: Hero(
                        tag: "user_avatar_$intdexString",
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 5),
                          ),
                          child: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                unknownableUser.image!),
                            radius: 100,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 110,
                    left: 10,
                    right: 10,
                    bottom: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        unknownableUser.name!,
                        style: theme.textTheme.headlineLarge,
                      ),
                      Text(
                        unknownableUser.email!,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Text(
                                userAboutController.friendsList.length
                                    .toString(),
                                style: theme.textTheme.bodyMedium,
                              ),
                              const Text(
                                " friends",
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "0",
                                style: theme.textTheme.bodyMedium,
                              ),
                              const Text(
                                " mutual friends",
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              bool isFriend = firestoreController
                                  .isFriend(unknownableUser.id!)
                                  .value;
                              return isFriend
                                  ? ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        shadowColor: Colors.redAccent,
                                        elevation: 5,
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.person),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Text(
                                              "Friend",
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        successMessage(
                                            'You added ${unknownableUser.name!} to the list of friends');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.redAccent,
                                        elevation: 5,
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.person_add),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(child: Text("Add Friend")),
                                        ],
                                      ),
                                    );
                            }),
                          ),
                          Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  final NotifyInMainController
                                      notifyInMainController =
                                      Get.put(NotifyInMainController());
                                  Get.to(() => ChatWithFriendPage(
                                        userFriend: unknownableUser,
                                        notifyInMainController:
                                            notifyInMainController,
                                      ));
                                },
                                clipBehavior: Clip.antiAlias,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.redAccent,
                                  elevation: 5,
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.message_rounded),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(child: Text("Message")),
                                  ],
                                )),
                          ),
                          Expanded(
                            child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.redAccent,
                                  elevation: 5,
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.menu_open_rounded),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(child: Text("Menu")),
                                  ],
                                )),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 10,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Details",
                        style: theme.textTheme.bodyLarge,
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                            itemCount: PostEditModel.listPostEditModels.length,
                            itemBuilder: (context, index) {
                              var option =
                                  PostEditModel.listPostEditModels[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          option.icon,
                                          size: 25,
                                          color: Colors.blueGrey,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            option.description,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Friends",
                        style: theme.textTheme.bodyLarge,
                      ),
                      Obx(
                        () {
                          if (userAboutController.friendsList.isEmpty) {
                            return const SizedBox();
                          }
                          var friends =
                              userAboutController.friendsList.toList();
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
                                                CachedNetworkImageProvider(
                                                    friend.image!),
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
                                                borderRadius:
                                                    BorderRadius.circular(100),
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
                                        style: theme.textTheme.bodyLarge!
                                            .copyWith(color: Colors.blueAccent),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      Text(
                        "${unknownableUser.name}'s Posts",
                        style: theme.textTheme.bodyLarge,
                      ),
                      Obx(() => DropdownButton<String>(
                            value: selectedOption.value,
                            icon:
                                const Icon(Icons.radio_button_checked_rounded),
                            iconSize: 24,
                            iconEnabledColor: Colors.blue,
                            focusColor: Colors.blue,
                            elevation: 16,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            style: const TextStyle(
                                color: Colors.black, fontSize: 20),
                            underline: const SizedBox(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                selectedOption.value = newValue;
                              }
                            },
                            items: options
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() {
                        if (userAboutController.postsList.isEmpty) {
                          return Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            ),
                          );
                        } else {
                          var posts = userAboutController.postsList.toList();
                          return ListView.builder(
                              itemCount: posts.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                var post = posts[index];
                                var postUser = post.postUser!;
                                return PostSectionWidget(
                                  theme: theme,
                                  post: post,
                                  postUser: postUser,
                                  currentUser: currentUser,
                                );
                              });
                        }
                      })
                    ],
                  ),
                ),
              ],
            )));
  }
}
