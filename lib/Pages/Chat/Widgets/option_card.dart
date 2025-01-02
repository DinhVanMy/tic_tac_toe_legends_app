import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.29,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 5),
              Text(
                title,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: const Duration(seconds: 1)),
              const SizedBox(height: 5),
              Text(
                description,
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: Colors.blueGrey),
                textAlign: TextAlign.center,
                maxLines: 4,
              ).animate().fadeIn(duration: const Duration(seconds: 3)),
            ],
          ),
        ),
      ),
    );
  }
}
