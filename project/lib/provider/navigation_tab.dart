// navigation_tab.dart
import 'package:flutter/material.dart';

class NavigationTab {
  final int index;
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final bool showBadge; // Can be dynamic later

  const NavigationTab({
    required this.index,
    required this.title,
    required this.icon,
    required this.activeIcon,
    this.showBadge = false,
  });

  static const bloc = NavigationTab(
    index: 0,
    title: 'BLoC Counter',
    icon: Icons.analytics_outlined,
    activeIcon: Icons.analytics,
  );

  static const weather = NavigationTab(
    index: 1,
    title: 'Weather App',
    icon: Icons.cloud_outlined,
    activeIcon: Icons.cloud,
  );

  static const tasks = NavigationTab(
    index: 2,
    title: 'My Tasks',
    icon: Icons.task_outlined,
    activeIcon: Icons.task,
  );

  static const more = NavigationTab(
    index: 3,
    title: 'More',
    icon: Icons.more_horiz_outlined,
    activeIcon: Icons.more_horiz,
    showBadge: false, // Can be set dynamically
  );

  static const List<NavigationTab> values = [bloc, weather, tasks, more];
}
