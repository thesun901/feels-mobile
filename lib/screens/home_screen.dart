import 'package:flutter/material.dart';
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

  final List<Widget> screens = const [
    FriendsScreen(),
    FeedScreen(),
    Center(child: Text('Profile Screen')),
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
            Container(
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
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.textLight),
              title: const Text(
                'My profile',
                style: TextStyle(color: AppColors.textLight),
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: AppColors.textLight),
              title: const Text(
                'Add friend',
                style: TextStyle(color: AppColors.textLight),
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/add_friend');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.textLight),
              title: const Text(
                'Settings',
                style: TextStyle(color: AppColors.textLight),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.textLight),
              title: const Text(
                'About',
                style: TextStyle(color: AppColors.textLight),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.textLight),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.textLight),
              ),
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
