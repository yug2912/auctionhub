// Author: Yug
// Role: Project Manager / Backend Developer
// Description: Helper class for all Firestore database read/write operations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  static final FirestoreHelper instance = FirestoreHelper._init();
  FirestoreHelper._init();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── AUCTIONS ───────────────────────────────────────

  // Save new auction to Firestore
  Future<String> addAuction({
    required String title,
    required String description,
    required String category,
    required double startingBid,
    required double priceIncrement,
    required String location,
    required String duration,
    String imageUrl = 'none',
  }) async {
    final user = _auth.currentUser;

    // Calculate exact end time based on duration chosen
    DateTime endDateTime;
    switch (duration) {
      case '1 hour':
        endDateTime = DateTime.now().add(const Duration(hours: 1));
        break;
      case '6 hours':
        endDateTime = DateTime.now().add(const Duration(hours: 6));
        break;
      case '12 hours':
        endDateTime = DateTime.now().add(const Duration(hours: 12));
        break;
      case '24 hours':
        endDateTime = DateTime.now().add(const Duration(hours: 24));
        break;
      case '3 days':
        endDateTime = DateTime.now().add(const Duration(days: 3));
        break;
      case '7 days':
        endDateTime = DateTime.now().add(const Duration(days: 7));
        break;
      default:
        endDateTime = DateTime.now().add(const Duration(hours: 24));
    }

    final doc = _db.collection('auctions').doc();
    await doc.set({
      'id': doc.id,
      'title': title,
      'description': description,
      'category': category,
      'startingBid': startingBid,
      'currentBid': startingBid,
      'priceIncrement': priceIncrement,
      'location': location,
      'duration': duration,
      'endTime': endDateTime.toIso8601String(),
      'imageUrl': imageUrl,
      'sellerId': user?.uid ?? 'unknown',
      'sellerName': user?.displayName ?? user?.email ?? 'Unknown',
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
    });
    return doc.id;
  }

  // Get all active auctions
  Future<List<Map<String, dynamic>>> getAllAuctions() async {
    final snapshot = await _db
        .collection('auctions')
        .where('status', isEqualTo: 'active')
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  // Update current bid
  Future<void> updateBid(String auctionId, double newBid) async {
    await _db.collection('auctions').doc(auctionId).update({
      'currentBid': newBid,
    });
  }

  // Mark auction as won
  Future<void> closeAuction(String auctionId, String winnerId) async {
    await _db.collection('auctions').doc(auctionId).update({
      'status': 'closed',
      'winnerId': winnerId,
    });
  }

  // ─── BIDS ───────────────────────────────────────────

  // Save a bid
  Future<void> placeBid({
    required String auctionId,
    required double amount,
  }) async {
    final user = _auth.currentUser;

    // Save bid to bids collection
    final doc = _db.collection('bids').doc();
    await doc.set({
      'id': doc.id,
      'auctionId': auctionId,
      'bidderId': user?.uid ?? 'unknown',
      'bidderName':
          user?.displayName ?? user?.email?.split('@')[0] ?? 'Unknown',
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Update currentBid in ALL auctions that match
    final auctionQuery = await _db
        .collection('auctions')
        .where('id', isEqualTo: auctionId)
        .get();

    if (auctionQuery.docs.isNotEmpty) {
      await auctionQuery.docs.first.reference.update({
        'currentBid': amount,
      });
    }
  }

  // Get top 3 bids for an auction
  Future<List<Map<String, dynamic>>> getTop3Bids(String auctionId) async {
    final snapshot = await _db
        .collection('bids')
        .where('auctionId', isEqualTo: auctionId)
        .orderBy('amount', descending: true)
        .limit(3)
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  // Get all bids for an auction
  Future<List<Map<String, dynamic>>> getAllBids(String auctionId) async {
    try {
      final snapshot = await _db
          .collection('bids')
          .where('auctionId', isEqualTo: auctionId)
          .get();
      final bids = snapshot.docs.map((d) => d.data()).toList();
      bids.sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));
      return bids;
    } catch (e) {
      return [];
    }
  }

  // ─── USERS ──────────────────────────────────────────

  // Save user when they register
  Future<void> saveUser(String name, String email) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
      'wonAuctions': [],
    });
  }

  // Add won auction to user profile
  Future<void> addWonAuction({
    required String auctionId,
    required String title,
    required double price,
    required String location,
    required String imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).update({
      'wonAuctions': FieldValue.arrayUnion([
        {
          'auctionId': auctionId,
          'title': title,
          'price': price,
          'location': location,
          'imageUrl': imageUrl,
          'wonAt': DateTime.now().toIso8601String(),
        }
      ]),
    });
  }

  // Get current user's won auctions
  Future<List<Map<String, dynamic>>> getWonAuctions() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return [];
    final data = doc.data();
    final won = data?['wonAuctions'] as List<dynamic>? ?? [];
    return won.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Calculate time left for frontend to display
  String getTimeLeft(String endTimeStr) {
    final endTime = DateTime.parse(endTimeStr);
    final now = DateTime.now();
    final diff = endTime.difference(now);

    if (diff.isNegative) return 'Ended';
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h left';
    if (diff.inHours > 0)
      return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m left';
    return 'Ending soon';
  }

  // Get total number of bids for an auction
  Future<int> getTotalBids(String auctionId) async {
    final snapshot = await _db
        .collection('bids')
        .where('auctionId', isEqualTo: auctionId)
        .get();
    return snapshot.docs.length;
  }
}
