import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/create_post_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_list_card.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_controller.dart';

class FriendBlogPage extends StatelessWidget {
  final PostController postController;
  final UserModel user;
  final ThemeData theme;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorState;
  const FriendBlogPage(
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(child: Obx(() {
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
                return RefreshIndicator(
                  key: refreshIndicatorState,
                  backgroundColor: Colors.blue,
                  color: Colors.white,
                  onRefresh: () async {
                    await postController.fetchInitialPosts();
                  },
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200) {
                        postController.fetchMorePosts();
                      }
                      return true;
                    },
                    child: ListView.builder(
                      controller: postController.scrollController,
                      itemCount: posts.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var post = posts[index];
                        var postUser = post.postUser!;
                        return Column(
                          children: [
                            index == 0
                                ? Column(
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
                                                    BorderRadius.circular(50)),
                                            child: CircleAvatar(
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      user.image!),
                                              radius: 25,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            onTap: () => Get.to(CreatePostPage(
                                              userModel: user,
                                              postController: postController,
                                            )),
                                            child: Ink(
                                              height: 45,
                                              padding: const EdgeInsets.only(
                                                  left: 20),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                border: Border.all(
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'What\'s on your mind?',
                                                  style: theme
                                                      .textTheme.titleMedium!
                                                      .copyWith(
                                                          color:
                                                              Colors.blueGrey),
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
                                              .friendsList.isEmpty) {
                                            return Center(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                child:
                                                    const CircularProgressIndicator(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            );
                                          }
                                          var friends = firestoreController
                                              .friendsList
                                              .toList();
                                          return SizedBox(
                                            height: 120,
                                            width: double.infinity,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemCount: friends.length,
                                              itemBuilder: (context, index) {
                                                var friend = friends[index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundImage:
                                                                CachedNetworkImageProvider(
                                                                    friend
                                                                        .image!),
                                                            radius: 35,
                                                          ),
                                                          Positioned(
                                                            bottom: 0,
                                                            right: 0,
                                                            child: Container(
                                                              width: 20,
                                                              height: 20,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .green,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 3,
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
                                        },
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
                                  ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              }
            })),
          ],
        ),
      ),
    );
  }
}
