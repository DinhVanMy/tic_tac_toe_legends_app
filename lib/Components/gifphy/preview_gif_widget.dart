import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:giphy_picker/giphy_picker.dart';

class PreviewGifWidget extends StatelessWidget {
  final Rx<GiphyGif?> selectedGif;
  const PreviewGifWidget({super.key, required this.selectedGif});

  @override
  Widget build(BuildContext context) {
    return Obx(() => selectedGif.value == null
        ? const SizedBox()
        : SizedBox(
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                selectedGif.value!.images.original!.url!,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                      child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                        alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.blueGrey,
                    ),
                  ));
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      "Error loading GIF",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            )));
  }
}
