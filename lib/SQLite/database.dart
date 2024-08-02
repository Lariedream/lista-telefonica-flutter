import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:teste_dev/Json/account_json.dart';

class DataBase {
  final dataBaseName = "larissa.db";

  String accountTbl = '''
  CREATE TABLE accounts(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(200) NOT NULL,
    telefone INTEGER NOT NULL CHECK (telefone > 0) UNIQUE,
    createAt TEXT
  )''';

  String logTbl = '''
  CREATE TABLE log_operacoes(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dataHora TEXT NOT NULL,
    tipoOperacao TEXT NOT NULL,
    dados jsonb 
  )''';

  // Database connection
  Future<Database> init() async {
    final dataBasePath = await getApplicationDocumentsDirectory();
    final path = "${dataBasePath.path}/$dataBaseName";
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      // Create tables
      await db.execute(accountTbl);
      await db.execute(logTbl);
    });
  }

  // Retrieve accounts
  Future<List<AccountsJson>> getAccounts() async {
    final Database db = await init();
    List<Map<String, Object?>> result = await db.query("accounts");
    return result.map((e) => AccountsJson.fromMap(e)).toList();
  }

  // Insert account
  Future<int> insertAccount(BuildContext context, AccountsJson account) async {
    final Database db = await init();
    int result = await db.insert("accounts", account.toMap());
    account.setId(result);
    await logOperation(db, 'Insert', account); // Log the operation
    return result;
  }

  // Update account
  Future<int> updateAccount(String nome, int telefone, int id) async {
    final Database db = await init();
    int result = await db.rawUpdate(
        "UPDATE accounts SET nome = ?, telefone = ? WHERE id = ?",
        [nome, telefone, id]);
    AccountsJson json = new AccountsJson(
        nome: nome, telefone: telefone, createAt: DateTime.now(), id: id);
    await logOperation(db, 'Update', json); // Log the operation
    return result;
  }

  // Delete account
  Future<int> deleteAccount(int id) async {
    final Database db = await init();
    AccountsJson json = await this.getById(id);
    int result = await db.delete("accounts", where: "id =?", whereArgs: [id]);
    await logOperation(db, 'Delete', json); // Log the operation
    return result;
  }

  Future<AccountsJson> getById(int id) async {
    final Database db = await init();

    List<Map<String, dynamic>> result = await db.query(
      "accounts",
      where: "id = ?",
      whereArgs: [id],
    );

    return AccountsJson.fromMap(result.first);
  }

  // Filter accounts
  Future<List<AccountsJson>> filter(String keyword) async {
    final Database db = await init();
    String queryKeyword = '%$keyword%';
    List<Map<String, Object?>> result = await db.rawQuery(
        'SELECT * FROM accounts WHERE nome LIKE ? OR telefone LIKE ?',
        [queryKeyword, queryKeyword]);
    return result.map((e) => AccountsJson.fromMap(e)).toList();
  }

  // Log operations
  Future<void> logOperation(
      Database db, String tipoOperacao, AccountsJson account) async {
    await db.insert('log_operacoes', {
      'dataHora': DateTime.now().toIso8601String(),
      'tipoOperacao': tipoOperacao,
      'dados': jsonEncode(account.toJson())
    });
  }

  // verificação

  Future<bool> telefoneDuplicado(int telefone) async {
    final Database db = await init();
    List<Map<String, dynamic>> result = await db.query(
      'accounts',
      where: 'telefone = ?',
      whereArgs: [telefone],
    );
    return result.isNotEmpty;
  }

  // get id telefone
  Future<int?> getTelefoneById(int id) async {
    final Database db =
        await init();
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts', 
      columns: ['telefone'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first['telefone'] as int?;
    }
    return null;
  }
}
