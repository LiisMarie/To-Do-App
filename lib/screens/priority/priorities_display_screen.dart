import 'dart:async';

import 'package:HW3/api/api.dart';
import 'package:HW3/database/repository.dart';
import 'package:HW3/domain/account.dart';
import 'package:HW3/domain/todo_priority.dart';
import 'package:HW3/helpers/helpers.dart';
import 'package:HW3/helpers/sync_helpers.dart';
import 'package:HW3/providers/model.dart';
import 'package:HW3/screens/menu_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'priorities_add_edit_screen.dart';

class PrioritiesDisplayScreen extends StatefulWidget {
  @override
  _PrioritiesDisplayScreenState createState() =>
      _PrioritiesDisplayScreenState();
}

class _PrioritiesDisplayScreenState extends State<PrioritiesDisplayScreen> {
  final repository = Repository();

  Account loggedInAccount;

  List<TodoPriority> priorityList;
  int priorityCount = 0;

  @override
  void initState() {
    super.initState();
    // refresh token
    getToken(context);

    // cancel timer
    Provider.of<Model>(context, listen: false).cancelTimer();
    // set new timer
    Provider.of<Model>(context, listen: false).setTimer(new Timer.periodic(
        const Duration(seconds: 15), (Timer t) => updateListView()));
  }

  @override
  Widget build(BuildContext context) {
    if (priorityList == null) {
      priorityList = List<TodoPriority>();
      updateListView();
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        child: getPriorityListView(),
      ),
      drawer: MenuItems(),
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('Priorities'),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: () {
        navigateToAddEditDetail(
            TodoPriority(null, '', 0, '', null), PriorityActionType.add);
      },
      tooltip: 'Add Priority',
      child: Icon(Icons.add),
    );
  }

  ListView getPriorityListView() {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: ReorderableListView(
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = priorityList.removeAt(oldIndex);
                  priorityList.insert(newIndex, item);

                  for (var i = 0; i < priorityCount; i++) {
                    priorityList[i].prioritySort = i;
                    priorityList[i].lastModifiedDT =
                        getFormattedDate(DateTime.now());

                    repository.updatePriority(priorityList[i]);
                  }
                });
              },
              children: List.generate(
                priorityCount,
                (position) {
                  return Dismissible(
                    key: Key(position.toString()),
                    background: slideRightBackground(),
                    secondaryBackground: slideLeftBackground(),
                    child: Card(
                      elevation: 2.0,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepOrangeAccent,
                          child: Text(
                              getFirstLetter(
                                  this.priorityList[position].priorityName),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        title: Text(this.priorityList[position].priorityName,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          navigateToAddEditDetail(this.priorityList[position],
                              PriorityActionType.edit);
                        },
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        final bool res = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                    "Are you sure you want to delete ${this.priorityList[position].priorityName}?"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      // delete priority from db
                                      _delete(
                                          context, this.priorityList[position]);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                        return res;
                      } else {
                        // navigate to edit page;
                        navigateToAddEditDetail(this.priorityList[position],
                            PriorityActionType.edit);
                      }
                      return false;
                    },
                  );
                },
              ).toList(),
            ),
          ),
        )
      ],
    );
  }

  void _delete(BuildContext context, TodoPriority priority) async {
    var token = Provider.of<Model>(context, listen: false).token;

    Future<bool> isAnyTaskUsingPriority = repository.isAnyTaskUsingCategory(priority.id);
    isAnyTaskUsingPriority.then((value) => {
      if (value) {
        // priority is used by a task/tasks, can't delete
        _showAlertDialog('Status', 'Can not delete ${priority.priorityName}, because it is used by a To-Do Task.')
      } else {
        // priority isn't in use, can be deleted
        if (token.length != 0) {
          deletePriorityFromServer(token, priority.serverId),
        },

        repository.deletePriority(priority.id),
        updateListView(),
        _showAlertDialog('Status', '${priority.priorityName} has been deleted.'),
      }
    });
  }

  void navigateToAddEditDetail(
      TodoPriority priority, PriorityActionType actionType) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PrioritiesAddEditScreen(priority, actionType);
    }));

    if (result != null) {
      updateListView();
    }
  }

  void updateListView() {
    var token = Provider.of<Model>(context, listen: false).token;
    if (token.length != 0) {
      syncPrioritiesFetchItems(token);
    }

    Future<List<TodoPriority>> todoPriorityListFuture =
        repository.getPriorityList();
    todoPriorityListFuture.then((priorityList) {
      setState(() {
        this.priorityList = priorityList;
        this
            .priorityList
            .sort((a, b) => a.prioritySort.compareTo(b.prioritySort));
        this.priorityCount = priorityList.length;
      });
    });
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    if (context != null) {
      showDialog(context: context, builder: (_) => alertDialog);
    }
  }
}
