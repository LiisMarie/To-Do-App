import 'package:HW3/database/database_helper.dart';

class TodoCategory {
  int _id;
  String _categoryName;
  int _categorySort;
  String _lastModifiedDT;
  int _serverId;

  TodoCategory(this._id, this._categoryName, this._categorySort,
      this._lastModifiedDT, this._serverId);

  int get id => _id;

  String get categoryName => _categoryName;

  int get categorySort => _categorySort;

  String get lastModifiedDT => _lastModifiedDT;

  int get serverId => _serverId;

  set categoryName(String newName) {
    this._categoryName = newName;
  }

  set categorySort(int newCategorySort) {
    this._categorySort = newCategorySort;
  }

  set lastModifiedDT(String newLastModifiedDT) {
    this._lastModifiedDT = newLastModifiedDT;
  }

  set serverId(int newServerId) {
    this._serverId = newServerId;
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.categoriesName: _categoryName,
      DatabaseHelper.categoriesSort: _categorySort,
      DatabaseHelper.categoriesLastModifiedDT: _lastModifiedDT,
      DatabaseHelper.categoriesServerId: _serverId,
    };
  }

  TodoCategory.fromMapObject(Map<String, dynamic> map) {
    this._id = map[DatabaseHelper.categoriesId];
    this._categoryName = map[DatabaseHelper.categoriesName];
    this._categorySort = map[DatabaseHelper.categoriesSort];
    this._lastModifiedDT = map[DatabaseHelper.categoriesLastModifiedDT];
    this._serverId = map[DatabaseHelper.categoriesServerId];
  }

  @override
  String toString() {
    return "_id: $id; "
        "_categoryName: $_categoryName, "
        "_categorySort: $_categorySort, "
        "_lastModifiedDT: $_lastModifiedDT, "
        "_serverId: $_serverId";
  }
}
