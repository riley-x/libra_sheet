import 'dart:async';

import 'package:libra_sheet/data/category.dart';
import 'package:libra_sheet/data/database/database_setup.dart';
import 'package:sqflite/sqlite_api.dart';

const categoryTable = '`categories`';

FutureOr<int> insertCategory(Category cat, {int? listIndex}) async {
  if (database == null) return 0;
  return database!.insert(
    categoryTable,
    cat.toMap(listIndex: listIndex),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Future<void> updateAccount(Account acc, {int? listIndex}) async {
//   await database?.update(
//     categoryTable,
//     acc.toMap(listIndex: listIndex),
//     where: '`key` = ?',
//     whereArgs: [acc.key],
//   );
// }
