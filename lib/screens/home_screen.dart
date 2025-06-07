import 'package:feels_mobile/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:feels_mobile/widgets/home_screen/drawer_item.dart';
import 'package:feels_mobile/widgets/app_card.dart';
import '../constants/colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/api_service.dart';
import './feed_screen.dart';
import 'friends_screen.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 1);

class HomeScreen extends ConsumerStatefulWidget {
  final int? initialIndex;

  const HomeScreen({super.key, this.initialIndex});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != null) {
      // Delay provider update until after build
      Future.microtask(() {
        ref.read(selectedIndexProvider.notifier).state = widget.initialIndex!;
      });
    }
  }

  final List<Widget> screens = [
    const FriendsScreen(),
    const FeedScreen(),
    const StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final indexNotifier = ref.read(selectedIndexProvider.notifier);
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        title: const Text(
          'Feels',
          style: TextStyle(color: AppColors.textLight),
        ),
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: AppColors.cardBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 15),
            AppCard(),
            DrawerItem(
              icon: Icons.person,
              title: 'My profile',
              onTap: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            DrawerItem(
              icon: Icons.person_add,
              title: 'Add friend',
              onTap: () {
                Navigator.of(context).pushNamed('/add_friend');
              },
            ),
            DrawerItem(
              icon: Icons.info,
              title: 'About',
              onTap: () {
                Navigator.of(context).pushNamed('/about');
              },
            ),
            DrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                ApiService.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.cardBackground,
        currentIndex: selectedIndex,
        onTap: (index) {
          indexNotifier.state = index;
        },
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Icon(Icons.people_alt_outlined),
            ),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Icon(Icons.access_time),
            ),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Icon(Icons.calendar_today),
            ),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
