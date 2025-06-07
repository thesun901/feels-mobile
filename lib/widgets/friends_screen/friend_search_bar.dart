import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class FriendsSearchBar extends StatelessWidget {
  const FriendsSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 400,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(color: AppColors.textLight),
          decoration: InputDecoration(
            hintText: 'Search friends...',
            hintStyle: const TextStyle(color: AppColors.textDim),
            prefixIcon: const Icon(Icons.search, color: AppColors.textDim),
            filled: true,
            fillColor: isFocused
                ? AppColors.cardBackground.withValues(alpha: 0.5)
                : AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
