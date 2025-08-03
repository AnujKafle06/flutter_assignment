// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc_counter/bloc_counter_screen.dart';
import 'fire_base_auth/firestore_crud_screen.dart';
import 'image_picker_screen.dart';
import 'more_screen.dart';
import 'provider/bottom_nav_provider.dart';
import 'provider/theme_provider.dart';
import 'weather/weather_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Widget> _screens = const [
    BlocCounterScreen(),
    WeatherScreen(),
    ImagePickerScreen(),
    TaskCrudScreen(),
    MoreScreen(),
  ];

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'BLoC',
      title: 'BLoC Counter',
    ),
    NavigationItem(
      icon: Icons.cloud_outlined,
      activeIcon: Icons.cloud,
      label: 'Weather',
      title: 'Weather App',
    ),
    NavigationItem(
      icon: Icons.image_outlined,
      activeIcon: Icons.image,
      label: 'Picker',
      title: 'Image Picker',
    ),
    NavigationItem(
      icon: Icons.task_outlined,
      activeIcon: Icons.task,
      label: 'Tasks',
      title: 'My Tasks',
    ),
    NavigationItem(
      icon: Icons.more_horiz_outlined,
      activeIcon: Icons.more_horiz,
      label: 'More',
      title: 'More',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final navProvider = Provider.of<BottomNavigationProvider>(context);
    final currentIndex = navProvider.currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _navigationItems[currentIndex].title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(themeProvider.isDarkMode),
              ),
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey(currentIndex),
          child: _screens[currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: navProvider.updateIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: _navigationItems.map((item) {
            final isSelected = _navigationItems.indexOf(item) == currentIndex;
            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isSelected ? item.activeIcon : item.icon, size: 24),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String title;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.title,
  });
}
