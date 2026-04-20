// Author: Yug
// Role: Project Manager / Backend Developer
// Description: In-memory manager for tracking the user's favourite auctions
import '../models/auction_model.dart';

class FavouritesManager {
  static final List<Auction> _favourites = [];

  static List<Auction> get favourites => List.from(_favourites);

  static void add(Auction auction) {
    if (!_favourites.any((a) => a.id == auction.id)) {
      _favourites.add(auction);
    }
  }

  static void remove(int id) {
    _favourites.removeWhere((a) => a.id == id);
  }

  static bool isFavourite(int? id) {
    return _favourites.any((a) => a.id == id);
  }
}
