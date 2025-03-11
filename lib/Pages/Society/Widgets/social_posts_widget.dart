import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Components/shimmers/friendavatar_placeholder_widget.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/create_post_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_list_card.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_controller.dart';
import 'package:tictactoe_gameapp/Components/shimmers/posts_placeholder_widget.dart';

class SocialPostsWidget extends StatelessWidget {
  final PostController postController;
  final UserModel user;
  final ThemeData theme;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorState;
  const SocialPostsWidget(
      {super.key,
      required this.user,
      required this.theme,
      required this.postController,
      required this.refreshIndicatorState});

  @override
  Widget build(BuildContext context) {
    final FirestoreController firestoreController =
        Get.put(FirestoreController());
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () {
                if (postController.postsList.isEmpty) {
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
                  var posts = postController.postsList.toList();
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200) {
                        postController.fetchMoreFilteredPosts();
                      }
                      return true;
                    },
                    child: RefreshIndicator(
                      key: refreshIndicatorState,
                      backgroundColor: Colors.blue,
                      color: Colors.white,
                      onRefresh: () async {
                        await postController.fetchFilteredPosts();
                      },
                      child: ListView.builder(
                        controller: postController.scrollController,
                        itemCount: posts.length +
                            (postController.isFetching.value ? 3 : 0),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index >= posts.length) {
                            return const PostsPlaceholderWidget();
                          } else {
                            var post = posts[index];
                            var postUser = post.postUser!;
                            return Column(
                              children: [
                                index == 0
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.blueAccent,
                                                      width: 3,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                                child: AvatarUserWidget(
                                                    radius: 25,
                                                    imagePath: user.image!),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                  child: GestureDetector(
                                                onTap: () => Get.to(
                                                  CreatePostPage(
                                                    userModel: user,
                                                    postController:
                                                        postController,
                                                  ),
                                                  transition: Transition.zoom,
                                                ),
                                                child: Container(
                                                  height: 45,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    border: Border.all(
                                                      color: Colors.blueGrey,
                                                    ),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'What\'s on your mind?',
                                                      style: theme.textTheme
                                                          .titleMedium!
                                                          .copyWith(
                                                              color: Colors
                                                                  .blueGrey),
                                                    ),
                                                  ),
                                                ),
                                              )),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.image,
                                                  color: Colors.lightGreen,
                                                  size: 40,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Obx(
                                            () {
                                              if (firestoreController
                                                  .isLoadingFriends.value) {
                                                return SizedBox(
                                                  height: 120,
                                                  width: double.infinity,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: 5,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return const FriendavatarPlaceholderWidget();
                                                    },
                                                  ),
                                                );
                                              } else {
                                                if (firestoreController
                                                    .friendsList.isEmpty) {
                                                  return const SizedBox();
                                                } else {
                                                  var friends =
                                                      firestoreController
                                                          .friendsList
                                                          .toList();
                                                  return SizedBox(
                                                    height: 120,
                                                    width: double.infinity,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemCount: friends.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        var friend =
                                                            friends[index];
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Column(
                                                            children: [
                                                              Stack(
                                                                children: [
                                                                  AvatarUserWidget(
                                                                      radius:
                                                                          35,
                                                                      imagePath:
                                                                          friend
                                                                              .image!),
                                                                  Positioned(
                                                                    bottom: 0,
                                                                    right: 0,
                                                                    child:
                                                                        Container(
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .green,
                                                                        borderRadius:
                                                                            BorderRadius.circular(100),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.white,
                                                                          width:
                                                                              3,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Text(
                                                                friend.name!,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                          Row(
                                            children: [
                                              const SizedBox(width: 10),
                                              const Icon(
                                                Icons.filter_list,
                                                size: 35,
                                              ),
                                              const SizedBox(width: 10),
                                              Obx(() => DropdownButton<String>(
                                                    value: postController
                                                        .selectedOption.value,
                                                    icon: const Icon(Icons
                                                        .radio_button_checked_rounded),
                                                    iconSize: 24,
                                                    iconEnabledColor:
                                                        Colors.blue,
                                                    focusColor: Colors.blue,
                                                    elevation: 16,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20),
                                                    underline: const SizedBox(),
                                                    onChanged:
                                                        (String? newValue) {
                                                      if (newValue != null) {
                                                        postController
                                                            .updateSelectedOption(
                                                                newValue);
                                                      }
                                                    },
                                                    items: postController
                                                        .options
                                                        .map<
                                                            DropdownMenuItem<
                                                                String>>((String
                                                            value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                  )),
                                            ],
                                          ),
                                          PostListCard(
                                            post: post,
                                            postUser: postUser,
                                            currentUser: user,
                                            theme: theme,
                                            postController: postController,
                                          ),
                                        ],
                                      )
                                    : PostListCard(
                                        post: post,
                                        postUser: postUser,
                                        currentUser: user,
                                        theme: theme,
                                        postController: postController,
                                      )
                                        .animate()
                                        .scale(duration: duration750)
                                        .fadeIn(duration: duration750),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
