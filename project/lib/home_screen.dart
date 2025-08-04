// home_screen.dart
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
    BlocCounterScreen(key: PageStorageKey('BlocCounter')),
    WeatherScreen(key: PageStorageKey('Weather')),
    ImagePickerScreen(key: PageStorageKey('ImagePicker')),
    TaskCrudScreen(key: PageStorageKey('TaskCrud')),
    MoreScreen(key: PageStorageKey('More')),
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            inherit: true, // Safe for lerp
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
            ),
          ),
        ],
      ),
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => navProvider.updateIndex(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: isSelected ? 24 : 22,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: isSelected ? 11 : 10,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[600],
                              inherit: true, // 🔑 Critical for lerp safety
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
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
