import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/firestore_helper.dart';

class MyAuctionsScreen extends StatefulWidget {
  const MyAuctionsScreen({super.key});

  @override
  State<MyAuctionsScreen> createState() => _MyAuctionsScreenState();
}

class _MyAuctionsScreenState extends State<MyAuctionsScreen> {
  List<Map<String, dynamic>> _myAuctions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMyAuctions();
  }

  Future<void> _loadMyAuctions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final all = await FirestoreHelper.instance.getAllAuctions();
    setState(() {
      _myAuctions = all.where((a) => a['sellerId'] == user.uid).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        title: const Text('My Auctions',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : _myAuctions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront_outlined,
                          size: 70, color: textSecondary),
                      const SizedBox(height: 16),
                      Text('No auctions listed yet',
                          style: TextStyle(
                              color: textSecondary,
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('Go to Sell tab to create an auction',
                          style:
                              TextStyle(color: textSecondary, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myAuctions.length,
                  itemBuilder: (_, i) {
                    final item = _myAuctions[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('🏷️', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                        title: Text(
                          item['title'] ?? 'Unknown',
                          style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Current Bid: \$${item['currentBid'] ?? 0}',
                              style: const TextStyle(
                                  color: Color(0xFFFF6B00),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['category'] ?? '',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item['status'] == 'active'
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['status'] == 'active' ? 'Active' : 'Closed',
                            style: TextStyle(
                              color: item['status'] == 'active'
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
