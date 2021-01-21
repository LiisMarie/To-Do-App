import 'package:HW3/database/database_helper.dart';
import 'package:HW3/domain/account.dart';
import 'package:HW3/domain/todo_category.dart';
import 'package:HW3/domain/todo_priority.dart';
import 'package:HW3/domain/todo_task.dart';
import 'package:sqflite/sqflite.dart';

class Repository {
  final dbHelper = DatabaseHelper();

  /* CREATE */
  Future<int> insert(String tableName, Map<String, dynamic> row) async {
    Database db = await dbHelper.database;
    return await db.insert(tableName, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /* READ */
  Future<List<Map<String, dynamic>>> queryAllRows(String tableName) async {
    Database db = await dbHelper.database;
    return await db.query(tableName);
  }

  Future<Account> getLoggedInUser() async {
    var accountMapList = await queryAllRows(DatabaseHelper.tableAccount);
    int count = accountMapList.length;

    for (int i = 0; i < count; i++) {
      return Account.fromMapObject(accountMapList[i]);
    }
    return null;
  }

  Future<List<TodoPriority>> getPriorityList() async {
    var prioritiesMapList = await queryAllRows(DatabaseHelper.tablePriorities);
    int count = prioritiesMapList.length;

    List<TodoPriority> prioritiesList = List<TodoPriority>();
    for (int i = 0; i < count; i++) {
      prioritiesList.add(TodoPriority.fromMapObject(prioritiesMapList[i]));
    }
    return prioritiesList;
  }

  Future<TodoPriority> getPriorityById(int id) async {
    Database db = await dbHelper.database;
    var prioritiesMapList = await db.query(DatabaseHelper.tablePriorities, where: "${DatabaseHelper.prioritiesId} = ?", whereArgs: [id]);
    if (prioritiesMapList.length != 0) {
      return TodoPriority.fromMapObject(prioritiesMapList[0]);
    }
    return null;
  }

  Future<TodoPriority> getPriorityByServerId(int id) async {
    Database db = await dbHelper.database;
    var prioritiesMapList = await db.query(DatabaseHelper.tablePriorities, where: "${DatabaseHelper.prioritiesServerId} = ?", whereArgs: [id]);
    if (prioritiesMapList.length != 0) {
      return TodoPriority.fromMapObject(prioritiesMapList[0]);
    }
    return null;
  }

  Future<List<TodoCategory>> getCategoryList() async {
    var categoriesMapList = await queryAllRows(DatabaseHelper.tableCategories);
    int count = categoriesMapList.length;

    List<TodoCategory> categoriesList = List<TodoCategory>();
    for (int i = 0; i < count; i++) {
      categoriesList.add(TodoCategory.fromMapObject(categoriesMapList[i]));
    }
    return categoriesList;
  }

   Future<TodoCategory> getCategoryById(int id) async {
    Database db = await dbHelper.database;
    var categoriesMapList = await db.query(DatabaseHelper.tableCategories, where: "${DatabaseHelper.categoriesId} = ?", whereArgs: [id]);
    if (categoriesMapList.length != 0) {
      return TodoCategory.fromMapObject(categoriesMapList[0]);
    }
    return null;
  }

  Future<TodoCategory> getCategoryByServerId(int id) async {
    Database db = await dbHelper.database;
    var categoriesMapList = await db.query(DatabaseHelper.tableCategories, where: "${DatabaseHelper.categoriesServerId} = ?", whereArgs: [id]);
    if (categoriesMapList.length != 0) {
      return TodoCategory.fromMapObject(categoriesMapList[0]);
    }
    return null;
  }

  Future<List<TodoTask>> getTaskList() async {
    var tasksMapList = await queryAllRows(DatabaseHelper.tableTodoTasks);
    int count = tasksMapList.length;

    List<TodoTask> tasksList = List<TodoTask>();
    for (int i = 0; i < count; i++) {
      tasksList.add(TodoTask.fromMapObject(tasksMapList[i]));
    }
    return tasksList;
  }

  Future<bool> isAnyTaskUsingCategory(int categoryId) async {
    Database db = await dbHelper.database;
    var taskMapList = await db.query(DatabaseHelper.tableTodoTasks, where: "${DatabaseHelper.todoTaskCategoryId} = ?", whereArgs: [categoryId]);
    if (taskMapList.length == 0) return false;
    return true;
  }

  Future<bool> isAnyTaskUsingPriority(int priorityId) async {
    Database db = await dbHelper.database;
    var taskMapList = await db.query(DatabaseHelper.tableTodoTasks, where: "${DatabaseHelper.todoTaskPriorityId} = ?", whereArgs: [priorityId]);
    if (taskMapList.length == 0) return false;
    return true;
  }

  /* UPDATE */
  Future<int> updatePriority(TodoPriority priority) async {
    Database db = await dbHelper.database;
    return await db.update(DatabaseHelper.tablePriorities, priority.toMap(), where: "${DatabaseHelper.prioritiesId} = ?", whereArgs: [priority.id]);
  }

  Future<int> updateCategory(TodoCategory category) async {
    Database db = await dbHelper.database;
    return await db.update(DatabaseHelper.tableCategories, category.toMap(), where: "${DatabaseHelper.categoriesId} = ?", whereArgs: [category.id]);
  }

  Future<int> updateTask(TodoTask task) async {
    Database db = await dbHelper.database;
    return await db.update(DatabaseHelper.tableTodoTasks, task.toMap(), where: "${DatabaseHelper.todoTaskId} = ?", whereArgs: [task.id]);
  }

  /* DELETE */
  Future<int> deleteUser() async {
    Database db = await dbHelper.database;
    // Pass the Account's id as a whereArg to prevent SQL injection.
    return await db.delete(DatabaseHelper.tableAccount, where: "${DatabaseHelper.accountId} = ?", whereArgs: [1]);
  }

  Future<int> deletePriority(int id) async {
    Database db = await dbHelper.database;
    return await db.delete(DatabaseHelper.tablePriorities, where: "${DatabaseHelper.prioritiesId} = ?", whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    Database db = await dbHelper.database;
    return await db.delete(DatabaseHelper.tableCategories, where: "${DatabaseHelper.categoriesId} = ?", whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await dbHelper.database;
    return await db.delete(DatabaseHelper.tableTodoTasks, where: "${DatabaseHelper.todoTaskId} = ?", whereArgs: [id]);
  }

  Future<void> deleteAllData() async {
    Database db = await dbHelper.database;
    db.delete(DatabaseHelper.tableTodoTasks);
    db.delete(DatabaseHelper.tableCategories);
    db.delete(DatabaseHelper.tablePriorities);
  }

}
