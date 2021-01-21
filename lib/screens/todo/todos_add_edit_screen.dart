import 'package:HW3/domain/todo_category.dart';
import 'package:HW3/domain/todo_priority.dart';
import 'package:date_time_picker/date_time_picker.dart';

import 'package:HW3/api/api.dart';
import 'package:HW3/domain/todo_task.dart';
import 'package:HW3/helpers/helpers.dart';
import 'package:HW3/providers/model.dart';
import 'package:flutter/material.dart';
import 'package:HW3/database/database_helper.dart';
import 'package:HW3/database/repository.dart';
import 'package:provider/provider.dart';

class TodosAddEditScreen extends StatefulWidget {
  final TodosActionType actionType;
  final TodoTask todoTask;

  TodosAddEditScreen(this.todoTask, this.actionType);

  @override
  State<StatefulWidget> createState() {
    return TodosAddEditScreenState(this.todoTask, this.actionType);
  }
}

enum TodosActionType { add, edit }

class TodosAddEditScreenState extends State<TodosAddEditScreen> {
  Repository repository = Repository();

  TodosActionType actionType;
  TodoTask todoTask;

  List<TodoPriority> priorityList = new List();
  List<TodoCategory> categoryList = new List();

  TextEditingController todoTaskNameController = TextEditingController();

  TodoPriority priorityDropdownValue;
  TodoCategory categoryDropdownValue;

  TodosAddEditScreenState(this.todoTask, this.actionType);

  @override
  Widget build(BuildContext context) {
    todoTaskNameController.text = todoTask.taskName;

    if (priorityList.length == 0) {
      getPriorities();
    }
    if (categoryList.length == 0) {
      getCategories();
    }

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                _buildForm(),
                Divider(color: Colors.transparent),
                _buildSaveButton(),
              ],
            ),
          ),
        ));
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(
          widget.actionType == TodosActionType.add ? "Add Todo" : "Edit Todo"),
      actions: <Widget>[
        this.actionType == TodosActionType.edit
            ? _buildDeleteButton()
            : Container(),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
        onPressed: () {
          setState(() {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text(
                        "Are you sure you want to delete ${todoTask.taskName}?"),
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
                          Navigator.of(context).pop();
                          _delete();
                        },
                      ),
                    ],
                  );
                });
          });
        },
        icon: Icon(Icons.delete));
  }

  Widget _buildForm() {
    return Column(
      children: [
        TextField(
          maxLength: 128,
          controller: todoTaskNameController,
          onChanged: (value) {
            updateTaskName();
          },
          decoration:
              InputDecoration(labelText: 'Name', icon: Icon(Icons.title)),
        ),

        Divider(color: Colors.transparent),

        // Dropdown for category
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(
                Icons.category,
                color: Colors.grey,
              ),
            ),
            DropdownButton(
              underline: SizedBox(),
              value: categoryDropdownValue,
              items: this.categoryList.map((TodoCategory category) {
                return new DropdownMenuItem<TodoCategory>(
                  value: category,
                  child: new Text(category.categoryName),
                );
              }).toList(),
              hint: Container(
                child: Text('Select category'),
              ),
              onChanged: (TodoCategory newValue) {
                setState(() {
                  categoryDropdownValue = newValue;
                });
                todoTask.taskCategory = newValue.id;
              },
            ),
          ],
        ),

        Divider(color: Colors.transparent),

        // Dropdown for priority
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(
                Icons.priority_high,
                color: Colors.grey,
              ),
            ),
            DropdownButton(
              underline: SizedBox(),
              value: priorityDropdownValue,
              items: this.priorityList.map((TodoPriority priority) {
                return new DropdownMenuItem<TodoPriority>(
                  value: priority,
                  child: new Text(priority.priorityName),
                );
              }).toList(),
              onChanged: (TodoPriority newValue) {
                setState(() {
                  priorityDropdownValue = newValue;
                });
                todoTask.taskPriority = newValue.id;
              },
              hint: Container(
                child: Text('Select priority'),
              ),
            ),
          ],
        ),

        Divider(color: Colors.transparent),

        // Datetimepicker for due date
        DateTimePicker(
          type: DateTimePickerType.dateTimeSeparate,
          dateMask: 'd MMM, yyyy',
          initialValue: todoTask.taskDueDT,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          icon: Icon(Icons.event),
          dateLabelText: 'Due Date',
          timeLabelText: 'Hour',
          onChanged: (val) => todoTask.taskDueDT = val,
          onSaved: (val) => todoTask.taskDueDT = val,
        ),

        Divider(color: Colors.transparent),

        // Completed check, visible only when editing
        this.actionType == TodosActionType.edit
            ? CheckboxListTile(
                title: Text("Completed"),
                value: todoTask.isCompletedAsBoolean,
                onChanged: (newValue) {
                  setState(() {
                    todoTask.isCompleted = todoTask.isCompleted == 0 ? 1 : 0;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              )
            : Container(),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: Column(
        children: <Widget>[
          ElevatedButton(
            child: Text(
              'Save',
              textScaleFactor: 1.3,
            ),
            onPressed: () {
              setState(() {
                _save();
              });
            },
          ),
        ],
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Update the name of task
  void updateTaskName() {
    todoTask.taskName = todoTaskNameController.text;
  }

  void getPriorities() {
    Future<List<TodoPriority>> todoPriorityListFuture =
        repository.getPriorityList();
    todoPriorityListFuture.then((priorityList) {
      setState(() {
        this.priorityList = priorityList;
        this
            .priorityList
            .sort((a, b) => a.prioritySort.compareTo(b.prioritySort));
      });
      // If editing a task then set tasks current priority to be visible in the dropdown
      if (actionType == TodosActionType.edit) {
        for (TodoPriority priority in priorityList) {
          if (priority.id == todoTask.taskPriority) {
            priorityDropdownValue = priority;
          }
        }
      }
    });
  }

  void getCategories() {
    Future<List<TodoCategory>> todoCategoryListFuture =
        repository.getCategoryList();
    todoCategoryListFuture.then((categoryList) {
      setState(() {
        this.categoryList = categoryList;
        this
            .categoryList
            .sort((a, b) => a.categorySort.compareTo(b.categorySort));
      });
      // If editing a task then set tasks current category to be visible in the dropdown
      if (actionType == TodosActionType.edit) {
        for (TodoCategory category in categoryList) {
          if (category.id == todoTask.taskCategory) {
            categoryDropdownValue = category;
          }
        }
      }
    });
  }

  // Save data to database
  void _save() async {
    if (todoTask.taskName == "") {
      _showAlertDialog('Status', 'Todo must have a Name!');
      return;
    }

    if (todoTask.taskName.length > 128) {
      _showAlertDialog('Status', 'Todo Name max length is 128 characters!');
      return;
    }

    if (categoryDropdownValue == null) {
      _showAlertDialog('Status', 'Todo must have a Category!');
      return;
    }

    if (priorityDropdownValue == null) {
      _showAlertDialog('Status', 'Todo must have a Priority!');
      return;
    }

    moveToLastScreen();

    int result;

    todoTask.lastModifiedDT = getFormattedDate(DateTime.now());
    if (actionType == TodosActionType.add) {
      // to make new task go to top of the list
      todoTask.taskSort = -1;
    }

    if (todoTask.taskDueDT != null) {
      if (todoTask.taskDueDT.length == 0) {
        todoTask.taskDueDT = null;
      }
    }

    if (todoTask.id != null) {
      // Case 1: Update operation
      // update locally
      result = await repository.updateTask(todoTask);

      // update in back
      var token = Provider.of<Model>(context, listen: false).token;
      if (token.length != 0) {
        var isCompleted = todoTask.isCompleted == 0 ? false : true;
        var isArchived = todoTask.isArchived == 0 ? false : true;
        updateTaskInServer(
            token,
            todoTask.serverId,
            todoTask.taskName,
            todoTask.taskSort,
            todoTask.taskDueDT,
            isCompleted,
            isArchived,
            categoryDropdownValue.serverId,
            priorityDropdownValue.serverId);
      }
    } else {
      // Case 2: Insert Operation
      // add to local, later with sync it will be added to back
      todoTask.serverId = -1;
      result = await repository.insert(
          DatabaseHelper.tableTodoTasks, todoTask.toMap());
    }

    if (result != 0) {
      // Success
      String action = actionType == TodosActionType.edit ? "Updated" : "Saved";
      _showAlertDialog('Status', 'Todo $action Successfully');
    } else {
      // Failure
      String action =
          actionType == TodosActionType.edit ? "Updating" : "Saving";
      _showAlertDialog('Status', 'Problem $action Todo');
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (todoTask.id == null) {
      _showAlertDialog('Status', 'No Todo was deleted');
      return;
    }

    var token = Provider.of<Model>(context, listen: false).token;
    if (token.length != 0) {
      deleteTaskFromServer(token, todoTask.serverId);
    }

    int result = await repository.deleteTask(todoTask.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Todo Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occurred while Deleting Todo');
    }
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
