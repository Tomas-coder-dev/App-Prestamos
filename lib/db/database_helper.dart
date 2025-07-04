import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contacto.dart';
import '../models/prestamo.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('prestamos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contactos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        telefono TEXT,
        email TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE prestamos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contactoId INTEGER NOT NULL,
        monto REAL NOT NULL,
        pagado INTEGER NOT NULL,
        nota TEXT,
        FOREIGN KEY (contactoId) REFERENCES contactos(id)
      )
    ''');
  }

  // CRUD Contacto
  Future<int> insertContacto(Contacto contacto) async {
    final db = await instance.database;
    return await db.insert('contactos', contacto.toMap());
  }

  Future<Contacto?> getContacto(int id) async {
    final db = await instance.database;
    final maps = await db.query('contactos', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Contacto.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Contacto>> getContactos() async {
    final db = await instance.database;
    final maps = await db.query('contactos', orderBy: 'nombre ASC');
    return maps.map((e) => Contacto.fromMap(e)).toList();
  }

  Future<int> updateContacto(Contacto contacto) async {
    final db = await instance.database;
    return await db.update(
      'contactos',
      contacto.toMap(),
      where: 'id = ?',
      whereArgs: [contacto.id],
    );
  }

  Future<int> deleteContacto(int id) async {
    final db = await instance.database;
    await db.delete('prestamos', where: 'contactoId = ?', whereArgs: [id]);
    return await db.delete('contactos', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Prestamo
  Future<int> insertPrestamo(Prestamo prestamo) async {
    final db = await instance.database;
    return await db.insert('prestamos', prestamo.toMap());
  }

  Future<Prestamo?> getPrestamo(int id) async {
    final db = await instance.database;
    final maps = await db.query('prestamos', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Prestamo.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Prestamo>> getPrestamos({int? contactoId}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps;
    if (contactoId != null) {
      maps = await db.query(
        'prestamos',
        where: 'contactoId = ?',
        whereArgs: [contactoId],
        orderBy: 'id DESC',
      );
    } else {
      maps = await db.query('prestamos', orderBy: 'id DESC');
    }
    return maps.map((e) => Prestamo.fromMap(e)).toList();
  }

  Future<int> updatePrestamo(Prestamo prestamo) async {
    final db = await instance.database;
    return await db.update(
      'prestamos',
      prestamo.toMap(),
      where: 'id = ?',
      whereArgs: [prestamo.id],
    );
  }

  Future<int> deletePrestamo(int id) async {
    final db = await instance.database;
    return await db.delete('prestamos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = DatabaseHelper._database;
    if (db != null) {
      await db.close();
      DatabaseHelper._database = null;
    }
  }
}
