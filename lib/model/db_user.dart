import 'package:sqflite/sqflite.dart' as sql;

class SQLUser {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE user(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        saldo TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("user.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<void> adicionarSaldo(
      String descConta, String valor, String dataPaga) async {
    final db = await SQLUser.db();

    final data = {
      "desc_conta": descConta,
      "valor": valor,
    };

    await db.insert('user', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLUser.db();
    return db.query('user', orderBy: 'id');
  }

  static Future<void> deleteData(int id) async {
    final db = await SQLUser.db();
    try {
      await db.delete('user', where: "id= ?", whereArgs: [id]);
    } catch (e) {}
  }
}
