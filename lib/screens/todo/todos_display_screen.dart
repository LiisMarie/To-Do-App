import 'dart:async';

import 'package:HW3/api/api.dart';
import 'package:HW3/database/repository.dart';
import 'package:HW3/domain/account.dart';
import 'package:HW3/domain/todo_task.dart';
import 'package:HW3/domain/todo_category.dart';
import 'package:HW3/domain/todo_priority.dart';
import 'package:HW3/helpers/helpers.dart';
import 'package:HW3/helpers/sync_helpers.dart';
import 'package:HW3/providers/model.dart';
import 'package:HW3/screens/menu_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todos_add_edit_screen.dart';

class TodosDisplayScreen extends StatefulWidget {
  @override
  _TodosDisplayScreenState createState() => _TodosDisplayScreenState();
}

class _TodosDisplayScreenState extends State<TodosDisplayScreen> {
  final repository = Repository();

  Account loggedInAccount;

  List<TodoTask> taskList;
  int taskCount = 0;

  // stores what to display
  // [ not done, done, all ]
  List<bool> _toDisplay = [true, false, false];

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
    if (taskList == null) {
      taskList = List<TodoTask>();
      updateListView();
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: getTasksListView(),
      drawer: MenuItems(),
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('Tasks'),
      bottom: PreferredSize(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: ToggleButtons(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              constraints: BoxConstraints.tight(Size(80, 30)),
              textStyle: TextStyle(fontWeight: FontWeight.bold),
              color: Colors.white,
              selectedColor: Colors.white,
              fillColor: Colors.blueGrey,
              children: <Widget>[
                Text('TO DO'),
                Text('DONE'),
                Text('ALL'),
              ],
              isSelected: _toDisplay,
              onPressed: (int index) {
                setState(() {
                  _toDisplay[0] = false;
                  _toDisplay[1] = false;
                  _toDisplay[2] = false;
                  _toDisplay[index] = true;
                });
              },
            ),
          ),
        ),
        preferredSize: Size.fromHeight(40.0),
      ),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: () {
        navigateToAddEditDetail(
            TodoTask(null, '', 0, '', 0, 0, -1, -1, '', null),
            TodosActionType.add);
      },
      tooltip: 'Add Priority',
      child: Icon(Icons.add),
    );
  }

  ListView getTasksListView() {
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
                  final item = taskList.removeAt(oldIndex);
                  taskList.insert(newIndex, item);

                  for (var i = 0; i < taskCount; i++) {
                    taskList[i].taskSort = i;
                    taskList[i].lastModifiedDT =
                        getFormattedDate(DateTime.now());
                    repository.updateTask(taskList[i]);
                  }
                });
              },
              children: List.generate(
                taskCount,
                (position) {
                  return Dismissible(
                    key: Key(position.toString()),
                    background: slideRightBackground(),
                    secondaryBackground: slideLeftBackground(),
                    child: shouldTaskBeShown(
                            this.taskList[position].isCompletedAsBoolean)
                        ? Card(
                            elevation: 2.0,
                            child: _buildListTile(taskList[position]),
                          )
                        : Container(),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        final bool res = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                    "Are you sure you want to delete ${this.taskList[position].taskName}?"),
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
                                      _delete(context, this.taskList[position]);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                        return res;
                      } else {
                        // navigate to edit page;
                        navigateToAddEditDetail(
                            this.taskList[position], TodosActionType.edit);
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

  Widget _buildListTile(TodoTask todoTask) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: Checkbox(
        value: todoTask.isCompletedAsBoolean,
        onChanged: (newValue) {
          setState(() {
            todoTask.isCompleted = todoTask.isCompleted == 0 ? 1 : 0;
            todoTask.lastModifiedDT = getFormattedDate(DateTime.now());
            repository.updateTask(todoTask);
          });
        },
      ),
      title: Text(
        todoTask.taskName,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.transparent, height: 7),
          Container(
            child: FutureBuilder<TodoCategory>(
              future: repository.getCategoryById(todoTask.taskCategory),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircleAvatar(
                          backgroundColor: Colors.teal,
                          radius: 13,
                          child: Icon(Icons.category,
                              size: 15, color: Colors.white),
                        ),
                      ),
                      Text(snapshot.data.categoryName),
                    ],
                  );
                }
                return Container();
              },
            ),
          ),
          Divider(color: Colors.transparent, height: 4),
          Container(
            child: FutureBuilder<TodoPriority>(
              future: repository.getPriorityById(todoTask.taskPriority),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircleAvatar(
                          backgroundColor: Colors.deepOrangeAccent,
                          radius: 13,
                          child: Icon(Icons.priority_high,
                              size: 15, color: Colors.white),
                        ),
                      ),
                      Text(snapshot.data.priorityName),
                    ],
                  );
                }
                return Container();
              },
            ),
          ),
          todoTask.taskDueDT != null
              ? Divider(color: Colors.transparent, height: 15)
              : Container(),
          _buildDueDate(todoTask),
        ],
      ),
      onTap: () {
        navigateToAddEditDetail(todoTask, TodosActionType.edit);
      },
    );
  }

  Widget _buildDueDate(TodoTask todoTask) {
    if (todoTask.taskDueDT == null) {
      return Container();
    }
    if (todoTask.taskDueDT.length == 0) {
      return Container();
    }

    String dueDTString = todoTask.taskDueDT;
    Color color = Colors.black;
    DateTime dueDateTime = DateTime.parse(dueDTString);
    final nowDateTime = DateTime.now();

    bool showTag = false;
    String tagText = '';
    if (dueDateTime.difference(nowDateTime).inHours <= 24) {
      color = Colors.orange;
      showTag = true;
      tagText = 'DUE SOON';
    }
    if (dueDateTime.isBefore(nowDateTime) && !todoTask.isCompletedAsBoolean) {
      showTag = true;
      color = Colors.red;
      tagText = 'OVERDUE';
    }
    if (todoTask.isCompletedAsBoolean) {
      showTag = true;
      color = Colors.green;
      tagText = 'COMPLETE';
    }
    return Row(
      children: [
        Text(
          '${dueDateTime.day}.${dueDateTime.month}.${dueDateTime.year} ${dueDateTime.hour}:${dueDateTime.minute}  ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        showTag
            ? Text(
                '  ' + tagText + '  ',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    backgroundColor: color),
              )
            : Container(),
      ],
    );
  }

  void _delete(BuildContext context, TodoTask task) async {
    var token = Provider.of<Model>(context, listen: false).token;
    if (token.length != 0) {
      deleteTaskFromServer(token, task.serverId);
    }

    await repository.deleteTask(task.id);
    updateListView();
  }

  void navigateToAddEditDetail(
      TodoTask task, TodosActionType actionType) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TodosAddEditScreen(task, actionType);
    }));

    if (result != null) {
      updateListView();
    }
  }

  void updateListView() {
    var token = Provider.of<Model>(context, listen: false).token;
    if (token.length != 0) {
      syncAll(token);
    }

    Future<List<TodoTask>> todoTaskListFuture = repository.getTaskList();
    todoTaskListFuture.then((todoList) {
      setState(() {
        this.taskList = todoList;
        this.taskList.sort((a, b) => a.taskSort.compareTo(b.taskSort));
        this.taskCount = todoList.length;
      });
    });
  }

  // for filtering by TO DO, DONE, ALL
  bool shouldTaskBeShown(bool isComplete) {
    if (_toDisplay[0]) {
      if (!isComplete) return true;
    }
    if (_toDisplay[1]) {
      if (isComplete) return true;
    }
    if (_toDisplay[2]) return true;
    return false;
  }
}
