// ────────────────────────────────────────────────────────────────────────────
// Main navigation shell — bottom nav bar + swipeable PageView + persistent mini player
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../screens/home/home_screen.dart';
import '../screens/frequent/frequent_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/playlists/playlists_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/mini_player.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final PageController _pageController;

  static const _screens = [
    HomeScreen(),
    FrequentScreen(),
    LibraryScreen(),
    PlaylistsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onNavTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neuBase,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player above nav bar
          const MiniPlayer(),
          // Navigation bar
          Container(
            decoration: BoxDecoration(
              color: neuBase,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA3B1C6).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 4,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onNavTapped,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              iconSize: 26,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.trending_up_outlined),
                  activeIcon: Icon(Icons.trending_up),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_outlined),
                  activeIcon: Icon(Icons.library_music),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.playlist_play_outlined),
                  activeIcon: Icon(Icons.playlist_play),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
