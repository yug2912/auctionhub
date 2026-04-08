import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/auction_model.dart';
import 'auction_detail_screen.dart';

class AuctionListScreen extends StatefulWidget {
  const AuctionListScreen({super.key});

  @override
  State<AuctionListScreen> createState() => _AuctionListScreenState();
}

class _AuctionListScreenState extends State<AuctionListScreen> {
  List<Auction> _all = [];
  List<Auction> _filtered = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _loading = true;

  final List<String> _categories = ['All', 'Electronics', 'Jewelry', 'Watches', 'Furniture', 'Art', 'Sports'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAllAuctions();
    setState(() {
      _all = data;
      _filtered = data;
      _loading = false;
    });
  }

  void _applyFilter() {
    setState(() {
      _filtered = _all.where((a) {
        final matchCat = _selectedCategory == 'All' || a.category == _selectedCategory;
        final matchSearch = a.title.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchCat && matchSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Auctions', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: false,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    onChanged: (v) {
                      _searchQuery = v;
                      _applyFilter();
                    },
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
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final selected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) {
                            _selectedCategory = cat;
                            _applyFilter();
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🔍', style: TextStyle(fontSize: 40)),
                              SizedBox(height: 12),
                              Text('No auctions found',
                                  style: TextStyle(color: Colors.grey, fontSize: 15)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final a = _filtered[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AuctionDetailScreen(auction: a)),
                                ).then((_) => _load()),
                                leading: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8EAF6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(a.emoji,
                                        style: const TextStyle(fontSize: 26)),
                                  ),
                                ),
                                title: Text(a.title,
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(a.category,
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '\$${a.currentBid.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1A237E)),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.timer_outlined,
                                            size: 12, color: Color(0xFFE65100)),
                                        const SizedBox(width: 2),
                                        Text(a.endTime,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFFE65100))),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: a.endTime.startsWith('0h')
                                        ? const Color(0xFFFFF3E0)
                                        : const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    a.endTime.startsWith('0h') ? 'ENDING' : 'LIVE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: a.endTime.startsWith('0h')
                                          ? const Color(0xFFE65100)
                                          : const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
