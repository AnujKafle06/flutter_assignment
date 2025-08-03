import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home_screen.dart'; // ⬅️ import your home screen with nav
import 'auth_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If logged in → go to full app
        if (snapshot.hasData) {
          return HomeScreen(); // ✅ use HomeScreen with nav
        }

        // Else → show login
        return const AuthScreen();
      },
    );
  }
}
