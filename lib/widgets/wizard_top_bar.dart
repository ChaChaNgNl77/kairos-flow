import 'package:flutter/material.dart';

class WizardTopBar extends StatelessWidget {
  final double progress; // Value between 0.0 and 1.0 (e.g., 0.2 = 20%)
  final VoidCallback? onBack;
  final VoidCallback? onHome;

  const WizardTopBar({
    Key? key,
    required this.progress,
    this.onBack,
    this.onHome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top icon row (Back <---> Home)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: const Color(0xFF1F1F1F), // Dark Grey
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(), // Remove default padding
            ),
            IconButton(
              onPressed: onHome,
              icon: const Icon(Icons.home_outlined), // or home_rounded
              color: const Color(0xFF1F1F1F),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4), // Rounded corners
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8.0, // Set slightly thicker like the reference image
            backgroundColor: Colors.grey[200], // Background color (Light Grey)
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF2E4B28), // Brand color (Deep Matcha Green)
            ),
          ),
        ),
      ],
    );
  }
}
