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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Won Auctions',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _wonAuctions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🏆', style: TextStyle(fontSize: 50)),
                      SizedBox(height: 16),
                      Text('No won auctions yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Start bidding to win items!',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _wonAuctions.length,
                  itemBuilder: (_, i) {
                    final item = _wonAuctions[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Photo or emoji
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EAF6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child:
                                    Text('🏆', style: TextStyle(fontSize: 30)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] ?? 'Unknown Item',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 13, color: Colors.grey),
                                      const SizedBox(width: 2),
                                      Text(
                                        item['location'] ?? 'Unknown',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Won for \$${item['price']?.toStringAsFixed(0) ?? '0'}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E7D32)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
