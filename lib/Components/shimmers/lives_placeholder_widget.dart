import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LivesPlaceholderWidget extends StatelessWidget {
  const LivesPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _liveStreamsLoadingPlaceholder();
  }

  Widget _liveStreamsLoadingPlaceholder() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
      ),
      itemCount: 8, // Số lượng placeholder
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Thumbnail
              Container(
                width: double.infinity,
                height: 120,
                color: Colors.red[200],
              ),
              // Thông tin streamer và tiêu đề
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red[200],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 14,
                            color: Colors.red[200],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 60,
                            height: 12,
                            color: Colors.red[200],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 100,
                    height: 15,
                    color: Colors.red[200],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
                    height: 12,
                    color: Colors.red[200],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 50,
                      height: 10,
                      color: Colors.red[200],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shimmer(
              delay: 200.ms,
              duration: 1000.ms,
              colors: [
                Colors.red[200]!,
                Colors.yellow[200]!,
                Colors.green[200]!,
                Colors.blue[200]!,
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
              size: 2.0,
            );
      },
    );
  }
}
