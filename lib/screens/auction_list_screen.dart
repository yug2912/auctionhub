import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/firestore_helper.dart';
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

  final List<String> _categories = [
    'All',
    'Electronics',
    'Jewelry',
    'Watches',
    'Furniture',
    'Art',
    'Cars',
    'Fashion'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _getEmoji(String category) {
    switch (category) {
      case 'Electronics':
        return '💻';
      case 'Jewelry':
        return '💍';
      case 'Watches':
        return '⌚';
      case 'Furniture':
        return '🪑';
      case 'Art':
        return '🎨';
      case 'Cars':
        return '🚗';
      case 'Fashion':
        return '👗';
      default:
        return '🏷️';
    }
  }

  Future<void> _load() async {
    try {
      final firestoreData = await FirestoreHelper.instance.getAllAuctions();
      if (firestoreData.isNotEmpty) {
        final auctionList = firestoreData.map((map) {
          String timeLeft = 'Active';
          try {
            final endTimeStr = map['endTime'] ?? '';
            if (endTimeStr.isNotEmpty && endTimeStr != '24 hours') {
              timeLeft = FirestoreHelper.instance.getTimeLeft(endTimeStr);
            }
          } catch (e) {
            timeLeft = 'Active';
          }
          return Auction(
            id: map['id'].toString().hashCode,
            title: map['title']?.toString() ?? 'Unknown',
            category: map['category']?.toString() ?? 'Other',
            description: map['description']?.toString() ?? '',
            startingPrice: (map['startingBid'] ?? 0).toDouble(),
            currentBid: (map['currentBid'] ?? 0).toDouble(),
            endTime: timeLeft,
            sellerName: map['sellerName']?.toString() ?? 'Unknown',
            emoji: _getEmoji(map['category']?.toString() ?? ''),
          );
        }).toList();
        setState(() {
          _all = auctionList;
          _filtered = auctionList;
          _loading = false;
        });
      } else {
        final data = await DatabaseHelper.instance.getAllAuctions();
        setState(() {
          _all = data;
          _filtered = data;
          _loading = false;
        });
      }
    } catch (e) {
      final data = await DatabaseHelper.instance.getAllAuctions();
      setState(() {
        _all = data;
        _filtered = data;
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filtered = _all.where((a) {
        final matchCat =
            _selectedCategory == 'All' || a.category == _selectedCategory;
        final matchSearch =
            a.title.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchCat && matchSearch;
      }).toList();
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
        title: const Text('All Auctions',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : Column(
              children: [
                // Search
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (v) {
                      _searchQuery = v;
                      _applyFilter();
                    },
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search auctions...',
                      hintStyle: TextStyle(color: textSecondary),
                      prefixIcon: Icon(Icons.search, color: textSecondary),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // Categories
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          _applyFilter();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF6B00)
                                : cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF6B00)
                                  : Colors.white24,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // List
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text('No auctions found',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 15)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final a = _filtered[i];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        AuctionDetailScreen(auction: a)),
                              ).then((_) => _load()),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(a.emoji,
                                            style:
                                                const TextStyle(fontSize: 36)),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(a.title,
                                                style: TextStyle(
                                                    color: textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14)),
                                            const SizedBox(height: 4),
                                            Text(a.category,
                                                style: TextStyle(
                                                    color: textSecondary,
                                                    fontSize: 11)),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Text(
                                                  '\$${a.currentBid.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                      color: Color(0xFFFF6B00),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 15),
                                                ),
                                                const SizedBox(width: 10),
                                                Icon(Icons.timer_outlined,
                                                    size: 12,
                                                    color: textSecondary),
                                                const SizedBox(width: 4),
                                                Text(a.endTime,
                                                    style: TextStyle(
                                                        color: textSecondary,
                                                        fontSize: 11)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: a.endTime == 'Ended'
                                            ? Colors.red.withOpacity(0.2)
                                            : Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        a.endTime == 'Ended' ? 'ENDED' : 'LIVE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: a.endTime == 'Ended'
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
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
