// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:math';

// import 'package:tictactoe_gameapp/Configs/constants.dart';

// class Carousel3DPage extends StatelessWidget {
//   const Carousel3DPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: RotatedBox(
//       quarterTurns: 1,
//       child: ListWheelScrollView.useDelegate(
//         controller:
//             FixedExtentScrollController(), // Thay đổi thành FixedExtentScrollController
//         physics: const FixedExtentScrollPhysics(),
//         diameterRatio: 1.7,
//         itemExtent: 300,
//         perspective: 0.04,
//         childDelegate: ListWheelChildBuilderDelegate(
//           childCount: images.length,
//           builder: (context, index) {
//             return RotatedBox(
//               quarterTurns: -1,
//               child: Container(
//                 margin: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 30,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.transparent,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.transparent,
//                       offset: Offset(0, 4),
//                       blurRadius: 10,
//                     ),
//                   ],
//                 ),
//                 child: Image.asset(images[index]),
//               ),
//             );
//           },
//         ),
//       ),
//     ));
//   }
// }
