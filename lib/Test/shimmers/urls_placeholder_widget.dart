import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UrlsPlaceholderWidget extends StatelessWidget {
  const UrlsPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _videosLoadingPlaceholder();
  }

  Widget _videosLoadingPlaceholder() {
    return ListView.builder(
      itemCount: 10, // Số lượng placeholder
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 100,
                  height: 80,
                  color: Colors.orange[200],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 16,
                      color: Colors.orange[200],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 200,
                      height: 12,
                      color: Colors.orange[200],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 180,
                      height: 12,
                      color: Colors.orange[200],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shimmer(
              delay: 500.ms,
              duration: 1500.ms,
              colors: [Colors.orange[200]!, Colors.orange[50]!],
              size: 1.5,
            );
      },
    );
  }
}
