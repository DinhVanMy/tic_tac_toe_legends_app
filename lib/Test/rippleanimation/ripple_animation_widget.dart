import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Test/rippleanimation/circle_painter.dart';

class RipplesAnimationCustom extends StatefulWidget {

  const RipplesAnimationCustom({super.key});

  @override
  State<RipplesAnimationCustom> createState() => _RipplesAnimationCustomState();
}

class _RipplesAnimationCustomState extends State<RipplesAnimationCustom>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CustomPaint(
      painter: CirclePainter(_controller, colorValue: Colors.blue),
      child: SizedBox(
        width: size.width / 1.3,
        height: size.height / 1.3,
        child: const Center(
            child: Text(
          "Searching...",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        )),
      ),
    );
  }
}
