import 'package:flutter/material.dart';

/// AETHERION Logo Widget
/// Displays the app logo from image asset
class AetherionLogo extends StatelessWidget {
  final double size;

  const AetherionLogo({
    super.key,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/Screenshot 2026-03-22 195949.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image not found
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.rocket_launch_outlined, size: 48),
            ),
          );
        },
      ),
    );
  }
}
