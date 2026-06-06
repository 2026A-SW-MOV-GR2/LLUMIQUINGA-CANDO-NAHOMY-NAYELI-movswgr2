import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

import '../../models/product_model.dart';
import '../product_repository.dart';
import '../../../core/logging/app_logger.dart';

/// Implementación RELACIONAL usando SQLite via sqflite_common_ffi.
/// Compatible con Android, iOS, Windows, Linux y macOS.
/// Posición A: Relacional — esquema fijo con tablas y tipos definidos.
class SqliteProductRepository implements ProductRepository {
  static const String _tag = 'SQLiteRepo';
  static const String _tableName = 'products';
  static const int _dbVersion = 1;

  final String dbName;
  Database? _db;

  SqliteProductRepository({this.dbName = 'hybrid_crud.db'});

  @override
  String get engineName => 'SQLite';

  @override
  String get engineType => 'sql';

  @override
  Future<void> initialize() async {
    AppLogger.info(_tag, 'Inicializando SQLite...');
    try {
      final path = await _resolvePath();

      _db = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: _createSchema,
          onOpen: (db) => AppLogger.debug(_tag, 'BD abierta: $path'),
        ),
      );
      AppLogger.info(_tag, 'SQLite listo');
    } catch (e) {
      AppLogger.error(_tag, 'Failed to initialize SQLite', e);
      rethrow;
    }
  }

  /// Resuelve la ruta correcta de la BD según plataforma
  Future<String> _resolvePath() async {
    // En tests y desktop el factory ya fue configurado externamente (main o setUpAll)
    // getDatabasesPath() funciona tanto con el factory FFI como con el nativo
    final dir = await getDatabasesPath();
    return join(dir, dbName);
  }

  Future<void> _createSchema(Database db, int version) async {
    AppLogger.debug(_tag, 'Creando esquema v$version...');
    await db.execute('''
      CREATE TABLE $_tableName (
        id         TEXT PRIMARY KEY,
        name       TEXT NOT NULL,
        price      REAL NOT NULL,
        category   TEXT NOT NULL,
        stock      INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');
    AppLogger.info(_tag, 'Esquema creado: tabla "$_tableName"');
  }

  Database get _database {
    if (_db == null) throw StateError('SQLite no inicializado. Llama initialize() primero.');
    return _db!;
  }

  @override
  Future<List<ProductModel>> getAll() async {
    AppLogger.debug(_tag, 'SELECT ALL from $_tableName');
    try {
      final maps = await _database.query(_tableName, orderBy: 'created_at DESC');
      final products = maps.map(ProductModel.fromMap).toList();
      AppLogger.info(_tag, 'Cargados ${products.length} productos');
      return products;
    } catch (e) {
      AppLogger.error(_tag, 'Error getAll', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getById(String id) async {
    AppLogger.debug(_tag, 'SELECT WHERE id=$id');
    try {
      final maps = await _database.query(
        _tableName, where: 'id = ?', whereArgs: [id], limit: 1,
      );
      return maps.isEmpty ? null : ProductModel.fromMap(maps.first);
    } catch (e) {
      AppLogger.error(_tag, 'Error getById id=$id', e);
      rethrow;
    }
  }

  @override
  Future<void> create(ProductModel product) async {
    AppLogger.info(_tag, 'INSERT: "${product.name}" [${product.id}]');
    try {
      await _database.insert(
        _tableName, product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      AppLogger.debug(_tag, 'INSERT OK');
    } catch (e) {
      AppLogger.error(_tag, 'Error create', e);
      rethrow;
    }
  }

  @override
  Future<void> update(ProductModel product) async {
    AppLogger.info(_tag, 'UPDATE: "${product.name}" [${product.id}]');
    try {
      await _database.update(
        _tableName, product.toMap(),
        where: 'id = ?', whereArgs: [product.id],
      );
      AppLogger.debug(_tag, 'UPDATE OK');
    } catch (e) {
      AppLogger.error(_tag, 'Error update', e);
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    AppLogger.info(_tag, 'DELETE id=$id');
    try {
      await _database.delete(_tableName, where: 'id = ?', whereArgs: [id]);
      AppLogger.debug(_tag, 'DELETE OK');
    } catch (e) {
      AppLogger.error(_tag, 'Error delete', e);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    AppLogger.debug(_tag, 'Cerrando SQLite');
    await _db?.close();
    _db = null;
  }
}
