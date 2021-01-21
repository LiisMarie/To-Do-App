import 'package:HW3/api/api.dart';
import 'package:HW3/helpers/helpers.dart';
import 'package:HW3/providers/model.dart';
import 'package:flutter/material.dart';
import 'package:HW3/database/database_helper.dart';
import 'package:HW3/database/repository.dart';
import 'package:HW3/domain/todo_category.dart';
import 'package:provider/provider.dart';

class CategoriesAddEditScreen extends StatefulWidget {
  final CategoryActionType actionType;
  final TodoCategory category;

  CategoriesAddEditScreen(this.category, this.actionType);

  @override
  State<StatefulWidget> createState() {
    return CategoriesAddEditScreenState(this.category, this.actionType);
  }
}

enum CategoryActionType { add, edit }

class CategoriesAddEditScreenState extends State<CategoriesAddEditScreen> {
  Repository repository = Repository();

  CategoryActionType actionType;
  TodoCategory category;

  TextEditingController categoryNameController = TextEditingController();

  CategoriesAddEditScreenState(this.category, this.actionType);

  @override
  Widget build(BuildContext context) {
    categoryNameController.text = category.categoryName;

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
      title: Text(widget.actionType == CategoryActionType.add
          ? "Add Category"
          : "Edit Category"),
      actions: <Widget>[
        this.actionType == CategoryActionType.edit
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
                        "Are you sure you want to delete ${category.categoryName}?"),
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
                          // delete category from db
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
            controller: categoryNameController,
            onChanged: (value) {
              updateCategoryName();
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

  // Update the name of category
  void updateCategoryName() {
    category.categoryName = categoryNameController.text;
  }

  // Save data to database
  void _save() async {
    if (category.categoryName == "") {
      _showAlertDialog('Status', 'Category must have a Name!');
      return;
    }

    if (category.categoryName.length > 128) {
      _showAlertDialog('Status', 'Category Name max length is 128 characters!');
      return;
    }

    moveToLastScreen();

    int result;

    category.lastModifiedDT = getFormattedDate(DateTime.now());
    if (actionType == CategoryActionType.add) {
      category.categorySort = -1;
    }

    if (category.id != null) {
      // Case 1: Update operation
      // update locally
      result = await repository.updateCategory(category);

      // update in back
      var token = Provider.of<Model>(context, listen: false).token;
      if (token.length != 0) {
        updateCategoryInServer(token, category.serverId, category.categoryName,
            category.categorySort);
      }
    } else {
      // Case 2: Insert Operation
      // add to local, later with sync it will be added to back
      category.serverId = -1;
      result = await repository.insert(
          DatabaseHelper.tableCategories, category.toMap());
    }

    if (result != 0) {
      // Success
      String action =
          actionType == CategoryActionType.edit ? "Updated" : "Saved";
      _showAlertDialog('Status', 'Category $action Successfully');
    } else {
      // Failure
      String action =
          actionType == CategoryActionType.edit ? "Updating" : "Saving";
      _showAlertDialog('Status', 'Problem $action Category');
    }
  }

  void _delete() async {
    moveToLastScreen();

    var token = Provider.of<Model>(context, listen: false).token;

    Future<bool> isAnyTaskUsingCategory = repository.isAnyTaskUsingCategory(category.id);
    isAnyTaskUsingCategory.then((value) => {
      if (value) {
        // category is used by a task/tasks, can't delete
        _showAlertDialog('Status', 'Can not delete ${category.categoryName}, because it is used by a To-Do Task.'),
      } else {
        // category isn't used, delete category from db
        if (token.length != 0) {
          deleteCategoryFromServer(token, category.serverId),
        },
        repository.deleteCategory(category.id),
        _showAlertDialog('Status', '${category.categoryName} has been deleted.'),
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
