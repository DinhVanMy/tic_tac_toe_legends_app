import 'package:flutter/material.dart';

class JajasTopIconWidget extends StatelessWidget {
  final String icon;
  final String name;
  final Function() onTap;
  const JajasTopIconWidget({
    super.key,
    required this.onTap,
    required this.icon,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Image.asset(
            icon,
            width: 50,
            fit: BoxFit.cover,
          ),
        ),
        Text(
          name,
          style: const TextStyle(
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
}
