// Author: Yug
// Role: Project Manager / Backend Developer
// Description: User profile screen with account info and sign-out functionality
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'login_screen.dart';
import 'won_auctions_screen.dart';
import 'my_auctions_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDark = themeNotifier.value == ThemeMode.dark;
  bool _notificationsOn = true;
  final User? _user = FirebaseAuth.instance.currentUser;
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    if (_user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();
    if (doc.exists) {
      setState(() {
        _displayName =
            doc.data()?['name'] ?? _user!.email?.split('@')[0] ?? 'User';
      });
    } else {
      setState(() {
        _displayName = _user!.email?.split('@')[0] ?? 'User';
      });
    }
  }

  void _editProfile() {
    final controller = TextEditingController(text: _displayName);
    final cardColor = Theme.of(context).cardColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Edit Profile', style: TextStyle(color: textPrimary)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: textSecondary),
            filled: true,
            fillColor: bgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFF6B00)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFFF6B00), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(_user!.uid)
                  .update({'name': newName});
              setState(() => _displayName = newName);
              if (mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Name updated successfully!'),
                  backgroundColor: Color(0xFFFF6B00),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/logo.png', width: 32, height: 32),
            const SizedBox(width: 8),
            const Text('Profile',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              color: cardColor,
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFFFF6B00),
                        child: Text(
                          _displayName.isNotEmpty
                              ? _displayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _editProfile,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B00),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _displayName,
                    style: TextStyle(
                        color: textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? '',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context, 'Account'),
                  _tile(context, Icons.person_outline, 'Edit Profile',
                      onTap: _editProfile),
                  _tile(context, Icons.emoji_events_outlined, 'Won Auctions',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WonAuctionsScreen()))),
                  _tile(context, Icons.storefront_outlined, 'My Auctions',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyAuctionsScreen()))),

                  const SizedBox(height: 8),
                  _sectionTitle(context, 'Preferences'),

                  // Dark mode toggle
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B00).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _isDark ? Icons.dark_mode : Icons.light_mode,
                          color: const Color(0xFFFF6B00),
                          size: 20,
                        ),
                      ),
                      title: Text('Dark Mode',
                          style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          _isDark ? 'Dark theme on' : 'Light theme on',
                          style: TextStyle(
                              color: textSecondary, fontSize: 12)),
                      trailing: Switch(
                        value: _isDark,
                        activeColor: const Color(0xFFFF6B00),
                        onChanged: (val) {
                          setState(() => _isDark = val);
                          themeNotifier.value =
                              val ? ThemeMode.dark : ThemeMode.light;
                        },
                      ),
                    ),
                  ),

                  // Notifications toggle
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B00).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: Color(0xFFFF6B00), size: 20),
                      ),
                      title: Text('Notifications',
                          style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      subtitle: Text('Bid and auction alerts',
                          style:
                              TextStyle(color: textSecondary, fontSize: 12)),
                      trailing: Switch(
                        value: _notificationsOn,
                        activeColor: const Color(0xFFFF6B00),
                        onChanged: (val) =>
                            setState(() => _notificationsOn = val),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign out
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (_) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Sign Out',
                          style: TextStyle(color: Colors.red, fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color)),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title,
      {required VoidCallback onTap}) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B00).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFFF6B00), size: 20),
        ),
        title: Text(title,
            style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right, color: textSecondary, size: 20),
      ),
    );
  }
}
