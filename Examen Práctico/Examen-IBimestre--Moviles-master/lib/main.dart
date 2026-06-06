import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'presentation/providers/product_provider.dart';
import 'presentation/screens/products_screen.dart';
import 'core/logging/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppLogger.info('Main', 'SQLite FFI inicializado para ${Platform.operatingSystem}');
  }

  await Hive.initFlutter();
  AppLogger.info('Main', 'Hive listo');

  final provider = ProductProvider();
  await provider.initialize();
  AppLogger.info('Main', 'ProductProvider listo — iniciando UI');

  runApp(HybridCrudApp(provider: provider));
}

class HybridCrudApp extends StatelessWidget {
  final ProductProvider provider;
  const HybridCrudApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        title: 'Hybrid CRUD - EPN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF4FC3F7),
            secondary: const Color(0xFFAED581),
            surface: const Color(0xFF16213E),
          ),
          scaffoldBackgroundColor: const Color(0xFF0D0D1B),
          useMaterial3: true,
        ),
        home: const ProductsScreen(),
      ),
    );
  }
}
