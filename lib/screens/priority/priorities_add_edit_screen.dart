import 'package:HW3/api/api.dart';
import 'package:HW3/domain/todo_priority.dart';
import 'package:HW3/helpers/helpers.dart';
import 'package:HW3/providers/model.dart';
import 'package:flutter/material.dart';
import 'package:HW3/database/database_helper.dart';
import 'package:HW3/database/repository.dart';
import 'package:provider/provider.dart';

class PrioritiesAddEditScreen extends StatefulWidget {
  final PriorityActionType actionType;
  final TodoPriority priority;

  PrioritiesAddEditScreen(this.priority, this.actionType);

  @override
  State<StatefulWidget> createState() {
    return PrioritiesAddEditScreenState(this.priority, this.actionType);
  }
}

enum PriorityActionType { add, edit }

class PrioritiesAddEditScreenState extends State<PrioritiesAddEditScreen> {
  Repository repository = Repository();

  PriorityActionType actionType;
  TodoPriority priority;

  TextEditingController priorityNameController = TextEditingController();

  PrioritiesAddEditScreenState(this.priority, this.actionType);

  @override
  Widget build(BuildContext context) {
    priorityNameController.text = priority.priorityName;

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
                _buildTextField(),
                Divider(color: Colors.transparent),
                _buildSaveButton(),
              ],
            ),
          ),
        ));
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(widget.actionType == PriorityActionType.add
          ? "Add Priority"
          : "Edit Priority"),
      actions: <Widget>[
        this.actionType == PriorityActionType.edit
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
                        "Are you sure you want to delete ${priority.priorityName}?"),
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
                          // delete priority from db
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

  Widget _buildTextField() {
    return Column(
      children: [
        TextField(
            maxLength: 128,
            controller: priorityNameController,
            onChanged: (value) {
              updatePriorityName();
            },
            decoration:
                InputDecoration(labelText: 'Name', icon: Icon(Icons.title))),
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

  // Update the name of priority
  void updatePriorityName() {
    priority.priorityName = priorityNameController.text;
  }

  // Save data to database
  void _save() async {
    if (priority.priorityName == "") {
      _showAlertDialog('Status', 'Priority must have a Name!');
      return;
    }

    if (priority.priorityName.length > 128) {
      _showAlertDialog('Status', 'Priority Name max length is 128 characters!');
      return;
    }

    moveToLastScreen();

    int result;

    priority.lastModifiedDT = getFormattedDate(DateTime.now());
    if (actionType == PriorityActionType.add) {
      priority.prioritySort = -1;
    }

    if (priority.id != null) {
      // Case 1: Update operation
      // update locally
      result = await repository.updatePriority(priority);

      // update in back
      var token = Provider.of<Model>(context, listen: false).token;
      if (token.length != 0) {
        updatePriorityInServer(token, priority.serverId, priority.priorityName,
            priority.prioritySort);
      }
    } else {
      // Case 2: Insert Operation
      // add to local, later with sync it will be added to back
      priority.serverId = -1;
      result = await repository.insert(
          DatabaseHelper.tablePriorities, priority.toMap());
    }

    if (result != 0) {
      // Success
      String action =
          actionType == PriorityActionType.edit ? "Updated" : "Saved";
      _showAlertDialog('Status', 'Priority $action Successfully');
    } else {
      // Failure
      String action =
          actionType == PriorityActionType.edit ? "Updating" : "Saving";
      _showAlertDialog('Status', 'Problem $action Priority');
    }
  }

  void _delete() async {
    moveToLastScreen();

    var token = Provider.of<Model>(context, listen: false).token;

    Future<bool> isAnyTaskUsingPriority = repository.isAnyTaskUsingPriority(priority.id);
    isAnyTaskUsingPriority.then((value) => {
      if (value) {
        // priority is used by a task/tasks, can't delete
        _showAlertDialog('Status', 'Can not delete ${priority.priorityName}, because it is used by a To-Do Task.'),
      } else {
        // priority isn't used, delete priority from db
        if (token.length != 0) {
          deletePriorityFromServer(token, priority.serverId),
        },
        repository.deletePriority(priority.id),
        _showAlertDialog('Status', '${priority.priorityName} has been deleted.'),
      }
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
