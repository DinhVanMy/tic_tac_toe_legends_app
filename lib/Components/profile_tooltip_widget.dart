import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class ProfileTooltipCustom extends StatelessWidget {
  final UserModel friend;
  const ProfileTooltipCustom({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      width: 200,
      height: 150,
      child: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(friend.image!),
              radius: 30,
            ),
            const SizedBox(height: 5),
            Text(
              friend.name!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.deepPurple,
              ),
            ),
            Text(friend.email!),
            const Divider(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Total Wins: ${friend.totalWins ?? "0"}"),
                Text("Total Coins: ${friend.totalCoins ?? "0"}"),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text("Tier"),
                const Spacer(flex: 3),
                Image.asset(
                  TrimRanking.diamondTrim,
                  width: 40,
                ),
                const Spacer(flex: 1),
                const Text("Master 1"),
              ],
            ),
            const SizedBox(height: 5),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text("Recently"),
                  const SizedBox(
                    width: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      ChampionsPathA.aatrox,
                      width: 40,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      ChampionsPathA.ahri,
                      width: 40,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      ChampionsPathA.akali,
                      width: 40,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.blueGrey,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.info,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.circle_notifications,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.flag,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.message_outlined,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person_add_alt,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
