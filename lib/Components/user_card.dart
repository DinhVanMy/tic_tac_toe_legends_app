import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/Animations/Overlays/profile_tooltip.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Enums/popup_position.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

import '../Configs/assets_path.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final String status;

  const UserCard({
    super.key,
    required this.user,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final AuthController authController = Get.find();
    final ProfileTooltip profileTooltip = Get.put(ProfileTooltip());
    final GlobalKey itemKey = GlobalKey();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: w / 2.6,
          height: 160,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: user.email == authController.getCurrentUserEmail()
                  ? Colors.blueAccent
                  : Colors.redAccent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text(
                user.name ?? '',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: user.email == authController.getCurrentUserEmail()
                          ? Colors.blueAccent
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                user.role ?? '',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    IconsPath.coinIcon,
                    width: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${user.totalCoins ?? "00"} Coins",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color:
                              user.email == authController.getCurrentUserEmail()
                                  ? Colors.blueAccent
                                  : Colors.redAccent,
                        ),
                  ),
                ],
              ),
              status == ""
                  ? const SizedBox()
                  : status == "ready"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.done,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(status),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.watch_later_outlined,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(status),
                          ],
                        ),
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          left: w / 2.6 / 2 - 110,
          child: Image.asset(
            BorderRanking.challBorder,
            width: 220,
          ),
        ),
        Positioned(
          top: -50,
          left: w / 2.6 / 2 - 50,
          child: GestureDetector(
            key: itemKey,
            onTap: () => profileTooltip.showProfileTooltip(
              context,
              itemKey,
              user,
              PopupPosition.above,
              null,
              null,
              null,
              // user.email == authController.getCurrentUserEmail()
              //     ? Colors.lightBlueAccent
              //     : Colors.redAccent,
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: user.email == authController.getCurrentUserEmail()
                      ? Colors.blue
                      : Colors.red,
                  width: 5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: user.image ?? "",
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
