import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EndOfCallLay extends StatelessWidget {
  final String url;
  const EndOfCallLay({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 30),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
                radius: 50,
              ),
              const Spacer(
                flex: 1,
              ),
              const Column(
                children: [
                  Text(
                    "Call ended",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "0 : 13",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(
                flex: 2,
              ),
              const Text(
                "How was the quality of your call?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const Spacer(
                flex: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(100),
                        splashColor: Colors.blueAccent,
                        child: Ink(
                          padding: const EdgeInsets.all(5.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey,
                          ),
                          child: const Icon(
                            Icons.thumb_up_alt_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        "Good",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(100),
                        splashColor: Colors.redAccent,
                        child: Ink(
                          padding: const EdgeInsets.all(5.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey,
                          ),
                          child: const Icon(
                            Icons.thumb_down_alt_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        "Bad",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(
                flex: 2,
              ),
              const Column(
                children: [
                  Text(
                    "We may use your data for personalization, innovation, research and other purposes described in our",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.cancel,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
      ],
    );
  }
}
