import 'package:HW3/database/database_helper.dart';

class TodoPriority {
  int _id;
  String _priorityName;
  int _prioritySort;
  String _lastModifiedDT;
  int _serverId;

  TodoPriority(this._id, this._priorityName, this._prioritySort,
      this._lastModifiedDT, this._serverId);

  int get id => _id;

  String get priorityName => _priorityName;

  int get prioritySort => _prioritySort;

  String get lastModifiedDT => _lastModifiedDT;

  int get serverId => _serverId;

  set priorityName(String newName) {
    this._priorityName = newName;
  }

  set prioritySort(int newCategorySort) {
    this._prioritySort = newCategorySort;
  }

  set lastModifiedDT(String newLastModifiedDT) {
    this._lastModifiedDT = newLastModifiedDT;
  }

  set serverId(int newServerId) {
    this._serverId = newServerId;
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.prioritiesName: _priorityName,
      DatabaseHelper.prioritiesSort: _prioritySort,
      DatabaseHelper.prioritiesLastModifiedDT: _lastModifiedDT,
      DatabaseHelper.prioritiesServerId: _serverId,
    };
  }

  TodoPriority.fromMapObject(Map<String, dynamic> map) {
    this._id = map[DatabaseHelper.prioritiesId];
    this._priorityName = map[DatabaseHelper.prioritiesName];
    this._prioritySort = map[DatabaseHelper.prioritiesSort];
    this._lastModifiedDT = map[DatabaseHelper.prioritiesLastModifiedDT];
    this._serverId = map[DatabaseHelper.prioritiesServerId];
  }

  @override
  String toString() {
    return "_id: $id; "
        "_categoryName: $_priorityName, "
        "_categorySort: $_prioritySort, "
        "_lastModifiedDT: $_lastModifiedDT, "
        "_serverId: $_serverId";
  }
}
