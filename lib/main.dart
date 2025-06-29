import 'package:feels_mobile/screens/add_status_screen.dart';
import 'package:feels_mobile/screens/archive_screen.dart';
import 'package:feels_mobile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_friend_screen.dart';
import 'screens/about_screen.dart';
import 'services/api_service.dart';
import 'constants/colors.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _checkAuth() async {
    final loggedIn = await ApiService.isLoggedIn();
    return loggedIn ? const HomeScreen() : const LoginScreen();
  }

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
        popupMenuTheme: ThemeData().popupMenuTheme.copyWith(
          color: AppColors.darkBackground,
        ),
      ),
      routes: {
        '/friends': (context) => const HomeScreen(initialIndex: 0),
        '/feed': (context) => const HomeScreen(initialIndex: 1),
        '/stats': (context) => const HomeScreen(initialIndex: 2),
        '/add_friend': (context) => AddFriendScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/add_status': (context) => const AddStatusScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/about': (context) => const AboutScreen(),
        '/archive': (context) => const ArchiveScreen(),
      },
      home: FutureBuilder<Widget>(
        future: _checkAuth(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
