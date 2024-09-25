import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../Configs/assets_path.dart';

class PriceArea extends StatelessWidget {
  final String entryPrice;
  final String winningPrice;
  const PriceArea({super.key, required this.entryPrice, required this.winningPrice});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: const Row(
                children: [
                  Text("Entry Price")
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context).colorScheme.primaryContainer
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context).colorScheme.primary
                  ),
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                children: [
                  SvgPicture.asset(IconsPath.coinIcon),
                  const SizedBox(width: 10,),
                  Text(entryPrice.toString())
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: const Row(
                children: [
                  Text("Winning Price")
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context).colorScheme.primaryContainer
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context).colorScheme.primary
                  ),
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                children: [
                  SvgPicture.asset(IconsPath.coinIcon),
                  const SizedBox(width: 10,),
                  Text(winningPrice.toString())
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}
