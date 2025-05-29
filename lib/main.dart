import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'screens/feed_screen.dart';
import 'constants/colors.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feels',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.darkBackground,
        cardColor: AppColors.cardBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cardBackground,
          foregroundColor: AppColors.textLight,
          elevation: 0,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.textLight,
          displayColor: AppColors.textLight,
        ),
      ),
      home: const FeedScreen(),
    );
  }
}
