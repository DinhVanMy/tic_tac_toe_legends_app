import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Models/Functions/gradient_generator_functions.dart';

class LoopingImageCarousel extends StatefulWidget {
  const LoopingImageCarousel({super.key});

  @override
  _LoopingImageCarouselState createState() => _LoopingImageCarouselState();
}

class _LoopingImageCarouselState extends State<LoopingImageCarousel> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      double maxScrollExtent = _scrollController.position.maxScrollExtent;
      double singleItemWidth = MediaQuery.of(context).size.width * 0.8;

      if (_scrollController.offset >= maxScrollExtent) {
        _scrollController.jumpTo(0); // Reset về đầu khi đến cuối
        _currentIndex = 0;
      } else {
        _currentIndex++;
        _scrollController.animateTo(
          _currentIndex * singleItemWidth,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 200,
        width: MediaQuery.sizeOf(context).width,
        child: ListView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          children: GradientGeneratorFunctions.generateGradientContainers(
            length: 200, // Số lượng item trong danh sách
            isDarkMode: false,
          ),
        ),
      ),
    );
  }
}
