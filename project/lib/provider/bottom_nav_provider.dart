import 'package:flutter/material.dart';

class BottomNavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void updateIndex(int newIndex) {
    if (newIndex != _currentIndex) {
      _currentIndex = newIndex;
      notifyListeners();
    }
  }
}
