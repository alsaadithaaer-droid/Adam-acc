import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'adam.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            barcode TEXT,
            unit TEXT NOT NULL DEFAULT 'piece',
            cartonSize REAL NOT NULL DEFAULT 1,
            qty REAL NOT NULL DEFAULT 0,
            costUsd REAL NOT NULL DEFAULT 0,
            priceUsd REAL NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE customers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT,
            balanceUsd REAL NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE suppliers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT,
            balanceUsd REAL NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amountUsd REAL NOT NULL,
            note TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE invoices(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            customerId INTEGER,
            supplierId INTEGER,
            currency TEXT NOT NULL DEFAULT 'USD',
            exchangeRate REAL NOT NULL DEFAULT 1,
            total REAL NOT NULL DEFAULT 0,
            profitUsd REAL NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE invoice_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoiceId INTEGER NOT NULL,
            productId INTEGER NOT NULL,
            qty REAL NOT NULL,
            unitPrice REAL NOT NULL,
            unitCost REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE settings(
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
        await db.insert('settings', {'key':'exchange_rate','value':'10000'});
        await db.insert('settings', {'key':'store_name','value':'Adam'});
      },
    );
    return _db!;
  }

  static Future<List<Map<String, dynamic>>> products() async =>
      (await db).query('products', orderBy: 'id DESC');

  static Future<List<Map<String, dynamic>>> customers() async =>
      (await db).query('customers', orderBy: 'id DESC');

  static Future<List<Map<String, dynamic>>> suppliers() async =>
      (await db).query('suppliers', orderBy: 'id DESC');

  static Future<List<Map<String, dynamic>>> expenses() async =>
      (await db).query('expenses', orderBy: 'id DESC');

  static Future<int> addProduct(Map<String, dynamic> row) async =>
      (await db).insert('products', row);

  static Future<int> addCustomer(Map<String, dynamic> row) async =>
      (await db).insert('customers', row);

  static Future<int> addSupplier(Map<String, dynamic> row) async =>
      (await db).insert('suppliers', row);

  static Future<int> addExpense(Map<String, dynamic> row) async =>
      (await db).insert('expenses', row);

  static Future<Map<String, dynamic>> dashboard() async {
    final d = await db;
    final p = Sqflite.firstIntValue(await d.rawQuery('SELECT COUNT(*) FROM products')) ?? 0;
    final c = Sqflite.firstIntValue(await d.rawQuery('SELECT COUNT(*) FROM customers')) ?? 0;
    final s = Sqflite.firstIntValue(await d.rawQuery('SELECT COUNT(*) FROM suppliers')) ?? 0;
    final e = (await d.rawQuery('SELECT COALESCE(SUM(amountUsd),0) v FROM expenses')).first['v'] ?? 0;
    return {'products': p, 'customers': c, 'suppliers': s, 'expenses': e};
  }
}
