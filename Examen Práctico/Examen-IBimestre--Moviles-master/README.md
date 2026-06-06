# 🗄️ Hybrid CRUD — Arquitectura Híbrida SQL + NoSQL
### Evaluación Práctica | Escuela Politécnica Nacional

---

## 📐 Arquitectura

```
lib/
├── core/
│   ├── logging/
│   │   └── app_logger.dart         ← Logs estructurados DEBUG/INFO/ERROR
│   └── utils/
│       └── uuid.dart               ← Generador UUID sin dependencias
├── data/
│   ├── models/
│   │   ├── product_model.dart      ← Entidad: 5 atributos (id, name, price, category, stock)
│   │   └── product_model.g.dart    ← Adaptador Hive (generado manualmente)
│   └── repositories/
│       ├── product_repository.dart      ← Interfaz abstracta (Patrón Repositorio)
│       ├── sql/
│       │   └── sqlite_product_repository.dart   ← Posición A: SQLite
│       └── nosql/
│           └── hive_product_repository.dart     ← Posición B: Hive NoSQL
└── presentation/
    ├── providers/
    │   └── product_provider.dart    ← Estado + conmutación de motor
    ├── screens/
    │   └── products_screen.dart     ← UI principal con Switch en AppBar
    └── widgets/
        ├── engine_indicator_chip.dart   ← Chip visual de motor activo
        ├── product_card.dart            ← Tarjeta de producto
        └── product_form_dialog.dart     ← Formulario Create/Update
test/
└── product_repository_test.dart    ← 9 pruebas unitarias
```

---

## ⚙️ Instalación

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Ejecutar la app
```bash
flutter run
```

### 3. Correr pruebas unitarias
```bash
flutter test
```

---

## 🔄 Mecanismo de Conmutación

| | Posición A (SQL) | Posición B (NoSQL) |
|---|---|---|
| **Motor** | SQLite | Hive |
| **Chip color** | Azul `#4FC3F7` | Verde `#AED581` |
| **Esquema** | Tabla fija con tipos SQL | Objetos dinámicos en Box |
| **API** | `sqflite` package | `hive_flutter` package |

**Switch en AppBar** → Al alternar, `ProductProvider.switchEngine()` cambia el repositorio activo y llama `refresh()` → `notifyListeners()` → UI actualiza instantáneamente.

---

## 🧱 Patrón Repositorio

```
ProductsScreen
     │
     ▼
ProductProvider          ← ChangeNotifier (estado + lógica)
     │
     ▼
ProductRepository        ← Interfaz abstracta (contrato)
     ├── SqliteProductRepository   ← Implementación SQL
     └── HiveProductRepository     ← Implementación NoSQL
```

La UI **nunca** llama directamente a SQLite o Hive.

---

## 📋 Logs Estructurados

Todos los eventos imprimen trazas con nivel:

```
[INFO ] [SQLiteRepo] 2024-01-15T10:30:00 - SQLite initialized successfully
[DEBUG] [SQLiteRepo] 2024-01-15T10:30:01 - Query: SELECT ALL from products
[INFO ] [ProductProvider] 2024-01-15T10:30:05 - ENGINE SWITCH: SQL → NOSQL
[INFO ] [HiveRepo] 2024-01-15T10:30:05 - Hive box "products_box" opened with 3 records
[ERROR] [SQLiteRepo] 2024-01-15T10:30:10 - Error inserting product
  └─ Error: ...
```

---

## 🧪 Pruebas Unitarias

| Test | Descripción |
|------|-------------|
| TC-001 | INSERT y SELECT en SQLite |
| TC-002 | UPDATE en SQLite |
| TC-003 | DELETE en SQLite |
| TC-004 | PUT y GET en Hive |
| TC-005 | Múltiples documentos en Hive |
| TC-006 | Motor inicial es SQL |
| TC-007 | `switchEngine()` cambia a NoSQL |
| TC-008 | No notifica si motor ya está activo |
| TC-009 | engineType cambia según motor |

---

## 📦 Dependencias Principales

```yaml
sqflite: ^2.3.2          # SQLite — Posición A
hive_flutter: ^1.1.0     # Hive NoSQL — Posición B
provider: ^6.1.2         # State management
google_fonts: ^6.2.1     # UI fonts
flutter_animate: ^4.5.0  # Animaciones
```

---

## 🎓 Mapeo Tecnológico (EPN)

| Capa | Tecnología | Justificación |
|------|-----------|---------------|
| Relacional | `sqflite` | SQLite nativo en Android/iOS, esquema fijo con DDL |
| No Relacional | `hive_flutter` | Store de objetos binario, sin servidor, adaptadores tipados |
| Estado | `provider` | Patrón Repositorio con ChangeNotifier |
| Logs | `debugPrint` | Trazas coloreadas por nivel en consola Flutter |
