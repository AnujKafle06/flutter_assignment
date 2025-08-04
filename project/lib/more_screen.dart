// more_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/provider/bottom_nav_provider.dart';
import 'package:provider/provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BottomNavigationProvider>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("More"),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Profile Header
            _buildUserHeader(context, user),

            const SizedBox(height: 20),

            // Main Menu Items
            _buildMenuSection(context, "Account", [
              _MenuItemData(
                icon: Icons.person_outline,
                title: "Profile",
                subtitle: "Manage your profile information",
                onTap: () => _navigateToProfile(context),
              ),
              _MenuItemData(
                icon: Icons.settings_outlined,
                title: "Settings",
                subtitle: "App preferences and configuration",
                onTap: () => _navigateToSettings(context),
              ),
              _MenuItemData(
                icon: Icons.security_outlined,
                title: "Privacy & Security",
                subtitle: "Manage your privacy settings",
                onTap: () => _navigateToPrivacy(context),
              ),
            ]),

            // App Settings
            _buildMenuSection(context, "App Settings", [
              _MenuItemData(
                icon: Icons.notifications_outlined,
                title: "Notifications",
                subtitle: "Manage notification preferences",
                onTap: () => _navigateToNotifications(context),
              ),
            ]),

            // Badge Toggle Card
            _buildBadgeToggleCard(context, provider),

            // Support Section
            _buildMenuSection(context, "Support", [
              _MenuItemData(
                icon: Icons.help_outline,
                title: "Help & FAQ",
                subtitle: "Get answers to common questions",
                onTap: () => _navigateToHelp(context),
              ),
              _MenuItemData(
                icon: Icons.feedback_outlined,
                title: "Send Feedback",
                subtitle: "Help us improve the app",
                onTap: () => _showEnhancedFeedbackDialog(context),
              ),
              _MenuItemData(
                icon: Icons.bug_report_outlined,
                title: "Report Issue",
                subtitle: "Report bugs or technical problems",
                onTap: () => _showReportIssueDialog(context),
              ),
            ]),

            // About Section
            _buildMenuSection(context, "About", [
              _MenuItemData(
                icon: Icons.info_outline,
                title: "About App",
                subtitle: "Version and app information",
                onTap: () => _showEnhancedAboutDialog(context),
              ),
              _MenuItemData(
                icon: Icons.gavel_outlined,
                title: "Terms & Privacy",
                subtitle: "Legal information and policies",
                onTap: () => _navigateToTerms(context),
              ),
            ]),

            const SizedBox(height: 20),

            // Logout Button
            _buildLogoutButton(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, User? user) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: user?.photoURL != null
                ? ClipOval(
                    child: Image.network(
                      user!.photoURL!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            user?.displayName ?? user?.email?.split('@').first ?? "User",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (user?.email != null)
            Text(
              user!.email!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<_MenuItemData> items,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return _buildMenuItem(context, entry.value, !isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    _MenuItemData item,
    bool showDivider,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: item.subtitle != null
              ? Text(
                  item.subtitle!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                )
              : null,
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            HapticFeedback.lightImpact();
            item.onTap();
          },
        ),
        if (showDivider)
          Divider(height: 1, indent: 60, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildBadgeToggleCard(
    BuildContext context,
    BottomNavigationProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile.adaptive(
        value: provider.showMoreBadge,
        onChanged: (v) {
          HapticFeedback.lightImpact();
          context.read<BottomNavigationProvider>().showMoreBadge = v;
        },
        title: const Text(
          "Show Badge on More Tab",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          "Display notification badge on the More tab",
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        icon: const Icon(Icons.logout),
        label: const Text("Sign Out"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red[200]!),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToPrivacy(BuildContext context) {
    Navigator.pushNamed(context, '/privacy');
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.pushNamed(context, '/notifications');
  }

  void _navigateToHelp(BuildContext context) {
    Navigator.pushNamed(context, '/help');
  }

  void _navigateToTerms(BuildContext context) {
    Navigator.pushNamed(context, '/terms');
  }

  // Dialog methods
  void _showEnhancedFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Send Feedback"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "We'd love to hear your thoughts! Your feedback helps us improve the app.",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                hintText: "Tell us what you think...",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Here you could send the feedback to your backend
              Navigator.pop(ctx);
              _showThankYouSnackBar(context, "Feedback sent successfully!");
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Report Issue"),
        content: const Text(
          "Please describe the issue you're experiencing and we'll look into it.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showThankYouSnackBar(context, "Issue reported successfully!");
            },
            child: const Text("Report"),
          ),
        ],
      ),
    );
  }

  void _showEnhancedAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "My Flutter App",
      applicationVersion: "1.0.0",
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.flutter_dash, color: Colors.white, size: 32),
      ),
      children: [
        const Text("Built with Flutter"),
        const Text("© 2024 Your Company Name"),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error signing out: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showThankYouSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
