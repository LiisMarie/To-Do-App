import 'package:HW3/database/database_helper.dart';
import 'package:HW3/helpers/sync_helpers.dart';
import 'package:HW3/database/repository.dart';
import 'package:HW3/providers/model.dart';
import 'package:HW3/screens/menu_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final repository = Repository();

  @override
  void initState() {
    super.initState();

    // cancel timer
    Provider.of<Model>(context, listen: false).cancelTimer();
  }

  void logOut() {

    // last sync before logging out
    var token = Provider.of<Model>(context, listen: false).token;
    if (token.length != 0) {
      syncAll(token);
    }

    Provider.of<Model>(context, listen: false).resetToken();  // reset token
    repository.deleteUser();  // delete user data from local database
    repository.deleteAllData();  // delete todos, categories and priorities from local db

    // navigate to todos
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/display-todos', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: repository.queryAllRows(DatabaseHelper.tableAccount),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                child: Column(
                  children: [
                    _buildEmailDisplay(
                        snapshot.data[0][DatabaseHelper.accountEmail]),

                    Divider(color: Colors.transparent),

                    _buildLogOutButton(),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Container(
              alignment: AlignmentDirectional.center,
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      drawer: MenuItems(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text("Account"),
    );
  }

  Widget _buildEmailDisplay(String email) {
    return Container(
      child: Column(
        children: [
          Text(
            "Email:",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          Divider(color: Colors.transparent),
          Text(
            "$email",
            style: TextStyle(
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogOutButton() {
    return Container(
      child: ElevatedButton(
        onPressed: () => logOut(),
        child: Text('Log out'),
      ),
    );
  }
}
