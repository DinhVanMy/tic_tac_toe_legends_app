import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Widgets/looping_carousel_widget.dart';
import 'package:tictactoe_gameapp/Test/animated_carousel/stream_scale_carousel.dart';
import 'package:tictactoe_gameapp/Test/animated_carousel/test3.dart';

class TestTestX2 extends StatelessWidget {
  const TestTestX2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              LoopingImageCarousel(),
              StreamScaleCarousel(),
            ],
          ),
        ),
      ),
    );
  }
}
