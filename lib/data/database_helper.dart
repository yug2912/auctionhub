// Author: Yug
// Role: Project Manager / Backend Developer
// Description: SQLite local database helper for offline auction data storage
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/auction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static final List<Auction> _webAuctions = [];
  static int _webIdCounter = 1;
  static bool _webInitialized = false;

  DatabaseHelper._init();

  static List<Auction> get _sampleData => [
    Auction(
      id: 1,
      title: 'Vintage Rolex Watch',
      category: 'Watches',
      description:
          'A rare 1968 Rolex Submariner in excellent condition. Original box and papers included. Authenticated by certified experts.',
      startingPrice: 800,
      currentBid: 1250,
      endTime: '2h 34m',
      sellerName: 'Jay',
      emoji: '⌚',
    ),
    Auction(
      id: 2,
      title: 'MacBook Pro 2023',
      category: 'Electronics',
      description:
          'Barely used MacBook Pro M2 chip, 16GB RAM, 512GB SSD. Comes with original charger and box. Perfect for students.',
      startingPrice: 600,
      currentBid: 890,
      endTime: '0h 18m',
      sellerName: 'Arsh',
      emoji: '💻',
    ),
    Auction(
      id: 3,
      title: 'Antique Chair Set',
      category: 'Furniture',
      description:
          'Set of 4 antique Victorian dining chairs. Solid mahogany wood with original upholstery. Excellent condition.',
      startingPrice: 200,
      currentBid: 320,
      endTime: '5h 10m',
      sellerName: 'Shiv',
      emoji: '🪑',
    ),
    Auction(
      id: 4,
      title: 'Diamond Ring',
      category: 'Jewelry',
      description:
          '18K gold diamond engagement ring, 1.2 carat certified diamond, SI1 clarity. Comes with GIA certificate.',
      startingPrice: 1500,
      currentBid: 2100,
      endTime: '12h 00m',
      sellerName: 'Yug',
      emoji: '💍',
    ),
    Auction(
      id: 5,
      title: 'iPhone 15 Pro',
      category: 'Electronics',
      description:
          'iPhone 15 Pro 256GB in Natural Titanium. Unlocked, no scratches, includes original accessories.',
      startingPrice: 500,
      currentBid: 700,
      endTime: '1h 45m',
      sellerName: 'Jay',
      emoji: '📱',
    ),
    Auction(
      id: 6,
      title: 'Oil Painting 1920s',
      category: 'Art',
      description:
          'Original oil on canvas landscape painting from the 1920s. Signed by a Canadian artist. Professionally restored.',
      startingPrice: 300,
      currentBid: 450,
      endTime: '8h 02m',
      sellerName: 'Arsh',
      emoji: '🎨',
    ),
  ];

  void _initWebData() {
    if (!_webInitialized) {
      _webAuctions.addAll(_sampleData);
      _webIdCounter = _sampleData.length + 1;
      _webInitialized = true;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('auction_hub.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE auctions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        startingPrice REAL NOT NULL,
        currentBid REAL NOT NULL,
        endTime TEXT NOT NULL,
        sellerName TEXT NOT NULL,
        emoji TEXT NOT NULL,
        isFavourite INTEGER NOT NULL DEFAULT 0
      )
    ''');
    for (final a in _sampleData) {
      await db.insert('auctions', a.toMap());
    }
  }

  Future<List<Auction>> getAllAuctions() async {
    if (kIsWeb) {
      _initWebData();
      return List.from(_webAuctions);
    }
    final db = await database;
    final maps = await db.query('auctions');
    return maps.map((m) => Auction.fromMap(m)).toList();
  }

  Future<int> insertAuction(Auction auction) async {
    if (kIsWeb) {
      _initWebData();
      final a = Auction(
        id: _webIdCounter++,
        title: auction.title,
        category: auction.category,
        description: auction.description,
        startingPrice: auction.startingPrice,
        currentBid: auction.currentBid,
        endTime: auction.endTime,
        sellerName: auction.sellerName,
        emoji: auction.emoji,
      );
      _webAuctions.add(a);
      return a.id!;
    }
    final db = await database;
    return db.insert('auctions', auction.toMap());
  }

  Future<int> updateAuction(Auction auction) async {
    if (kIsWeb) {
      _initWebData();
      final i = _webAuctions.indexWhere((a) => a.id == auction.id);
      if (i != -1) {
        _webAuctions[i] = auction;
        return 1;
      }
      return 0;
    }
    final db = await database;
    return db.update(
      'auctions',
      auction.toMap(),
      where: 'id = ?',
      whereArgs: [auction.id],
    );
  }

  Future<int> deleteAuction(int id) async {
    if (kIsWeb) {
      _initWebData();
      final before = _webAuctions.length;
      _webAuctions.removeWhere((a) => a.id == id);
      return before - _webAuctions.length;
    }
    final db = await database;
    return db.delete('auctions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Auction>> getAuctionsByCategory(String category) async {
    if (kIsWeb) {
      _initWebData();
      return _webAuctions.where((a) => a.category == category).toList();
    }
    final db = await database;
    final maps = await db.query(
      'auctions',
      where: 'category = ?',
      whereArgs: [category],
    );
    return maps.map((m) => Auction.fromMap(m)).toList();
  }

  Future<List<Auction>> getFavourites() async {
    if (kIsWeb) {
      _initWebData();
      return _webAuctions.where((a) => a.isFavourite).toList();
    }
    final db = await database;
    final maps = await db.query(
      'auctions',
      where: 'isFavourite = ?',
      whereArgs: [1],
    );
    return maps.map((m) => Auction.fromMap(m)).toList();
  }
}
