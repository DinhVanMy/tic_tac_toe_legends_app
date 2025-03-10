import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';

class PrimaryIconWithButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;
  final Color color;
  final String iconPath;
  final double? width;
  final double? height;
  final bool isLogo;
  const PrimaryIconWithButton(
      {super.key,
      this.width,
      this.height = 70.0,
      required this.buttonText,
      required this.onTap,
      required this.iconPath,
      required this.color,
      this.isLogo = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 2.0,
              spreadRadius: 0.0,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLogo
                ? Image.asset(
                    IconsPath.applogo,
                    width: 40,
                  )
                : SvgPicture.asset(
                    iconPath,
                    width: 40,
                  ),
            const SizedBox(
              width: 10,
            ),
            Text(
              buttonText,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
