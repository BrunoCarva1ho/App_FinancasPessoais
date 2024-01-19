import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE data(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        desc_conta TEXT,
        valor TEXT,
        dataPaga TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      CREATE TABLE user(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        saldo TEXT,
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

  static Future<void> adicionarSaldo(
      String descConta, String valor, String saldoAtual) async {
    final db = await SQLHelper.db();

    final user = {
      "saldo": saldoAtual,
    };

    final data = {
      "desc_conta": descConta,
      "valor": valor,
    };

    await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    await db.update('user', user);
  }

  static Future<void> criarSaldo(String saldoAtual) async {
    final db = await SQLHelper.db();

    final user = {
      "saldo": saldoAtual,
    };

    await db.insert('user', user,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> adicionarConta(String descConta, String valor,
      String dataPaga, double saldoAtual) async {
    final db = await SQLHelper.db();

    final user = {
      "saldo": saldoAtual,
    };

    final data = {
      "desc_conta": descConta,
      "valor": valor,
    };

    await db.update('user', user);
    await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLHelper.db();
    return db.query('data', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getUser() async {
    final db = await SQLHelper.db();
    return db.query('user', orderBy: 'id');
  }

  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('data', where: "id= ?", whereArgs: [id]);
    } catch (e) {}
  }
}
