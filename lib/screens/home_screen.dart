import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/firestore_helper.dart';
import '../data/favourites_manager.dart';
import '../models/auction_model.dart';
import 'auction_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Auction> _auctions = [];
  List<Auction> _filtered = [];
  bool _loading = true;
  String _searchQuery = '';
  String _selectedCategory = '';
  Set<int> _favouriteIds = {};

  final List<String> _categories = [
    'All',
    'Cars',
    'Furniture',
    'Jewelry',
    'Art',
    'Watches',
    'Electronics'
  ];

  @override
  void initState() {
    super.initState();
    _loadAuctions();
  }

  Future<void> _loadAuctions() async {
    try {
      final firestoreData = await FirestoreHelper.instance.getAllAuctions();

      if (firestoreData.isNotEmpty) {
        final auctionList = firestoreData.map((map) {
          String endTimeStr = map['endTime'] ?? '';
          String timeLeft = 'Active';
          try {
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
          _auctions = auctionList;
          _filtered = auctionList;
          _loading = false;
        });
      } else {
        final data = await DatabaseHelper.instance.getAllAuctions();
        setState(() {
          _auctions = data;
          _filtered = data;
          _loading = false;
        });
      }
    } catch (e) {
      final data = await DatabaseHelper.instance.getAllAuctions();
      setState(() {
        _auctions = data;
        _filtered = data;
        _loading = false;
      });
    }
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

  void _search(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category == 'All' ? '' : category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filtered = _auctions.where((a) {
      final matchSearch = _searchQuery.isEmpty ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory =
          _selectedCategory.isEmpty || a.category == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList();
  }

  void _toggleFavourite(Auction auction) {
    setState(() {
      if (_favouriteIds.contains(auction.id)) {
        _favouriteIds.remove(auction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favourites'),
            backgroundColor: Colors.grey,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _favouriteIds.add(auction.id!);
        FavouritesManager.add(auction);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to favourites!'),
            backgroundColor: Color(0xFFFF6B00),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/logo.png', width: 32, height: 32),
            const SizedBox(width: 8),
            const Text('Auction Hub',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: _search,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search Item......',
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

                // Category buttons
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final isSelected = cat == 'All'
                          ? _selectedCategory.isEmpty
                          : _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => _filterByCategory(cat),
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
                const SizedBox(height: 16),

                // Auction list
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text('No auctions found',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 15)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final a = _filtered[i];
                            final isFav = _favouriteIds.contains(a.id);
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        AuctionDetailScreen(auction: a)),
                              ).then((_) => _loadAuctions()),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
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
                                                const TextStyle(fontSize: 40)),
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
                                            Text(
                                              '\$${a.currentBid.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                  color: Color(0xFFFF6B00),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
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
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: IconButton(
                                        icon: Icon(
                                          isFav
                                              ? Icons.favorite
                                              : Icons.favorite_outline,
                                          color: isFav
                                              ? const Color(0xFFFF6B00)
                                              : textSecondary,
                                        ),
                                        onPressed: () => _toggleFavourite(a),
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
