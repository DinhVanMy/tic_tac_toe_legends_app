import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';

class StreamScaleCarousel extends StatefulWidget {
  const StreamScaleCarousel({super.key});

  @override
  _LoopingImageCarouselState createState() => _LoopingImageCarouselState();
}

class _LoopingImageCarouselState extends State<StreamScaleCarousel> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  int _currentIndex = 0;

  final List<String> _imagePaths = [
    ImagePath.map1,
    ImagePath.map2,
    ImagePath.map10,
    ImagePath.map4,
    ImagePath.map5,
    ImagePath.map6,
  ];

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
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      double maxScrollExtent = _scrollController.position.maxScrollExtent;
      double singleItemWidth = MediaQuery.of(context).size.width * 0.8;

      if (_scrollController.offset >= maxScrollExtent) {
        _scrollController.jumpTo(0); // Reset về đầu khi đến cuối
        _currentIndex = 0;
      } else {
        _currentIndex++;
        _scrollController.animateTo(
          _currentIndex * singleItemWidth,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  double _calculateScale(int index) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemOffset =
        index * (screenWidth * 0.8 + 20); // 20 là khoảng cách giữa các item
    double centerOffset =
        _scrollController.offset + screenWidth / 2 - (screenWidth * 0.8) / 2;
    double distanceToCenter = (centerOffset - itemOffset).abs();

    // Điều chỉnh scale dựa trên khoảng cách đến trung tâm
    double scale = 1.0 - (distanceToCenter / screenWidth).clamp(0.0, 0.3);
    return scale;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // Chiều cao của carousel
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _imagePaths.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Transform.scale(
                scale: _calculateScale(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    _imagePaths[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
