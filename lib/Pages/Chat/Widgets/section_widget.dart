import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Pages/Chat/Widgets/option_card.dart';

class SectionWidget extends StatelessWidget {
  final List<OptionCard> options;

  const SectionWidget({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: options
              .map((option) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: option,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}