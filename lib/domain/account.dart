import 'package:HW3/database/database_helper.dart';

class Account {
  int _id;
  String _email;
  String _password;

  Account(this._id, this._email, this._password);

  int get id => _id;

  String get email => _email;

  String get password => _password;

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.accountId: _id,
      DatabaseHelper.accountEmail: _email,
      DatabaseHelper.accountPassword: _password,
    };
  }

  Account.fromMapObject(Map<String, dynamic> map) {
    this._id = map[DatabaseHelper.accountId];
    this._email = map[DatabaseHelper.accountEmail];
    this._password = map[DatabaseHelper.accountPassword];
  }
}
