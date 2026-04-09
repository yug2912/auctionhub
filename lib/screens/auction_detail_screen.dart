import 'package:flutter/material.dart';
import '../models/auction_model.dart';
import '../data/database_helper.dart';

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

  final List<BidHistory> _history = [
    BidHistory(bidderName: 'Arsh', amount: 0, timeAgo: '2 min ago', initial: 'A'),
    BidHistory(bidderName: 'Jay', amount: 0, timeAgo: '15 min ago', initial: 'J'),
    BidHistory(bidderName: 'Shiv', amount: 0, timeAgo: '1h ago', initial: 'S'),
  ];

  @override
  void initState() {
    super.initState();
    _auction = widget.auction;
    _isFav = _auction.isFavourite;

    // Set bid history amounts relative to current bid
    _history[0] = BidHistory(bidderName: 'Arsh', amount: _auction.currentBid, timeAgo: '2 min ago', initial: 'A');
    _history[1] = BidHistory(bidderName: 'Jay', amount: _auction.currentBid - 150, timeAgo: '15 min ago', initial: 'J');
    _history[2] = BidHistory(bidderName: 'Shiv', amount: _auction.currentBid - 300, timeAgo: '1h ago', initial: 'S');
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  void _placeBid() {
    final input = double.tryParse(_bidController.text);
    final minBid = _auction.currentBid + 50;

    if (input == null) {
      _showSnack('Please enter a valid amount', isError: true);
      return;
    }
    if (input <= _auction.currentBid) {
      _showSnack('Bid must be higher than \$${_auction.currentBid.toStringAsFixed(0)}', isError: true);
      return;
    }

    setState(() {
      _history.insert(0, BidHistory(
        bidderName: 'You',
        amount: input,
        timeAgo: 'Just now',
        initial: 'Y',
      ));
      _auction.currentBid = input;
    });

    DatabaseHelper.instance.updateAuction(_auction);
    _bidController.clear();
    _showSnack('Bid of \$${input.toStringAsFixed(0)} placed successfully!');
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFav() async {
    setState(() {
      _isFav = !_isFav;
      _auction.isFavourite = _isFav;
    });
    await DatabaseHelper.instance.updateAuction(_auction);
  }

  @override
  Widget build(BuildContext context) {
    final isEndingSoon = _auction.endTime.startsWith('0h');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border,
                    color: _isFav ? Colors.red : null),
                onPressed: _toggleFav,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isEndingSoon ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD),
                child: Center(
                  child: Text(_auction.emoji,
                      style: const TextStyle(fontSize: 80)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(_auction.title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isEndingSoon
                              ? const Color(0xFFFFF3E0)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isEndingSoon ? 'ENDING SOON' : 'LIVE',
                          style: TextStyle(
                            fontSize: 11,
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
                  Text('${_auction.category} • Posted by ${_auction.sellerName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),

                  // Bid info box
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Current Bid',
                                  style: TextStyle(
                                      fontSize: 11, color: Color(0xFFE65100))),
                              const SizedBox(height: 4),
                              Text('\$${_auction.currentBid.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A237E))),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Time Left',
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFFE65100))),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.timer,
                                    size: 18, color: Color(0xFFE65100)),
                                const SizedBox(width: 4),
                                Text(_auction.endTime,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFE65100))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Description
                  const SizedBox(height: 14),
                  const Text('Description',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(_auction.description,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey, height: 1.6)),

                  // Bid History
                  const SizedBox(height: 16),
                  const Text('Bid History',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ..._history.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFFE8EAF6),
                              child: Text(b.initial,
                                  style: const TextStyle(
                                      color: Color(0xFF1A237E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.bidderName,
                                      style: const TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w500)),
                                  Text(b.timeAgo,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text('\$${b.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A237E))),
                          ],
                        ),
                      )),

                  // Place Bid
                  const SizedBox(height: 16),
                  const Text('Place Your Bid',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    'Minimum bid: \$${(_auction.currentBid + 50).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bidController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter bid amount',
                      prefixText: '\$ ',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _placeBid,
                      icon: const Icon(Icons.gavel),
                      label: const Text('Place Bid',
                          style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
