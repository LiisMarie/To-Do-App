import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "app.db";
  static final _databaseVersion = 1;

  // table: ACCOUNT
  static final tableAccount = "account";
  static final accountId = "_id";
  static final accountEmail = "email";
  static final accountPassword = "password";

  static final sqlCreateTableAccount = """
          CREATE TABLE IF NOT EXISTS $tableAccount (
          $accountId INTEGER PRIMARY KEY,
          $accountEmail TEXT NOT NULL,
          $accountPassword TEXT NOT NULL
        )""";
  static final sqlDeleteTableAccount = """DROP TABLE IF EXISTS $tableAccount""";

  // table: TODOCATEGORIES
  static final tableCategories = "todoCategories";
  static final categoriesId = "_id";
  static final categoriesName = "name";
  static final categoriesSort = "sort";
  static final categoriesLastModifiedDT = "lastModifiedDT";
  static final categoriesServerId = "serverId";

  static final sqlCreateTableCategories = """
          CREATE TABLE IF NOT EXISTS $tableCategories (
          $categoriesId INTEGER PRIMARY KEY,
          $categoriesName TEXT NOT NULL,
          $categoriesSort INTEGER NOT NULL,
          $categoriesLastModifiedDT TEXT NOT NULL,
          $categoriesServerId INTEGER
        )""";
  static final sqlDeleteTableCategories =
      """DROP TABLE IF EXISTS $tableCategories""";

  // table: TODOPRIORITIES
  static final tablePriorities = "todoPriorities";
  static final prioritiesId = "_id";
  static final prioritiesName = "name";
  static final prioritiesSort = "sort";
  static final prioritiesLastModifiedDT = "lastModifiedDT";
  static final prioritiesServerId = "serverId";

  static final sqlCreateTablePriorities = """
          CREATE TABLE IF NOT EXISTS $tablePriorities (
          $prioritiesId INTEGER PRIMARY KEY,
          $prioritiesName TEXT NOT NULL,
          $prioritiesSort INTEGER NOT NULL,
          $prioritiesLastModifiedDT TEXT NOT NULL,
          $prioritiesServerId INTEGER
        )""";
  static final sqlDeleteTablePriorities =
      """DROP TABLE IF EXISTS $tablePriorities""";

  // table: TODOTASKS
  static final tableTodoTasks = "todoTasks";
  static final todoTaskId = "_id";
  static final todoTaskName = "name";
  static final todoTaskSort = "sort";
  static final todoTaskDueDT = "dueDT";
  static final todoTaskIsCompleted = "isCompleted";
  static final todoTaskIsArchived = "isArchived";
  static final todoTaskCategoryId = "categoryId";
  static final todoTaskPriorityId = "priorityId";
  static final todoTaskLastModifiedDT = "lastModifiedDT";
  static final todoTaskServerId = "todoTaskServerId";

  static final sqlCreateTableTodoTasks = """
          CREATE TABLE IF NOT EXISTS $tableTodoTasks (
          $todoTaskId INTEGER PRIMARY KEY,
          $todoTaskName TEXT NOT NULL,
          $todoTaskSort INTEGER NOT NULL,
          $todoTaskDueDT TEXT,
          $todoTaskIsCompleted INTEGER NOT NULL CHECK ($todoTaskIsCompleted IN (0,1)),
          $todoTaskIsArchived INTEGER NOT NULL CHECK ($todoTaskIsArchived IN (0,1)),
          $todoTaskCategoryId INTEGER NOT NULL,
          $todoTaskPriorityId INTEGER NOT NULL,
          $todoTaskLastModifiedDT TEXT NOT NULL,
          $todoTaskServerId INTEGER
        )""";
  static final sqlDeleteTableTodoTasks =
      """DROP TABLE IF EXISTS $tableTodoTasks""";

  // make this an singleton
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return instance;
  }

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String path = join(appDir.path, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    // create all tables
    await db.execute(sqlCreateTableAccount);
    await db.execute(sqlCreateTableCategories);
    await db.execute(sqlCreateTablePriorities);
    await db.execute(sqlCreateTableTodoTasks);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // delete existing tables
    await db.execute(sqlDeleteTableAccount);
    await db.execute(sqlDeleteTableCategories);
    await db.execute(sqlDeleteTablePriorities);
    await db.execute(sqlDeleteTableTodoTasks);
    // recreate
    _onCreate(db, newVersion);
  }
}
