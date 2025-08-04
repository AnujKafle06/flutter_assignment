// bottom_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:project/provider/bottom_nav_provider.dart';
import 'package:provider/provider.dart';

import 'navigation_tab.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int initialIndex;
  const CustomBottomNavigationBar({super.key, this.initialIndex = 0});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _lastTapTime = 0;

  @override
  void initState() {
    super.initState();
    final provider = context.read<BottomNavigationProvider>();
    provider.updateIndex(widget.initialIndex);
  }

  void _onItemTapped(int index) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final isDoubleTap = now - _lastTapTime < 300;
    _lastTapTime = now;

    final provider = context.read<BottomNavigationProvider>();

    // Handle double tap to go back
    if (isDoubleTap && index == provider.currentIndex) {
      if (await provider.handleTabDoubleTap(index)) return;
    }

    provider.updateIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BottomNavigationProvider>();
    final currentIndex = provider.currentIndex;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: _onItemTapped,
      elevation: 8,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: NavigationTab.values.map((tab) {
        final isActive = tab.index == currentIndex;
        final icon = Icon(
          isActive ? tab.activeIcon : tab.icon,
          color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey,
        );

        // Add badge if needed
        Widget tabIcon = icon;
        if (tab == NavigationTab.more && provider.showMoreBadge) {
          tabIcon = Badge(smallSize: 6, child: icon);
        }

        return BottomNavigationBarItem(
          icon: tabIcon,
          activeIcon: Icon(
            tab.activeIcon,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: tab.title,
        );
      }).toList(),
    );
  }
}
