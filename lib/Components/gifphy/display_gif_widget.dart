import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class DisplayGifWidget extends StatelessWidget {
  final String gifUrl;
  const DisplayGifWidget({super.key, required this.gifUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: GestureDetector(
        onTap: () {
          Get.dialog(
            Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(8),
                  minScale: 0.0005,
                  maxScale: 3,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(gifUrl),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().scale(duration: const Duration(milliseconds: 600)),
          );
        },
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: gifUrl,
              placeholder: (context, url) => Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.blueGrey,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
            )),
      ),
    );
  }
}
