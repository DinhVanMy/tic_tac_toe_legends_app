import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class InGameUserCard extends StatelessWidget {
  final String icon;
  final String name;
  final String imageUrl;
  final Color color;
  const InGameUserCard(
      {super.key,
      required this.icon,
      required this.name,
      required this.imageUrl,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: w / 2.6,
          height: 160,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color,
                width: 5,
              )),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      icon,
                      width: 30,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.secondary,
                          BlendMode.srcIn),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: -50,
          left: w / 2.6 / 2 - 50,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: color,
                width: 5,
              ),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
