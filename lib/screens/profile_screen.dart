import 'package:flutter/material.dart';
import '../main.dart';
import 'login_screen.dart';
import 'won_auctions_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDark = false;
  bool _notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF1A237E),
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 28),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white,
                        child: const Text(
                          'A',
                          style: TextStyle(
                            fontSize: 36,
                            color: Color(0xFF1A237E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Arsh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'arsh@email.com',
                    style: TextStyle(color: Color(0xFF9FA8DA), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _profileStat('12', 'Active Bids'),
                      _divider(),
                      _profileStat('3', 'Items Won'),
                      _divider(),
                      _profileStat('5', 'Listed'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Account'),
                  _settingsTile(
                    Icons.person_outline,
                    'Edit Profile',
                    onTap: () {},
                  ),
                  _settingsTile(Icons.history, 'Bid History', onTap: () {}),
                  _settingsTile(Icons.emoji_events, 'Won Auctions', onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WonAuctionsScreen()));
                  }),
                  _settingsTile(
                    Icons.favorite_outline,
                    'Saved Items',
                    onTap: () {},
                  ),
                  _settingsTile(
                    Icons.storefront_outlined,
                    'My Auctions',
                    onTap: () {},
                  ),

                  const SizedBox(height: 8),
                  _sectionTitle('Preferences'),

                  // Dark Mode Toggle
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EAF6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _isDark ? Icons.dark_mode : Icons.light_mode,
                          color: const Color(0xFF1A237E),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        _isDark ? 'Dark theme on' : 'Light theme on',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Switch(
                        value: _isDark,
                        onChanged: (val) {
                          setState(() => _isDark = val);
                          themeNotifier.value =
                              val ? ThemeMode.dark : ThemeMode.light;
                        },
                      ),
                    ),
                  ),

                  // Notifications Toggle
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EAF6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF1A237E),
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: const Text(
                        'Outbid & auction alerts',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Switch(
                        value: _notificationsOn,
                        onChanged: (val) =>
                            setState(() => _notificationsOn = val),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  _sectionTitle('Support'),
                  _settingsTile(
                    Icons.help_outline,
                    'Help & Support',
                    onTap: () {},
                  ),
                  _settingsTile(
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    onTap: () {},
                  ),
                  _settingsTile(Icons.info_outline, 'About', onTap: () {}),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (_) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9FA8DA), fontSize: 11),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(height: 32, width: 1, color: Colors.white24);
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _settingsTile(
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1A237E), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ),
    );
  }
}
