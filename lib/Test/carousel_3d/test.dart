// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:tictactoe_gameapp/Test/rippleanimation/ripple_animation_widget.dart';
// import 'package:tictactoe_gameapp/Test/carousel_3d/test2.dart';

// class TesterWidget extends StatelessWidget {
//   const TesterWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: const SafeArea(
//         child: Center(
//             child: Stack(
//           children: [
//             SizedBox(
//                 height: 350,
//                 width: double.infinity,
//                 child: Carousel3DPage()),
//           ],
//         )),
//       ),
//     );
//   }
// }

// List<Widget> scrollListItems(BuildContext context) {
//   int i = 0;
//   List<Widget> items = [];
//   do {
//     i += 1;
//     items.add(
//       Container(
//         decoration: BoxDecoration(
//           color: Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
//               .withOpacity(1.0),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: const RipplesAnimationCustom(),
//       ),
//     );
//   } while (i <= 150);
//   return items;
// }
