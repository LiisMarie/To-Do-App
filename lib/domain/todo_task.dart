import 'package:HW3/database/database_helper.dart';

class TodoTask {
  int _id;
  String _taskName;
  int _taskSort;
  String _taskDueDT;
  int _taskIsCompleted;
  int _taskIsArchived;
  int _taskCategoryId;
  int _taskPriorityId;
  String _lastModifiedDT;
  int _serverId;

  TodoTask(
      this._id,
      this._taskName,
      this._taskSort,
      this._taskDueDT,
      this._taskIsCompleted,
      this._taskIsArchived,
      this._taskCategoryId,
      this._taskPriorityId,
      this._lastModifiedDT,
      this._serverId);

  int get id => _id;

  String get taskName => _taskName;

  int get taskSort => _taskSort;

  String get taskDueDT => _taskDueDT;

  int get isCompleted => _taskIsCompleted;

  bool get isCompletedAsBoolean => _taskIsCompleted == 0 ? false : true;

  int get isArchived => _taskIsArchived;

  bool get isArchivedAsBoolean => _taskIsArchived == 0 ? false : true;

  int get taskCategory => _taskCategoryId;

  int get taskPriority => _taskPriorityId;

  String get lastModifiedDT => _lastModifiedDT;

  int get serverId => _serverId;

  set taskName(String newName) {
    this._taskName = newName;
  }

  set taskSort(int newSort) {
    this._taskSort = newSort;
  }

  set taskDueDT(String newDueDT) {
    this._taskDueDT = newDueDT;
  }

  set isCompleted(int newIsCompleted) {
    this._taskIsCompleted = newIsCompleted;
  }

  set isArchived(int newIsArchived) {
    this._taskIsArchived = newIsArchived;
  }

  set taskCategory(int newCategory) {
    this._taskCategoryId = newCategory;
  }

  set taskPriority(int newPriority) {
    this._taskPriorityId = newPriority;
  }

  set lastModifiedDT(String newLastModifiedDT) {
    this._lastModifiedDT = newLastModifiedDT;
  }

  set serverId(int newServerId) {
    this._serverId = newServerId;
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.todoTaskName: _taskName,
      DatabaseHelper.todoTaskSort: _taskSort,
      DatabaseHelper.todoTaskDueDT: _taskDueDT,
      DatabaseHelper.todoTaskIsCompleted: _taskIsCompleted,
      DatabaseHelper.todoTaskIsArchived: _taskIsArchived,
      DatabaseHelper.todoTaskCategoryId: _taskCategoryId,
      DatabaseHelper.todoTaskPriorityId: _taskPriorityId,
      DatabaseHelper.todoTaskLastModifiedDT: _lastModifiedDT,
      DatabaseHelper.todoTaskServerId: _serverId,
    };
  }

  TodoTask.fromMapObject(Map<String, dynamic> map) {
    this._id = map[DatabaseHelper.todoTaskId];
    this._taskName = map[DatabaseHelper.todoTaskName];
    this._taskSort = map[DatabaseHelper.todoTaskSort];
    this._taskDueDT = map[DatabaseHelper.todoTaskDueDT];
    this._taskIsCompleted = map[DatabaseHelper.todoTaskIsCompleted];
    this._taskIsArchived = map[DatabaseHelper.todoTaskIsArchived];
    this._taskCategoryId = map[DatabaseHelper.todoTaskCategoryId];
    this._taskPriorityId = map[DatabaseHelper.todoTaskPriorityId];
    this._lastModifiedDT = map[DatabaseHelper.todoTaskLastModifiedDT];
    this._serverId = map[DatabaseHelper.todoTaskServerId];
  }

  @override
  String toString() {
    return "_id: $id; "
        "_taskName: $_taskName, "
        "_taskSort: $_taskSort, "
        "_taskDueDT: $_taskDueDT, "
        "_taskIsCompleted: $_taskIsCompleted, "
        "_taskIsArchived: $_taskIsArchived, "
        "_taskCategoryId: $_taskCategoryId, "
        "_taskPriorityId: $_taskPriorityId, "
        "_lastModifiedDT: $_lastModifiedDT, "
        "_serverId: $_serverId";
  }
}
