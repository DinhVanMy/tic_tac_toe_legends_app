import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';

class RoomInfo extends StatelessWidget {
  final String roomCode;
  const RoomInfo({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final AuthController auth = Get.find<AuthController>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                // const Row(
                //   children: [
                //     Text("Generated Room Code"),
                //   ],
                // ),
                // const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      height: 70,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            roomCode,
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontSize: w / 14,
                              letterSpacing: 2.4,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () async {
                        
                        final result = await Share.share(
                            "${auth.getCurrentUserEmail()} invited you play roomCode: $roomCode");
                        if (result.status == ShareResultStatus.success) {
                          successMessage("Your enemy has recieved roomCode");
                        } else {
                          errorMessage("Your enemy has not recieved roomCode");
                        }
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(13),
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Icon(
                          Icons.ios_share_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Share This Private code with your Friends & Ask Theme To Join The Game",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
