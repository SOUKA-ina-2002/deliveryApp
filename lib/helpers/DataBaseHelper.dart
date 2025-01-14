import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sales_points.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sales_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            address TEXT,
            contact_name TEXT,
            contact_phone TEXT,
            storage_capacity INTEGER,
            gps_coordinates TEXT
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getSalesPoints() async {
    final db = await database;
    return await db.query('sales_points');
  }


  Future<int> insertSalesPoint({
    required String name,
    required String address,
    required String contactName,
    required String contactPhone,
    required int storageCapacity,
    required String gpsCoordinates,
  }) async {
    final db = await database;
    return await db.insert('sales_points', {
      'name': name,
      'address': address,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'storage_capacity': storageCapacity,
      'gps_coordinates': gpsCoordinates,
    });
  }


  Future<int> updateSalesPoint({
    required int id,
    required String name,
    required String address,
    required String contactName,
    required String contactPhone,
    required int storageCapacity,
    required String gpsCoordinates,
  }) async {
    final db = await database;
    return await db.update(
      'sales_points',
      {
        'name': name,
        'address': address,
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'storage_capacity': storageCapacity,
        'gps_coordinates': gpsCoordinates,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSalesPoint(int id) async {
    final db = await database;
    return await db.delete('sales_points', where: 'id = ?', whereArgs: [id]);
  }
}
