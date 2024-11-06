import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_edit_model.dart';

class PostEditSheet extends StatelessWidget {
  final ScrollController scrollController;
  const PostEditSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
        itemCount: PostEditModel.listPostEditModels.length,
        itemBuilder: (context, index) {
          var option = PostEditModel.listPostEditModels[index];
          return Material(
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(
                      option.icon,
                      size: 35,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            option.description,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.blueGrey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
