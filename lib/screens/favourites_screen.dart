import 'package:flutter/material.dart';
import '../data/favourites_manager.dart';
import '../models/auction_model.dart';
import 'auction_detail_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final favourites = FavouritesManager.favourites;
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
            const Text('Favourites',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
          ],
        ),
      ),
      body: favourites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline, size: 70, color: textSecondary),
                  const SizedBox(height: 16),
                  Text('No favourites yet',
                      style: TextStyle(
                          color: textSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('Tap the heart on any auction to save it here',
                      style: TextStyle(color: textSecondary, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favourites.length,
              itemBuilder: (_, i) {
                final a = favourites[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AuctionDetailScreen(auction: a)),
                  ).then((_) => setState(() {})),
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
                                style: const TextStyle(fontSize: 40)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite,
                              color: Color(0xFFFF6B00)),
                          onPressed: () {
                            FavouritesManager.remove(a.id!);
                            setState(() {});
                          },
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
