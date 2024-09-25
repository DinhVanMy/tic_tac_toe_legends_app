import 'package:flutter/material.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.live_tv_rounded,
          color: Colors.red,
          size: 30,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.youtube_searched_for_outlined,
              color: Colors.blue,
              size: 30,
            ),
          ),
        ],
      ),
      
    );
  }
}
