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

    await database.execute("""
      CREATE TABLE debito(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        saldo TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);

    await database.execute("""
      CREATE TABLE carteira(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        saldo TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("financas.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<void> adicionarPagamento(String descConta, String valor,
      String dataPaga, String saldo, String dataDoValor, String metodo) async {
    final db = await SQLHelper.db();

    final valorSaldo = {
      "saldo": saldo,
    };

    if (metodo == "Dinheiro") {
      await db.insert('carteira', valorSaldo,
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
    } else {
      await db.insert('debito', valorSaldo,
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
    }

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
      String dataPaga, String saldo, String dataDoValor, String metodo) async {
    final db = await SQLHelper.db();

    final valorSaldo = {
      "saldo": saldo,
    };

    if (metodo == "Dinheiro") {
      await db.insert('carteira', valorSaldo,
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
    } else {
      await db.insert('debito', valorSaldo,
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
    }

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

  static Future<List<Map<String, dynamic>>> getSaldoDebito() async {
    final db = await SQLHelper.db();
    return db.query('debito', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSaldoCarteira() async {
    final db = await SQLHelper.db();
    return db.query('carteira', orderBy: 'id');
  }

  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('data', where: "id= ?", whereArgs: [id]);
    } catch (e) {}
  }
}
