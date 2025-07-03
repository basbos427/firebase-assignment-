import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InventoryItem {
  int? id;
  String name;
  int quantity;
  String category;

  InventoryItem(this.name, this.quantity, this.category, {this.id});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
    };
  }

  static InventoryItem fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      map['name'],
      map['quantity'],
      map['category'],
      id: map['id'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inventory.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            quantity INTEGER,
            category TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE users (
            username TEXT PRIMARY KEY,
            password TEXT
          )
        ''');
      },
    );
  }

  // --- User methods ---
  Future<bool> insertUser(String username, String password) async {
    final dbClient = await db;
    try {
      await dbClient.insert('users', {
        'username': username,
        'password': password,
      });
      return true;
    } catch (e) {
      return false; // username already exists
    }
  }

  Future<bool> userExists(String username) async {
    final dbClient = await db;
    final res = await dbClient.query('users', where: 'username = ?', whereArgs: [username]);
    return res.isNotEmpty;
  }

  Future<bool> validateUser(String username, String password) async {
    final dbClient = await db;
    final res = await dbClient.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    return res.isNotEmpty;
  }

  // --- Inventory methods ---
  Future<List<InventoryItem>> getItems() async {
    final dbClient = await db;
    final maps = await dbClient.query('items');
    return maps.map((e) => InventoryItem.fromMap(e)).toList();
  }

  Future<int> insertItem(InventoryItem item) async {
    final dbClient = await db;
    return await dbClient.insert('items', item.toMap());
  }

  Future<int> updateItem(InventoryItem item) async {
    final dbClient = await db;
    return await dbClient.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inventory.db');
    await deleteDatabase(path);
  }
} 