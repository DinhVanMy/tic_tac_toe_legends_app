import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/About/user_about_page.dart';

class LikeUserListSheet extends StatelessWidget {
  final List<UserModel> likeUsers;
  final ScrollController scrollController;
  const LikeUserListSheet(
      {super.key, required this.likeUsers, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 35,
                ),
              ),
              Text(
                'People liked post',
                style: theme.textTheme.headlineMedium,
              ),
              IconButton(
                onPressed: () {
                  scrollController.animateTo(0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.bounceInOut);
                },
                icon: const Icon(
                  Icons.refresh_outlined,
                  size: 35,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const Divider(
            color: Colors.blueGrey,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: likeUsers.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  UserModel likeUser = likeUsers[index];
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.blue, width: 3),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(
                                  UserAboutPage(
                                    unknownableUser: likeUser,
                                  ),
                                  transition: Transition.leftToRightWithFade);
                            },
                            child: AvatarUserWidget(
                                radius: 30, imagePath: likeUser.image!),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                likeUser.name!,
                                style: theme.textTheme.bodyLarge,
                              ),
                              Text(
                                likeUser.email!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {},
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
                                Text("Add Friend"),
                              ],
                            )),
                      ],
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
