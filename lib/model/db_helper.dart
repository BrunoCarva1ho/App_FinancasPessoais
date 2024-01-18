import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE data(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,

        saldo TEXT,
        desc_conta TEXT,
        valor TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("database_name.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<void> createDataSaldo(String saldo) async {
    final db = await SQLHelper.db();
    final data = {"saldo": saldo};

    await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> createData(String desc_conta, String valor) async {
    final db = await SQLHelper.db();

    final data = {"desc_conta": desc_conta, "valor": valor};

    await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLHelper.db();
    return db.query('data', orderBy: 'id');
  }

  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('data', where: "id= ?", whereArgs: [id]);
    } catch (e) {}
  }
}
