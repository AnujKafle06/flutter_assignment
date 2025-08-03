import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
        },
      ),
    );
  }
}
