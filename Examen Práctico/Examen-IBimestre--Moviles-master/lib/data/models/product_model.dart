import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double price;

  @HiveField(3)
  late String category;

  @HiveField(4)
  late int stock;

  @HiveField(5)
  late DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.createdAt,
  });

  /// Convierte desde Map (usado por SQLite)
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      stock: map['stock'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// Convierte a Map (usado por SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    int? stock,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Product(id: $id, name: $name, price: $price, category: $category, stock: $stock)';
}
