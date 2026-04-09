class Auction {
  final int? id;
  final String title;
  final String category;
  final String description;
  final double startingPrice;
  double currentBid;
  final String endTime;
  final String sellerName;
  final String emoji;
  bool isFavourite;

  Auction({
    this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.startingPrice,
    required this.currentBid,
    required this.endTime,
    required this.sellerName,
    required this.emoji,
    this.isFavourite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'startingPrice': startingPrice,
      'currentBid': currentBid,
      'endTime': endTime,
      'sellerName': sellerName,
      'emoji': emoji,
      'isFavourite': isFavourite ? 1 : 0,
    };
  }

  factory Auction.fromMap(Map<String, dynamic> map) {
    return Auction(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      description: map['description'],
      startingPrice: map['startingPrice'],
      currentBid: map['currentBid'],
      endTime: map['endTime'],
      sellerName: map['sellerName'],
      emoji: map['emoji'],
      isFavourite: map['isFavourite'] == 1,
    );
  }
}

class BidHistory {
  final String bidderName;
  final double amount;
  final String timeAgo;
  final String initial;

  BidHistory({
    required this.bidderName,
    required this.amount,
    required this.timeAgo,
    required this.initial,
  });
}
