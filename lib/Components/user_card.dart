import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';

import '../Configs/assets_path.dart';

class UserCard extends StatelessWidget {
  final String imageUrl;
  final String? email;
  final String name;
  final String coins;
  final String status;
  final String role;
  const UserCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.coins,
    this.status = "",
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final AuthController authController = Get.find();
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
              color: email == authController.getCurrentUserEmail()
                  ? Colors.blueAccent
                  : Colors.redAccent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                role,
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
                    "$coins Coins",
                    style: Theme.of(context).textTheme.bodyMedium,
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
          top: -50,
          left: w / 2.6 / 2 - 50,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: email == authController.getCurrentUserEmail()
                    ? Colors.blue
                    : Colors.red,
                width: 5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
