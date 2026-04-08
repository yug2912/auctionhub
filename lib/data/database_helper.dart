import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/auction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

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

    // Insert sample data
    final samples = [
      Auction(title: 'Vintage Rolex Watch', category: 'Watches', description: 'A rare 1968 Rolex Submariner in excellent condition. Original box and papers included. Authenticated by certified experts. A collector\'s dream piece.', startingPrice: 800, currentBid: 1250, endTime: '2h 34m', sellerName: 'Jay', emoji: '⌚'),
      Auction(title: 'MacBook Pro 2023', category: 'Electronics', description: 'Barely used MacBook Pro M2 chip, 16GB RAM, 512GB SSD. Comes with original charger and box. Perfect for students and professionals.', startingPrice: 600, currentBid: 890, endTime: '0h 18m', sellerName: 'Arsh', emoji: '💻'),
      Auction(title: 'Antique Chair Set', category: 'Furniture', description: 'Set of 4 antique Victorian dining chairs. Solid mahogany wood with original upholstery. Excellent condition for their age.', startingPrice: 200, currentBid: 320, endTime: '5h 10m', sellerName: 'Shiv', emoji: '🪑'),
      Auction(title: 'Diamond Ring', category: 'Jewelry', description: '18K gold diamond engagement ring, 1.2 carat certified diamond, SI1 clarity, G color. Comes with GIA certificate.', startingPrice: 1500, currentBid: 2100, endTime: '12h 00m', sellerName: 'Yug', emoji: '💍'),
      Auction(title: 'iPhone 15 Pro', category: 'Electronics', description: 'iPhone 15 Pro 256GB in Natural Titanium. Unlocked, no scratches, includes original accessories and box.', startingPrice: 500, currentBid: 700, endTime: '1h 45m', sellerName: 'Jay', emoji: '📱'),
      Auction(title: 'Oil Painting 1920s', category: 'Art', description: 'Original oil on canvas landscape painting from the 1920s. Signed by a well-known Canadian artist. Professionally restored.', startingPrice: 300, currentBid: 450, endTime: '8h 02m', sellerName: 'Arsh', emoji: '🎨'),
    ];

    for (final a in samples) {
      await db.insert('auctions', a.toMap());
    }
  }

  Future<List<Auction>> getAllAuctions() async {
    final db = await database;
    final maps = await db.query('auctions');
    return maps.map((m) => Auction.fromMap(m)).toList();
  }

  Future<int> insertAuction(Auction auction) async {
    final db = await database;
    return db.insert('auctions', auction.toMap());
  }

  Future<int> updateAuction(Auction auction) async {
    final db = await database;
    return db.update('auctions', auction.toMap(), where: 'id = ?', whereArgs: [auction.id]);
  }

  Future<int> deleteAuction(int id) async {
    final db = await database;
    return db.delete('auctions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Auction>> getAuctionsByCategory(String category) async {
    final db = await database;
    final maps = await db.query('auctions', where: 'category = ?', whereArgs: [category]);
    return maps.map((m) => Auction.fromMap(m)).toList();
  }

  Future<List<Auction>> getFavourites() async {
    final db = await database;
    final maps = await db.query('auctions', where: 'isFavourite = ?', whereArgs: [1]);
    return maps.map((m) => Auction.fromMap(m)).toList();
  }
}
