import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Components/customized_widgets/slide_to_confirm_widget.dart';

class GameInviteRequestDialog extends StatelessWidget {
  final UserModel friend;
  final Function() onPressedAccept;
  final Function() onPressedRefuse;
  const GameInviteRequestDialog({
    super.key,
    required this.friend,
    required this.onPressedAccept,
    required this.onPressedRefuse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 400,
      alignment: Alignment.center,
      // padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const Text(
                "Invite",
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 20,
                ),
              ),
              const Divider(
                color: Colors.white,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(friend.image!),
                    radius: 30,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Column(
                    children: [
                      Text(
                        friend.name!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.purple,
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            TrimRanking.diamondTrim,
                            width: 25,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            "Master 1",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.blue, width: 1), // Viền trên
                    bottom:
                        BorderSide(color: Colors.blue, width: 1), // Viền dưới
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent, // Màu mờ ở trái
                        Colors.black, // Màu rõ ở giữa
                        Colors.transparent, // Màu mờ ở phải
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode:
                      BlendMode.dstIn, // Kết hợp shader với nội dung container
                  child: Container(
                    width: double.infinity,
                    height: 90,
                    color: Colors.blueAccent.withOpacity(0.5),
                    child: const SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            'Invited you to join room',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            'Ranked , 1 Vs 1',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Text(
                            'roomId: ',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          Text(
                            'I hear you\'re strong! Want to team up?',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onPressedRefuse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      fixedSize: const Size(120, 30),
                    ),
                    child: const Text(
                      'Refuse',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      fixedSize: const Size(120, 30),
                    ),
                    child: const Text(
                      'Waiting',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onPressedAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      fixedSize: const Size(120, 30),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
          Positioned(
            top: -10,
            right: -10,
            child: IconButton(
              onPressed: onPressedRefuse,
              icon: const Icon(
                Icons.cancel_outlined,
                size: 40,
                color: Colors.yellowAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CallInviteRequestDialog extends StatelessWidget {
  final UserModel friend;
  final Function() onPressedAccept;
  final Function() onPressedRefuse;
  final bool isvideocall;
  const CallInviteRequestDialog(
      {super.key,
      required this.friend,
      required this.onPressedAccept,
      required this.onPressedRefuse,
      required this.isvideocall});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: 400,
      alignment: Alignment.center,
      // padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Column(
        children: [
          const Text(
            "Calling...",
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(
            color: Colors.white,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(friend.image!),
                radius: 30,
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                children: [
                  Text(
                    friend.name!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.purple,
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        TrimRanking.diamondTrim,
                        width: 25,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text(
                        "Master 1",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.blue, width: 1), // Viền trên
                bottom: BorderSide(color: Colors.blue, width: 1), // Viền dưới
              ),
            ),
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent, // Màu mờ ở trái
                    Colors.black, // Màu rõ ở giữa
                    Colors.transparent, // Màu mờ ở phải
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              blendMode:
                  BlendMode.dstIn, // Kết hợp shader với nội dung container
              child: Container(
                width: double.infinity,
                height: 90,
                color: Colors.blueAccent.withOpacity(0.5),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Text(
                            isvideocall
                                ? 'You have a video call'
                                : 'You have a voice call',
                            style: const TextStyle(
                              color: Colors.lightGreenAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            isvideocall ? Icons.video_call : Icons.call_end,
                            size: 50,
                            color: Colors.greenAccent,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          CallSlider(
            onAccept: onPressedAccept,
            onDecline: onPressedRefuse,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
