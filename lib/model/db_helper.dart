import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE data(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        desc_conta TEXT,
        valor TEXT,
        tipo TEXT,
        metodo TEXT,
        data_do_valor TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("dados.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<void> adicionarPagamento(String descConta, String valor,
      String dataPaga, String dataDoValor, String metodo) async {
    final db = await SQLHelper.db();

    final data = {
      "desc_conta": descConta,
      "valor": valor,
      "tipo": "pagamento",
      "metodo": metodo,
      "data_do_valor": dataDoValor
    };

    await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> adicionarRecebimento(String descConta, String valor,
      String dataPaga, String dataDoValor, String metodo) async {
    final db = await SQLHelper.db();

    final data = {
      "desc_conta": descConta,
      "valor": valor,
      "tipo": "recebimento",
      "metodo": metodo,
      "data_do_valor": dataDoValor
    };

    await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getDebito() async {
    final db = await SQLHelper.db();
    return db.query('data',
        where: 'metodo LIKE ?',
        whereArgs: ['Cartão de Débito'],
        orderBy: 'id DESC');
  }

  static Future<List<Map<String, dynamic>>> getCarteira() async {
    final db = await SQLHelper.db();
    return db.query('data',
        where: 'metodo LIKE ?', whereArgs: ['Dinheiro'], orderBy: 'id DESC');
  }

  static Future<void> editData(
      int id, String descConta, String valor, String data) async {
    final db = await SQLHelper.db();
    final newData = {
      "desc_conta": descConta,
      "valor": valor,
      "data_do_valor": data
    };
    try {
      await db.update('data', newData, where: "id = ?", whereArgs: [id]);
    } catch (e) {}
  }

  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('data', where: "id= ?", whereArgs: [id]);
    } catch (e) {}
  }
}
