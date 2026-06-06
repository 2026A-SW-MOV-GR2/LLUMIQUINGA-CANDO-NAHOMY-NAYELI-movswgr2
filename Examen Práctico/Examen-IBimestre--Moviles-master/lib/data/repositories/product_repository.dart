import '../../data/models/product_model.dart';

abstract class ProductRepository {
  /// Obtiene todos los productos
  Future<List<ProductModel>> getAll();

  /// Obtiene un producto por ID
  Future<ProductModel?> getById(String id);

  /// Crea un nuevo producto
  Future<void> create(ProductModel product);

  /// Actualiza un producto existente
  Future<void> update(ProductModel product);

  /// Elimina un producto por ID
  Future<void> delete(String id);

  /// Nombre del motor activo (para logs e indicador visual)
  String get engineName;

  /// Tipo de motor: 'sql' o 'nosql'
  String get engineType;

  /// Inicializa el repositorio (abre BD, crea tablas, etc.)
  Future<void> initialize();

  /// Cierra conexiones
  Future<void> dispose();
}
