import 'package:flutter/material.dart';
import '../data/firestore_helper.dart';

class WonAuctionsScreen extends StatefulWidget {
  const WonAuctionsScreen({super.key});

  @override
  State<WonAuctionsScreen> createState() => _WonAuctionsScreenState();
}

class _WonAuctionsScreenState extends State<WonAuctionsScreen> {
  List<Map<String, dynamic>> _wonAuctions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWonAuctions();
  }

  Future<void> _loadWonAuctions() async {
    final data = await FirestoreHelper.instance.getWonAuctions();
    setState(() {
      _wonAuctions = data;
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Won Auctions',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : _wonAuctions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text('No won auctions yet',
                          style: TextStyle(
                              color: textSecondary,
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('Start bidding to win items!',
                          style:
                              TextStyle(color: textSecondary, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _wonAuctions.length,
                  itemBuilder: (_, i) {
                    final item = _wonAuctions[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  item['imageUrl'] ?? '🏆',
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] ?? 'Unknown Item',
                                    style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          size: 13, color: textSecondary),
                                      const SizedBox(width: 2),
                                      Text(
                                        item['location'] ?? 'Unknown',
                                        style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B00)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Won for \$${item['price']?.toStringAsFixed(0) ?? '0'}',
                                      style: const TextStyle(
                                          color: Color(0xFFFF6B00),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text('🏆', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
