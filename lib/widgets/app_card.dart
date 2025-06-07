import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class AppCard extends StatelessWidget {

  const AppCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Card(
        color: AppColors.cardBackground.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 64,
                width: 64,
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Feels',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 1.2,
                ),
              ),
              const Text(
                'Share your emotions',
                style: TextStyle(
                  color: AppColors.textDim,
                  fontSize: 14,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}