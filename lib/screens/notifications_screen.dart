import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, dynamic>> _notifications = const [
    {'icon': Icons.arrow_upward, 'color': Color(0xFFE53935), 'bg': Color(0xFFFFEBEE), 'title': 'You were outbid!', 'body': 'MacBook Pro 2023 — New bid: \$950. Tap to rebid.', 'time': '5 min ago', 'read': false},
    {'icon': Icons.emoji_events, 'color': Color(0xFF43A047), 'bg': Color(0xFFE8F5E9), 'title': 'You won the auction!', 'body': 'Congratulations! You won Sony Headphones.', 'time': '2h ago', 'read': false},
    {'icon': Icons.timer, 'color': Color(0xFFFF8F00), 'bg': Color(0xFFFFF8E1), 'title': 'Ending soon!', 'body': 'Vintage Rolex Watch has 30 minutes left.', 'time': '3h ago', 'read': true},
    {'icon': Icons.favorite, 'color': Color(0xFF8E24AA), 'bg': Color(0xFFF3E5F5), 'title': 'Watchlist update', 'body': 'iPhone 15 Pro now has 8 bids.', 'time': '5h ago', 'read': true},
    {'icon': Icons.arrow_upward, 'color': Color(0xFFE53935), 'bg': Color(0xFFFFEBEE), 'title': 'You were outbid!', 'body': 'Antique Chair Set — New bid: \$350.', 'time': 'Yesterday', 'read': true},
    {'icon': Icons.new_releases, 'color': Color(0xFF1E88E5), 'bg': Color(0xFFE3F2FD), 'title': 'New auction in Watches', 'body': 'A new item matching your interest was listed.', 'time': 'Yesterday', 'read': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark all read')),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (_, i) {
          final n = _notifications[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: n['bg'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 22),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(n['title'] as String,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: n['read'] == false ? FontWeight.w700 : FontWeight.w500)),
                  ),
                  if (n['read'] == false)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFF1A237E), shape: BoxShape.circle),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3),
                  Text(n['body'] as String,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(n['time'] as String,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
