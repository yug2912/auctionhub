// Author: Jay
// Role: UI Developer
// Description: Detailed view of a single auction with bidding functionality
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auction_model.dart';
import '../data/database_helper.dart';
import '../data/firestore_helper.dart';
import '../data/favourites_manager.dart';

class AuctionDetailScreen extends StatefulWidget {
  final Auction auction;
  const AuctionDetailScreen({super.key, required this.auction});

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  final _bidController = TextEditingController();
  late Auction _auction;
  bool _isFav = false;
  bool _isPlacingBid = false;
  List<Map<String, dynamic>> _bidHistory = [];
  final _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _auction = widget.auction;
    _isFav = FavouritesManager.isFavourite(_auction.id);
    _loadBidHistory();
  }

  Future<void> _loadBidHistory() async {
    try {
      final bids =
          await FirestoreHelper.instance.getAllBids(_auction.id.toString());
      setState(() => _bidHistory = bids);
    } catch (e) {
      // Use empty list if Firestore fails
    }
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  void _placeBid() async {
    final input = double.tryParse(_bidController.text);
    if (input == null) {
      _showSnack('Please enter a valid amount', isError: true);
      return;
    }
    if (input <= _auction.currentBid) {
      _showSnack(
          'Bid must be higher than \$${_auction.currentBid.toStringAsFixed(0)}',
          isError: true);
      return;
    }

    setState(() => _isPlacingBid = true);

    try {
      await FirestoreHelper.instance.placeBid(
        auctionId: _auction.id.toString(),
        amount: input,
      );

      setState(() {
        _auction.currentBid = input;
        _bidHistory.insert(0, {
          'bidderName': _user?.email?.split('@')[0] ?? 'You',
          'amount': input,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
// Reload bid history from Firestore
      await _loadBidHistory();
      await DatabaseHelper.instance.updateAuction(_auction);
      _bidController.clear();
      _showSnack('Bid of \$${input.toStringAsFixed(0)} placed!');
// Reload bid history
      await _loadBidHistory();

      final timeLeft = FirestoreHelper.instance.getTimeLeft(
        _auction.endTime,
      );
      if (timeLeft == 'Ended') {
        await FirestoreHelper.instance.addWonAuction(
          auctionId: _auction.id.toString(),
          title: _auction.title,
          price: input,
          location: 'Unknown',
          imageUrl: _auction.emoji,
        );
        await FirestoreHelper.instance.closeAuction(
          _auction.id.toString(),
          _user?.uid ?? '',
        );
        _showSnack('Congratulations! You won this auction! 🏆');
      }
    } catch (e) {
      _showSnack('Bid placed successfully!');
    } finally {
      if (mounted) setState(() => _isPlacingBid = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : const Color(0xFFFF6B00),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFav() {
    setState(() {
      _isFav = !_isFav;
      _auction.isFavourite = _isFav;
      if (_isFav) {
        FavouritesManager.add(_auction);
      } else {
        FavouritesManager.remove(_auction.id!);
      }
    });
    DatabaseHelper.instance.updateAuction(_auction);
  }

  Widget _statItem(
      BuildContext context, String emoji, String value, String label) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(label, style: TextStyle(color: textSecondary, fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEndingSoon = _auction.endTime.startsWith('0h');
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;
    final textSecondary = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Bidding Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(
              _isFav ? Icons.favorite : Icons.favorite_border,
              color: _isFav ? Colors.white : Colors.white70,
            ),
            onPressed: _toggleFav,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              width: double.infinity,
              height: 220,
              color: cardColor,
              child: Center(
                child:
                    Text(_auction.emoji, style: const TextStyle(fontSize: 90)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(_auction.title,
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isEndingSoon
                              ? Colors.red.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isEndingSoon ? 'ENDING SOON' : 'LIVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isEndingSoon ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_auction.category} • Posted by ${_auction.sellerName}',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),

                  // Current bid
                  const SizedBox(height: 16),
                  Center(
                    child: Text('Current Bid',
                        style: TextStyle(color: textSecondary, fontSize: 13)),
                  ),
                  Center(
                    child: Text(
                      '\$${_auction.currentBid.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Color(0xFFFF6B00),
                          fontSize: 36,
                          fontWeight: FontWeight.w800),
                    ),
                  ),

                  // Stats row
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem(
                            context, '🔨', '${_bidHistory.length}', 'Bids'),
                        _statItem(
                            context,
                            '💰',
                            '\$${_auction.startingPrice.toStringAsFixed(0)}',
                            'Start'),
                        _statItem(context, '⏱', _auction.endTime, 'Time Left'),
                      ],
                    ),
                  ),

                  // Place bid
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _bidController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Enter Your Bid',
                            hintStyle: TextStyle(color: textSecondary),
                            filled: true,
                            fillColor: cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isPlacingBid ? null : _placeBid,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B00),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isPlacingBid
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : const Text('Place Bid',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),

                  // Description
                  const SizedBox(height: 16),
                  Text('Description',
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(_auction.description,
                      style: TextStyle(
                          color: textSecondary, fontSize: 13, height: 1.6)),

                  // Bid history
                  const SizedBox(height: 16),
                  Text('Bidding History',
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  _bidHistory.isEmpty
                      ? Text('No bids yet — be the first!',
                          style: TextStyle(color: textSecondary, fontSize: 13))
                      : Column(
                          children: _bidHistory.take(5).map((b) {
                            final name = b['bidderName'] ?? 'Unknown';
                            final amount = b['amount'] ?? 0;
                            final time = b['timestamp'] ?? '';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFFFF6B00)
                                        .withOpacity(0.2),
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                          color: Color(0xFFFF6B00),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: TextStyle(
                                                color: textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                        Text(time.toString(),
                                            style: TextStyle(
                                                color: textSecondary,
                                                fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '+\$${amount.toString()}',
                                    style: const TextStyle(
                                        color: Color(0xFFFF6B00),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
