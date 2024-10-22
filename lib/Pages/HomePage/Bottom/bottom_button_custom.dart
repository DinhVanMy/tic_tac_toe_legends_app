import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomButtonCustom extends StatelessWidget {
  final Function() onPressed;
  final ThemeData theme;
  final String icon;
  const BottomButtonCustom(
      {super.key,
      required this.onPressed,
      required this.theme,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              spreadRadius: 2.0,
              color: Colors.white,
              blurRadius: 15.0,
              offset: Offset(5, 5),
            ),
            BoxShadow(
              spreadRadius: 2.0,
              color: Colors.white,
              blurRadius: 15.0,
              offset: Offset(-5, -5),
            ),
          ],
        ),
        child: SvgPicture.asset(
          icon,
          width: 40,
        ),
      ),
    );
  }
}
