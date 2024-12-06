import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Components/customized_widgets/slide_to_confirm_widget.dart';

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Slider Example')),
      body: CallSlider(
        onAccept: () {
          print('Call Accepted');
        },
        onDecline: () {
          print('Call Declined');
        },
      ),
    );
  }
}
