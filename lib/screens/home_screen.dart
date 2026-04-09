import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/auction_model.dart';
import 'auction_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Auction> _auctions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAuctions();
  }

  Future<void> _loadAuctions() async {
    final data = await DatabaseHelper.instance.getAllAuctions();
    setState(() {
      _auctions = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFF1A237E),
                    padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Welcome back,',
                                    style: TextStyle(color: Color(0xFF9FA8DA), fontSize: 13)),
                                Text('Arsh 👋',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Text('A',
                                  style: TextStyle(
                                      color: const Color(0xFF1A237E),
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _statCard('${_auctions.length}', 'Live Auctions'),
                            const SizedBox(width: 10),
                            _statCard('3', 'Items Won'),
                            const SizedBox(width: 10),
                            _statCard('5', 'Watchlist'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Search
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search auctions...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                // Categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Categories',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['All', 'Electronics', 'Jewelry', 'Watches', 'Furniture', 'Art', 'Sports']
                                .map((c) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterChip(
                                        label: Text(c),
                                        selected: c == 'All',
                                        onSelected: (_) {},
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Featured Title
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Text('Featured Auctions',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),

                // Auction Cards
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _AuctionCard(
                        auction: _auctions[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AuctionDetailScreen(auction: _auctions[i])),
                        ).then((_) => _loadAuctions()),
                      ),
                      childCount: _auctions.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Color(0xFF9FA8DA), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _AuctionCard extends StatelessWidget {
  final Auction auction;
  final VoidCallback onTap;

  const _AuctionCard({required this.auction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEndingSoon = auction.endTime.startsWith('0h');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: isEndingSoon
                    ? const Color(0xFFFCE4EC)
                    : const Color(0xFFE3F2FD),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Text(auction.emoji, style: const TextStyle(fontSize: 50)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(auction.title,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isEndingSoon
                              ? const Color(0xFFFFF3E0)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isEndingSoon ? 'ENDING' : 'LIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isEndingSoon
                                ? const Color(0xFFE65100)
                                : const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(auction.category,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Bid',
                              style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text('\$${auction.currentBid.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A237E))),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 14, color: Color(0xFFE65100)),
                          const SizedBox(width: 4),
                          Text(auction.endTime,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFE65100),
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
