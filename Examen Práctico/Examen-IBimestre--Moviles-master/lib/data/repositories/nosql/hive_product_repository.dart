import 'package:hive_flutter/hive_flutter.dart';

import '../../models/product_model.dart';
import '../product_repository.dart';
import '../../../core/logging/app_logger.dart';

class HiveProductRepository implements ProductRepository {
  static const String _tag = 'HiveRepo';

  final String boxName;
  Box<ProductModel>? _box;

  HiveProductRepository({this.boxName = 'products_box'});

  @override
  String get engineName => 'Hive (NoSQL)';

  @override
  String get engineType => 'nosql';

  @override
  Future<void> initialize() async {
    AppLogger.info(_tag, 'Initializing Hive NoSQL store (box: "$boxName")...');
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductModelAdapter());
        AppLogger.debug(_tag, 'ProductModelAdapter registered');
      }

      if (Hive.isBoxOpen(boxName)) {
        _box = Hive.box<ProductModel>(boxName);
        AppLogger.debug(_tag, 'Reusing already-open box "$boxName"');
      } else {
        _box = await Hive.openBox<ProductModel>(boxName);
      }

      AppLogger.info(_tag, 'Hive box "$boxName" ready with ${_box!.length} records');
    } catch (e) {
      AppLogger.error(_tag, 'Failed to initialize Hive', e);
      rethrow;
    }
  }

  Box<ProductModel> get _store {
    if (_box == null || !_box!.isOpen) {
      throw StateError('Hive box "$boxName" not initialized. Call initialize() first.');
    }
    return _box!;
  }

  @override
  Future<List<ProductModel>> getAll() async {
    AppLogger.debug(_tag, 'Fetching all documents from Hive box "$boxName"');
    try {
      final products = _store.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      AppLogger.info(_tag, 'Fetched ${products.length} products from Hive');
      return products;
    } catch (e) {
      AppLogger.error(_tag, 'Error fetching from Hive', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getById(String id) async {
    AppLogger.debug(_tag, 'Hive: get document key=$id');
    try {
      return _store.get(id);
    } catch (e) {
      AppLogger.error(_tag, 'Error getting document id=$id', e);
      rethrow;
    }
  }

  @override
  Future<void> create(ProductModel product) async {
    AppLogger.info(_tag, 'Hive PUT: ${product.name} [key=${product.id}]');
    try {
      await _store.put(product.id, product);
      AppLogger.debug(_tag, 'Document stored in Hive successfully');
    } catch (e) {
      AppLogger.error(_tag, 'Error storing document in Hive', e);
      rethrow;
    }
  }

  @override
  Future<void> update(ProductModel product) async {
    AppLogger.info(_tag, 'Hive UPDATE: ${product.name} [key=${product.id}]');
    try {
      await _store.put(product.id, product);
      AppLogger.debug(_tag, 'Document updated in Hive');
    } catch (e) {
      AppLogger.error(_tag, 'Error updating document in Hive', e);
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    AppLogger.info(_tag, 'Hive DELETE: key=$id');
    try {
      await _store.delete(id);
      AppLogger.debug(_tag, 'Document deleted from Hive');
    } catch (e) {
      AppLogger.error(_tag, 'Error deleting document from Hive', e);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    AppLogger.debug(_tag, 'Closing Hive box "$boxName"');
    await _box?.close();
    _box = null;
  }
}
