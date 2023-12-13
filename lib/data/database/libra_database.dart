import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:libra_sheet/data/database/accounts.dart';
import 'package:libra_sheet/data/database/allocations.dart';
import 'package:libra_sheet/data/database/categories.dart';
import 'package:libra_sheet/data/database/category_history.dart';
import 'package:libra_sheet/data/database/reimbursements.dart';
import 'package:libra_sheet/data/database/rules.dart';
import 'package:libra_sheet/data/database/tags.dart';
import 'package:libra_sheet/data/database/transactions.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// TODO deprecated
Database? libraDatabase;

final _backupDateFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');

class LibraDatabase {
  //-------------------------------------------------------------------------------------
  // Singleton setup (is this even needed? everything is static)
  //-------------------------------------------------------------------------------------
  LibraDatabase._internal();
  static final LibraDatabase _instance = LibraDatabase._internal();
  factory LibraDatabase() {
    return _instance;
  }

  //-------------------------------------------------------------------------------------
  // Members
  //-------------------------------------------------------------------------------------
  static Database? _database;

  static Database get db {
    if (_database == null) throw StateError("Database not initialized");
    return _database!;
  }

  /// This measures the amount of "data" processed since the last backup happened. It is roughly
  /// equivalent to the number of rows affected. A new backup will be registered when this reaches
  /// [_maxScore].
  static int _scoreSinceLastBackup = 0;
  static DateTime _lastBackupTime = DateTime.now();

  static const int _maxScore = 100;

  //-------------------------------------------------------------------------------------
  // Database setup
  //-------------------------------------------------------------------------------------
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    /// Windows: C:\Users\riley\Documents\Projects\libra_sheet\.dart_tool\sqflite_common_ffi\databases\libra_sheet.db
    /// Windows exe: C:\Users\riley\Documents\Projects\libra_sheet\build\windows\runner\Release\.dart_tool\sqflite_common_ffi\databases\libra_sheet.db
    /// Mac: /Users/riley/Library/Containers/com.example.libraSheet/Data/Documents/libra_sheet.db
    // final path = join(await getDatabasesPath(), 'libra_sheet.db');

    final appDocumentsDir = await getApplicationDocumentsDirectory();
    final path = join(appDocumentsDir.path, "Libra Sheet", "libra_sheet.db");
    debugPrint('LibraDatabase::init() path=$path');

    _database = await openDatabase(
      path,
      onCreate: _createDatabase,
      version: 14,
    );
    libraDatabase = _database;
  }

  static Future<void> backup() async {
    _lastBackupTime = DateTime.now();
    _scoreSinceLastBackup = 0;
    final timestamp = _backupDateFormat.format(_lastBackupTime);

    String origPath = db.path;
    String newPath;
    if (origPath.endsWith('.db')) {
      newPath = "${origPath.substring(0, origPath.length - 3)}_$timestamp.db";
    } else {
      newPath = "${origPath}_$timestamp";
    }
    await File(origPath).copy(newPath);
    debugPrint("LibraDatabase::backup() Backed up to $newPath");
  }

  /// Adds to [_scoreSinceLastBackup], and triggers a backup if it exceeds [_maxScore] and hasn't
  /// been backed-up in the past 10 seconds (this helps prevent multiple backups in a single big
  /// transaction).
  static void tallyBackup(int score) {
    _scoreSinceLastBackup += score;
    if (_scoreSinceLastBackup > _maxScore &&
        DateTime.now().difference(_lastBackupTime).inSeconds > 10) backup();
  }
}

FutureOr<void> _createDatabase(Database db, int version) {
  return switch (version) {
    14 => _createDatabase14(db),
    _ => null,
  };
}

FutureOr<void> _createDatabase14(Database db) async {
  await db.execute(createAccountsTableSql);
  await db.execute("CREATE TABLE IF NOT EXISTS $categoryTable ("
      "`key` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "`name` TEXT NOT NULL, "
      "`colorLong` INTEGER NOT NULL, "
      "`parentKey` INTEGER NOT NULL, "
      "`listIndex` INTEGER NOT NULL)");
  await db.execute(createCategoryHistoryTableSql);
  await db.execute(createRulesTableSql);
  await db.execute(createTagsTableSql);
  await db.execute(createTransactionsTableSql);
  await db.execute(createAllocationsTableSql);
  await db.execute(createReimbursementsTableSql);
  await db.execute(createTagJoinTableSql);
  await db.execute(createDefaultCategories);
  if (kDebugMode) {
    await db.execute(createTestAccountsSql);
    await db.execute(createTestTagsSql);
  }
}

const createDefaultCategories = '''
INSERT INTO "categories" ("key", "name", "colorLong", "parentKey", "listIndex") VALUES
(1, 'Paycheck', 4279939415, -1, 0),
(2, 'Cash Back', 4278607389, -1, 1),
(3, 'Gifts', 4293828260, -1, 2),
(4, 'Interest', 4285770954, -1, 3),
(5, 'Tax Refund', 4284238947, -1, 4),
(6, 'Household', 4286531083, -2, 4),
(7, 'Utilities', 4293303345, 6, 1),
(8, 'Rent/Mortgage', 4287500554, 6, 0),
(9, 'Supplies', 4290017826, 6, 2),
(10, 'Food', 4283611708, -2, 0),
(11, 'Groceries', 4285851992, 10, 0),
(12, 'Takeout', 4291882280, 10, 1),
(13, 'Restaurants', 4278422059, 10, 2),
(14, 'Snacks', 4285369631, 10, 3),
(15, 'Alcohol', 4287806109, 10, 4),
(16, 'Shopping', 4278434036, -2, 1),
(17, 'Clothes', 4283008198, 16, 0),
(18, 'Electronics', 4282903786, 16, 1),
(19, 'Furniture', 4283925399, 16, 2),
(20, 'Gifts', 4278937202, 16, 3),
(21, 'Entertainment', 4293960260, -2, 2),
(22, 'Subscriptions', 4289683232, 21, 0),
(23, 'Games', 4293907217, 21, 1),
(24, 'Movies & Events', 4292836714, 21, 2),
(25, 'Health', 4291904339, -2, 3),
(26, 'Pharmacy', 4291053104, 25, 0),
(27, 'Beauty', 4294923164, 25, 1),
(28, 'Copays', 4292848559, 25, 2),
(29, 'Insurance', 4288020487, 25, 3),
(30, 'Transportation', 4281353876, -2, 5),
(31, 'Car', 4284443815, 30, 0),
(32, 'Gas', 4283382146, 30, 1),
(33, 'Taxis', 4282349036, 30, 2),
(34, 'Fares', 4289710333, 30, 3),
(35, 'Other', 4287993237, -2, 7),
(36, 'Hotels', 4289619419, 39, 0),
(37, 'Taxes', 4289687417, 35, 0),
(38, 'Services', 4287460443, 35, 1),
(39, 'Vacation', 4291798491, -2, 6),
(40, 'Transportation', 4290074759, 39, 1),
(41, 'Attractions', 4293365977, 39, 2);
''';
