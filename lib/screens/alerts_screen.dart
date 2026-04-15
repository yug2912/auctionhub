import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<Map<String, dynamic>> _alerts = [
    {
      'icon': Icons.check_circle,
      'color': Colors.green,
      'title': 'Auction Posted!',
      'body': 'Your item has been successfully listed on AuctionHub.',
      'time': 'Just now',
      'read': false,
    },
    {
      'icon': Icons.emoji_events,
      'color': Color(0xFFFF6B00),
      'title': 'You Won an Auction!',
      'body': 'Congratulations! You are the highest bidder.',
      'time': '2h ago',
      'read': false,
    },
    {
      'icon': Icons.arrow_upward,
      'color': Colors.red,
      'title': 'You were outbid!',
      'body': 'Someone placed a higher bid. Bid again to win!',
      'time': '3h ago',
      'read': true,
    },
    {
      'icon': Icons.timer,
      'color': Colors.orange,
      'title': 'Auction Ending Soon!',
      'body': 'An auction you are watching ends in 30 minutes.',
      'time': '5h ago',
      'read': true,
    },
    {
      'icon': Icons.celebration,
      'color': Colors.purple,
      'title': 'Welcome to AuctionHub!',
      'body': 'Start bidding or selling your items today.',
      'time': 'Yesterday',
      'read': true,
    },
  ];

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
            const Text('Alerts',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var a in _alerts) {
                  a['read'] = true;
                }
              });
            },
            child: const Text('Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      body: _alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 70, color: textSecondary),
                  const SizedBox(height: 16),
                  Text('No alerts yet',
                      style: TextStyle(
                          color: textSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _alerts.length,
              itemBuilder: (_, i) {
                final alert = _alerts[i];
                final isRead = alert['read'] as bool;
                return GestureDetector(
                  onTap: () {
                    setState(() => _alerts[i]['read'] = true);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isRead
                          ? cardColor
                          : cardColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isRead
                            ? Colors.transparent
                            : const Color(0xFFFF6B00).withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (alert['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          alert['icon'] as IconData,
                          color: alert['color'] as Color,
                          size: 22,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert['title'] as String,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 13,
                                fontWeight:
                                    isRead ? FontWeight.w400 : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6B00),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            alert['body'] as String,
                            style: TextStyle(
                                color: textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert['time'] as String,
                            style: TextStyle(
                                color: textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
