import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';

class LoopingCarousel extends StatefulWidget {
  const LoopingCarousel({super.key});

  @override
  _LoopingCarouselState createState() => _LoopingCarouselState();
}

class _LoopingCarouselState extends State<LoopingCarousel> {
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < imagePaths.length) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        // Reset vị trí ngầm về trang đầu khi đạt đến trang cuối cùng
        _currentPage = 0;
        _pageController.jumpToPage(_currentPage);
        _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).width,
      width: MediaQuery.sizeOf(context).width,
      child: PageView.builder(
        controller: _pageController,
        itemCount: imagePaths.length + 1, // Thêm một trang để tạo hiệu ứng vòng lặp
        onPageChanged: (index) {
          // Kiểm tra nếu đến trang sao chép ở cuối
          if (index == imagePaths.length) {
            Future.delayed(const Duration(milliseconds: 300), () {
              // Nhảy về trang đầu (trang thực sự) mà không có hiệu ứng
              _pageController.jumpToPage(0);
              _currentPage = 0;
            });
          } else {
            _currentPage = index;
          }
        },
        itemBuilder: (context, index) {
          final imageIndex = index % imagePaths.length; // Lấy ảnh theo index thực
          return Image.asset(imagePaths[imageIndex], fit: BoxFit.cover);
        },
      ),
    );
  }
}
