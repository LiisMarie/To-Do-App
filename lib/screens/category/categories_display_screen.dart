import 'dart:async';

import 'package:HW3/api/api.dart';
import 'package:HW3/database/repository.dart';
import 'package:HW3/domain/account.dart';
import 'package:HW3/domain/todo_category.dart';
import 'package:HW3/helpers/helpers.dart';
import 'package:HW3/helpers/sync_helpers.dart';
import 'package:HW3/providers/model.dart';
import 'package:HW3/screens/menu_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'categories_add_edit_screen.dart';

class CategoriesDisplayScreen extends StatefulWidget {
  @override
  _CategoriesDisplayScreenState createState() =>
      _CategoriesDisplayScreenState();
}

class _CategoriesDisplayScreenState extends State<CategoriesDisplayScreen> {
  final repository = Repository();

  Account loggedInAccount;

  List<TodoCategory> categoryList;
  int categoryCount = 0;

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
    if (categoryList == null) {
      categoryList = List<TodoCategory>();
      updateListView();
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        child: getCategoryListView(),
      ),
      drawer: MenuItems(),
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('Categories'),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: () {
        navigateToAddEditDetail(
            TodoCategory(null, '', 0, '', null), CategoryActionType.add);
      },
      tooltip: 'Add Category',
      child: Icon(Icons.add),
    );
  }

  ListView getCategoryListView() {
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
                  final item = categoryList.removeAt(oldIndex);
                  categoryList.insert(newIndex, item);

                  for (var i = 0; i < categoryCount; i++) {
                    categoryList[i].categorySort = i;
                    categoryList[i].lastModifiedDT =
                        getFormattedDate(DateTime.now());

                    repository.updateCategory(categoryList[i]);
                  }
                });
              },
              children: List.generate(
                categoryCount,
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
                          backgroundColor: Colors.teal,
                          child: Text(
                              getFirstLetter(
                                  this.categoryList[position].categoryName),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        title: Text(this.categoryList[position].categoryName,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          navigateToAddEditDetail(this.categoryList[position],
                              CategoryActionType.edit);
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
                                    "Are you sure you want to delete ${this.categoryList[position].categoryName}?"),
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
                                      // delete category from db
                                      _delete(
                                          context, this.categoryList[position]);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                        return res;
                      } else {
                        // navigate to edit page;
                        navigateToAddEditDetail(this.categoryList[position],
                            CategoryActionType.edit);
                      }
                      return false;
                    },
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _delete(BuildContext context, TodoCategory category) async {
    var token = Provider.of<Model>(context, listen: false).token;

    Future<bool> isAnyTaskUsingCategory = repository.isAnyTaskUsingCategory(category.id);
    isAnyTaskUsingCategory.then((value) => {
      if (value) {
        // category is used by a task/tasks, can't delete
        _showAlertDialog('Status', 'Can not delete ${category.categoryName}, because it is used by a To-Do Task.')
      } else {
        // category isn't in use, can be deleted
        if (token.length != 0) {
          deleteCategoryFromServer(token, category.serverId),
        },

        repository.deleteCategory(category.id),
        updateListView(),
        _showAlertDialog('Status', '${category.categoryName} has been deleted.'),
      }
    });
  }

  void navigateToAddEditDetail(
      TodoCategory category, CategoryActionType actionType) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CategoriesAddEditScreen(category, actionType);
    }));

    if (result != null) {
      updateListView();
    }
  }

  void updateListView() {
    var token = Provider.of<Model>(context, listen: false).token;
    if (token.length != 0) {
      syncCategoriesFetchItems(token);
    }

    Future<List<TodoCategory>> todoCategoryListFuture =
        repository.getCategoryList();
    todoCategoryListFuture.then((categoryList) {
      setState(() {
        this.categoryList = categoryList;
        this
            .categoryList
            .sort((a, b) => a.categorySort.compareTo(b.categorySort));
        this.categoryCount = categoryList.length;
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
