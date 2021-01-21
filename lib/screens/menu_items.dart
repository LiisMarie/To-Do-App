import 'package:HW3/database/database_helper.dart';
import 'package:HW3/database/repository.dart';
import 'package:HW3/providers/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class MenuItems extends StatefulWidget {
  @override
  _MenuItemsState createState() => _MenuItemsState();
}

class _MenuItemsState extends State<MenuItems> {
  final repository = Repository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: repository.queryAllRows(DatabaseHelper.tableAccount),
      builder: (context, snapshot) {
        return Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Stack(children: <Widget>[
                    Positioned(
                      bottom: 12.0,
                      left: 16.0,
                      child: Text(
                        "Menu",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.0,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ])),

              // go to categories
              _createDrawerItem(
                icon: Icons.assignment_turned_in,
                text: "To-Do Tasks",
                route: "/display-todos",
              ),

              Divider(),

              // go to priorities
              _createDrawerItem(
                icon: Icons.category,
                text: "Categories",
                route: "/display-categories",
              ),

              Divider(),

              // go to account info, visible when logged in
              _createDrawerItem(
                icon: Icons.priority_high,
                text: "Priorities",
                route: "/display-priorities",
              ),

              Divider(),

              // go to login/register page, visible when not logged in
              Visibility(
                visible: snapshot.hasData && snapshot.data.isNotEmpty,
                child: _createDrawerItem(
                  icon: Icons.account_box_rounded,
                  text: "Account",
                  route: "/account",
                ),
              ),
              Visibility(
                visible: snapshot.hasData && snapshot.data.isEmpty,
                child: _createDrawerItem(
                  icon: Icons.login,
                  text: "Login / Register",
                  route: "/login",
                ),
              ),

              Divider(),

              // switch for changing app theme
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: ToggleSwitch(
                    minWidth: 100,
                    initialLabelIndex: 0,
                    cornerRadius: 20.0,
                    activeBgColor: Colors.grey,
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.amber,
                    inactiveFgColor: Colors.white,
                    labels: ['DARK', 'LIGHT'],
                    icons: [Icons.brightness_3, Icons.wb_sunny],
                    onToggle: (_) {
                      Provider.of<Model>(context, listen: false).setTheme(
                          Provider.of<Model>(context, listen: false)
                                      .getTheme() ==
                                  ThemeData.dark()
                              ? ThemeData.light()
                              : ThemeData.dark());
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _createDrawerItem({IconData icon, String text, String route}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}
