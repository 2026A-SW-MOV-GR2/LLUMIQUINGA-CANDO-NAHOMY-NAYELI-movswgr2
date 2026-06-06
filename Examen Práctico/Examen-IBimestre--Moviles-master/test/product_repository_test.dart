import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'package:flutter_hybrid_crud/data/models/product_model.dart';
import 'package:flutter_hybrid_crud/data/repositories/sql/sqlite_product_repository.dart';
import 'package:flutter_hybrid_crud/data/repositories/nosql/hive_product_repository.dart';
import 'package:flutter_hybrid_crud/presentation/providers/product_provider.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// PRUEBAS UNITARIAS — EPN Evaluación Práctica
/// ─────────────────────────────────────────────────────────────────────────────

ProductModel makeProduct({String id = 'test-001'}) => ProductModel(
      id: id,
      name: 'Laptop Test Pro',
      price: 999.99,
      category: 'Electronics',
      stock: 5,
      createdAt: DateTime(2024, 1, 15),
    );

int _counter = 0;
String get _nextDbName => 'test_${++_counter}.db';
String get _nextBoxName => 'box_$_counter';

void main() {
  setUpAll(() async {
    // FFI para tests en desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Hive en carpeta temporal
    final dir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductModelAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
  });

  // ─── GRUPO 1: SQLite ───────────────────────────────────────────────────────
  group('SQLite Repository', () {
    late SqliteProductRepository repo;

    setUp(() async {
      repo = SqliteProductRepository(dbName: _nextDbName);
      // En tests el factory ya fue seteado en setUpAll, no necesita Platform check
      await repo.initialize();
    });

    tearDown(() => repo.dispose());

    test('TC-001: inserta y recupera un producto por ID', () async {
      final p = makeProduct(id: 'sql-tc01');
      await repo.create(p);

      final found = await repo.getById('sql-tc01');
      expect(found, isNotNull);
      expect(found!.name, equals('Laptop Test Pro'));
      expect(found.price, equals(999.99));
      expect(found.stock, equals(5));
    });

    test('TC-002: actualiza un producto existente', () async {
      final p = makeProduct(id: 'sql-tc02');
      await repo.create(p);

      await repo.update(p.copyWith(name: 'Updated', price: 1499.00));
      final found = await repo.getById('sql-tc02');

      expect(found!.name, equals('Updated'));
      expect(found.price, equals(1499.00));
    });

    test('TC-003: elimina un producto y retorna null', () async {
      final p = makeProduct(id: 'sql-tc03');
      await repo.create(p);
      await repo.delete('sql-tc03');
      expect(await repo.getById('sql-tc03'), isNull);
    });

    test('TC-004: getAll retorna todos los insertados', () async {
      await repo.create(makeProduct(id: 'sql-a'));
      await repo.create(makeProduct(id: 'sql-b'));

      final ids = (await repo.getAll()).map((p) => p.id).toList();
      expect(ids, containsAll(['sql-a', 'sql-b']));
    });
  });

  // ─── GRUPO 2: Hive ─────────────────────────────────────────────────────────
  group('Hive (NoSQL) Repository', () {
    late HiveProductRepository repo;

    setUp(() async {
      repo = HiveProductRepository(boxName: _nextBoxName);
      await repo.initialize();
    });

    tearDown(() => repo.dispose());

    test('TC-005: inserta y recupera un documento en Hive', () async {
      final p = makeProduct(id: 'hive-tc05');
      await repo.create(p);

      final found = await repo.getById('hive-tc05');
      expect(found, isNotNull);
      expect(found!.name, equals('Laptop Test Pro'));
    });

    test('TC-006: elimina un documento de Hive', () async {
      final p = makeProduct(id: 'hive-tc06');
      await repo.create(p);
      await repo.delete('hive-tc06');
      expect(await repo.getById('hive-tc06'), isNull);
    });
  });

  // ─── GRUPO 3: Cambio de motor ──────────────────────────────────────────────
  group('Engine Switching (ProductProvider)', () {
    test('TC-007: motor inicial es SQL', () {
      final p = ProductProvider();
      expect(p.engine, equals(DatabaseEngine.sql));
      expect(p.isSQL, isTrue);
    });

    test('TC-008: switchEngine cambia a NoSQL', () async {
      final p = ProductProvider();
      await p.switchEngine(DatabaseEngine.nosql);
      expect(p.isSQL, isFalse);
      expect(p.engine, equals(DatabaseEngine.nosql));
    });

    test('TC-009: no notifica si el motor ya está activo', () async {
      final p = ProductProvider();
      var count = 0;
      p.addListener(() => count++);
      await p.switchEngine(DatabaseEngine.sql); // mismo motor
      expect(count, equals(0));
    });

    test('TC-010: puede volver de NoSQL a SQL', () async {
      final p = ProductProvider();
      await p.switchEngine(DatabaseEngine.nosql);
      await p.switchEngine(DatabaseEngine.sql);
      expect(p.isSQL, isTrue);
    });
  });
}
