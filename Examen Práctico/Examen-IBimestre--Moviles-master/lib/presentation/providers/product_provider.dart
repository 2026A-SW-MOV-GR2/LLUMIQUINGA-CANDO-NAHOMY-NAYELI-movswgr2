import 'package:flutter/foundation.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/sql/sqlite_product_repository.dart';
import '../../data/repositories/nosql/hive_product_repository.dart';
import '../../core/logging/app_logger.dart';
import '../../core/utils/uuid.dart';

const _uuid = Uuid();

enum DatabaseEngine { sql, nosql }

class ProductProvider extends ChangeNotifier {
  static const String _tag = 'ProductProvider';

  final SqliteProductRepository _sqlRepo;
  final HiveProductRepository _noSqlRepo;

  late ProductRepository _activeRepo;
  bool _initialized = false;

  DatabaseEngine _engine = DatabaseEngine.sql;
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  ProductProvider({
    SqliteProductRepository? sqlRepo,
    HiveProductRepository? noSqlRepo,
  })  : _sqlRepo = sqlRepo ?? SqliteProductRepository(),
        _noSqlRepo = noSqlRepo ?? HiveProductRepository();


  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DatabaseEngine get engine => _engine;
  bool get isSQL => _engine == DatabaseEngine.sql;
  bool get initialized => _initialized;

  String get engineName => _initialized ? _activeRepo.engineName : 'None';
  String get engineType => _initialized ? _activeRepo.engineType : 'none';


  Future<void> initialize() async {
    if (_initialized) return;

    AppLogger.info(_tag, 'Initializing repositories...');
    _setLoading(true);
    try {
      await _sqlRepo.initialize();
      AppLogger.info(_tag, 'SQLite ready');

      await _noSqlRepo.initialize();
      AppLogger.info(_tag, 'Hive ready');

      _activeRepo = _sqlRepo; // motor por defecto: SQL
      _initialized = true;
      AppLogger.info(_tag, 'Default engine: ${_activeRepo.engineName}');

      await _fetchProducts();
    } catch (e) {
      _error = 'Error inicializando: $e';
      AppLogger.error(_tag, 'Initialize failed', e);
    } finally {
      _setLoading(false);
    }
  }

  // ─── Conmutación de Motor ──────────────────────────────────────────────────

  /// Cambia el motor en tiempo de ejecución sin reiniciar la app.
  /// Cumple: "Al alternar el switch, la lista se actualiza al instante"
  Future<void> switchEngine(DatabaseEngine newEngine) async {
    if (_engine == newEngine) return;

    AppLogger.info(
      _tag,
      'ENGINE SWITCH: ${_engine.name.toUpperCase()} → ${newEngine.name.toUpperCase()}',
    );

    _engine = newEngine;
    _activeRepo = newEngine == DatabaseEngine.sql ? _sqlRepo : _noSqlRepo;
    AppLogger.debug(_tag, 'Active engine: ${_activeRepo.engineName}');

    await refresh();
  }

  // ─── CRUD Operations ───────────────────────────────────────────────────────

  Future<void> refresh() async {
    if (!_initialized) return;
    _setLoading(true);
    try {
      await _fetchProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      AppLogger.error(_tag, 'Error refreshing products', e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchProducts() async {
    _products = await _activeRepo.getAll();
    AppLogger.debug(_tag, 'Loaded ${_products.length} products from ${_activeRepo.engineName}');
  }

  Future<bool> createProduct({
    required String name,
    required double price,
    required String category,
    required int stock,
  }) async {
    if (!_initialized) {
      AppLogger.error(_tag, 'createProduct called before initialize()');
      return false;
    }
    try {
      final product = ProductModel(
        id: _uuid.v4(),
        name: name,
        price: price,
        category: category,
        stock: stock,
        createdAt: DateTime.now(),
      );
      AppLogger.info(_tag, 'Creating product: "$name" via ${_activeRepo.engineName}');
      await _activeRepo.create(product);
      await refresh();
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error(_tag, 'Create failed', e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    if (!_initialized) return false;
    try {
      AppLogger.info(_tag, 'Updating: "${product.name}" [${product.id}] via ${_activeRepo.engineName}');
      await _activeRepo.update(product);
      await refresh();
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error(_tag, 'Update failed', e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    if (!_initialized) return false;
    try {
      AppLogger.info(_tag, 'Deleting id=$id via ${_activeRepo.engineName}');
      await _activeRepo.delete(id);
      await refresh();
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error(_tag, 'Delete failed', e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _sqlRepo.dispose();
    await _noSqlRepo.dispose();
    super.dispose();
  }
}
