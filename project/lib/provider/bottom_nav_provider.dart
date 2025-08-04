// bottom_navigation_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'navigation_tab.dart';

class BottomNavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  bool _isAnimating = false;

  final List<int> _navigationHistory = [0];

  // For handling re-tap actions (e.g., scroll to top)
  final Map<int, VoidCallback> onTabRevisited = {};

  // Dynamic badge control
  bool _showMoreBadge = false;
  bool get showMoreBadge => _showMoreBadge;

  set showMoreBadge(bool value) {
    _showMoreBadge = value;
    notifyListeners();
  }

  // Getters
  int get currentIndex => _currentIndex;
  bool get isAnimating => _isAnimating;
  NavigationTab get currentTab => NavigationTab.values[_currentIndex];
  String get currentTitle => currentTab.title;
  List<int> get navigationHistory => List.unmodifiable(_navigationHistory);

  bool isLoggedIn() => FirebaseAuth.instance.currentUser != null;

  bool canAccessTab(NavigationTab tab) {
    // Example: Tasks tab requires login
    if (tab == NavigationTab.tasks) return isLoggedIn();
    return true;
  }

  void _setAnimating(bool animating) {
    if (_isAnimating != animating) {
      _isAnimating = animating;
      notifyListeners();
    }
  }

  Future<bool> handleTabDoubleTap(int index) async {
    if (index == _currentIndex) {
      if (_navigationHistory.length > 1) {
        goBack();
        return true;
      }
    }
    return false;
  }

  void updateIndex(int newIndex) async {
    if (newIndex == _currentIndex) return;

    final tab = getTabByIndex(newIndex);
    if (!canAccessTab(tab)) {
      _showLoginRequired();
      return;
    }

    HapticFeedback.selectionClick(); // Subtle feedback

    _setAnimating(true);
    final oldIndex = _currentIndex;
    _currentIndex = newIndex;

    _updateNavigationHistory(newIndex);

    notifyListeners();

    // Simulate animation delay
    await Future.delayed(const Duration(milliseconds: 300));
    _setAnimating(false);

    debugPrint('Navigation: $oldIndex → $newIndex (${tab.title})');
  }

  void _updateNavigationHistory(int newIndex) {
    _navigationHistory.remove(newIndex);
    _navigationHistory.add(newIndex);

    if (_navigationHistory.length > 5) {
      _navigationHistory.removeAt(0);
    }
  }

  void goBack() {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      final previousIndex = _navigationHistory.last;
      _currentIndex = previousIndex;
      notifyListeners();
      debugPrint('Navigated back to index: $previousIndex');
    }
  }

  bool canGoBack() => _navigationHistory.length > 1;

  void resetToHome() {
    updateIndex(0);
  }

  NavigationTab getTabByIndex(int index) {
    return NavigationTab.values.firstWhere(
      (tab) => tab.index == index,
      orElse: () => NavigationTab.bloc,
    );
  }

  bool isTabActive(int index) => _currentIndex == index;

  void registerRevisitAction(int index, VoidCallback action) {
    onTabRevisited[index] = action;
  }

  void triggerRevisit(int index) {
    onTabRevisited[index]?.call();
  }

  Future<void> _showLoginRequired() async {
    // Could use dialog, snackbar, or navigate
    debugPrint("Login required to access this tab.");
  }

  @override
  void dispose() {
    _navigationHistory.clear();
    onTabRevisited.clear();
    super.dispose();
  }
}
