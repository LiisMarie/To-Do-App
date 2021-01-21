import 'package:HW3/api/api.dart';
import 'package:HW3/database/database_helper.dart';
import 'package:HW3/database/repository.dart';
import 'package:HW3/domain/todo_category.dart';
import 'package:HW3/domain/todo_priority.dart';
import 'package:HW3/domain/todo_task.dart';
import 'package:HW3/providers/model.dart';
import 'package:provider/provider.dart';

Repository repository = Repository();

getToken(context) async {
  var account = await repository.getLoggedInUser();
  if (account != null) {
    var jwt = await updateLoggedInUserToken(account.email, account.password);
    if (jwt.token.isNotEmpty) {
      Provider.of<Model>(context, listen: false).updateToken(jwt.token);
    }
  }
}

syncAll(String token) async {
  syncCategoriesFetchItems(token);
  syncPrioritiesFetchItems(token);
  syncTodoTasksFetchItems(token);
}

syncCategoriesFetchItems(String token) async {
  Future<Iterable> categoriesMapFromServer = fetchAllCategories(token);
  Future<List<TodoCategory>> categoryListFuture = repository.getCategoryList();

  if (categoriesMapFromServer != null && categoryListFuture != null) {
    await syncCategories(token, categoriesMapFromServer, categoryListFuture);
  }
}

syncCategories(String token, Future<Iterable> categoriesMapFromServerFuture, Future<List<TodoCategory>> todoCategoryListFuture) async {
  Iterable categoriesMapFromServer;
  List<TodoCategory> categoriesListFromLocalDB;

  Future<int> backId;  // for storing backId when adding local category to back
  DateTime datetimeLocalCategory;  // for storing local category last modified DT
  DateTime datetimeServerCategory;  // for storing server category last modified DT
  List<int> syncedServerCategoryIds = [];  // for storing server ID's of already synced categories

  // for storing whether category was found from back
  // necessary for identifying whether category was synced yet or not
  bool foundCategoryFromBack = false;

  // get categories from server
  categoriesMapFromServerFuture.then((value) => {
    categoriesMapFromServer = value,

    // get categories from local database list
    todoCategoryListFuture.then((value) => {
      categoriesListFromLocalDB = value,

      if (categoriesListFromLocalDB != null) {
        // go through local categories
        for (var localCategory in categoriesListFromLocalDB) {
          foundCategoryFromBack = false,

            if (localCategory.serverId == -1) {
              // this category currently isn't in server
              // add category to back
              backId = addCategoryToServer(token, localCategory.categoryName, localCategory.categorySort),
              if (backId != null) {
                backId.then((value) => {
                  // add backId to local database
                  localCategory.serverId = value,
                  repository.updateCategory(localCategory),
                })
              }
            } else {
              // this category is in server

              // go through categories received from server
              for (var i = 0; i < categoriesMapFromServer.length; i++) {

                // found corresponding category from server response
                if (categoriesMapFromServer.elementAt(i)['id'] == localCategory.serverId) {
                  foundCategoryFromBack = true,

                  // get last modified dates for both local and server category
                  datetimeLocalCategory = DateTime.parse(localCategory.lastModifiedDT),
                  datetimeServerCategory = DateTime.parse(categoriesMapFromServer.elementAt(i)['syncDT']),

                  if (datetimeServerCategory.compareTo(datetimeLocalCategory) < 0) {
                    // syncDT < lastModified : update in server
                    updateCategoryInServer(token, localCategory.serverId, localCategory.categoryName, localCategory.categorySort),

                    syncedServerCategoryIds.add(localCategory.serverId),
                  } else if (datetimeServerCategory.compareTo(datetimeLocalCategory) > 0) {
                    // syncDT > lastModified : update locally
                    localCategory.categoryName = categoriesMapFromServer.elementAt(i)['todoCategoryName'],
                    localCategory.categorySort = categoriesMapFromServer.elementAt(i)['todoCategorySort'],
                    localCategory.lastModifiedDT = categoriesMapFromServer.elementAt(i)['syncDT'],
                    repository.updateCategory(localCategory),

                    syncedServerCategoryIds.add(localCategory.serverId),
                  } else {
                    // local and server are in sync
                    syncedServerCategoryIds.add(localCategory.serverId),
                  },
                }
              },

              // if local category wasn't found from back then remove category from local
              if (!foundCategoryFromBack) {
                repository.deleteCategory(localCategory.id),
              }
            }
          }
      },
      for (var serverCategory in categoriesMapFromServer) {
        // if category from server has not been synced yet, it means it's not in local DB yet
        if (!syncedServerCategoryIds.contains(serverCategory['id'])) {
          // category from server will be added to local database
          repository.insert(DatabaseHelper.tableCategories,
              new TodoCategory(
                  null,
                  serverCategory['todoCategoryName'],
                  serverCategory['todoCategorySort'],
                  serverCategory['syncDT'],
                  serverCategory['id']).toMap()),
        }
      }
    }),
  });
}

syncPrioritiesFetchItems(String token) async {
  Future<Iterable> prioritiesMapFromServer = fetchAllPriorities(token);
  Future<List<TodoPriority>> priorityListFuture = repository.getPriorityList();

  if (prioritiesMapFromServer != null && priorityListFuture != null) {
    await syncPriorities(token, prioritiesMapFromServer, priorityListFuture);
  }
}

syncPriorities(String token, Future<Iterable> prioritiesMapFromServerFuture, Future<List<TodoPriority>> todoPriorityListFuture) async {
  Iterable prioritiesMapFromServer;
  List<TodoPriority> prioritiesListFromLocalDB;

  Future<int> backId;  // for storing backId when adding local priority to back
  DateTime datetimeLocalPriority;  // for storing local priority last modified DT
  DateTime datetimeServerPriority;  // for storing server priority last modified DT
  List<int> syncedServerPriorityIds = [];  // for storing server ID's of already synced priorities

  // for storing whether priority was found from back
  // necessary for identifying whether priority was synced yet or not
  bool foundPriorityFromBack = false;

  // get priorities from server
  prioritiesMapFromServerFuture.then((value) => {
    prioritiesMapFromServer = value,

    // get priorities from local database list
    todoPriorityListFuture.then((value) => {
      prioritiesListFromLocalDB = value,

      if (prioritiesListFromLocalDB != null) {
        // go through local priorities
        for (var localPriority in prioritiesListFromLocalDB) {
          foundPriorityFromBack = false,

          if (localPriority.serverId == -1) {
            // this priority currently isn't in server
            // add priority to back
            backId = addPriorityToServer(token, localPriority.priorityName, localPriority.prioritySort),
            if (backId != null) {
              backId.then((value) => {
                // add backId to local database
                localPriority.serverId = value,
                repository.updatePriority(localPriority),
              })
            }
          } else {
            // this priority is in server

            // go through priorities received from server
            for (var i = 0; i < prioritiesMapFromServer.length; i++) {

              // found corresponding priority from server response
              if (prioritiesMapFromServer.elementAt(i)['id'] == localPriority.serverId) {
                foundPriorityFromBack = true,

                // get last modified dates for both local and server priority
                datetimeLocalPriority = DateTime.parse(localPriority.lastModifiedDT),
                datetimeServerPriority = DateTime.parse(prioritiesMapFromServer.elementAt(i)['syncDT']),

                if (datetimeServerPriority.compareTo(datetimeLocalPriority) < 0) {
                  // syncDT < lastModified : update in server
                  updatePriorityInServer(token, localPriority.serverId, localPriority.priorityName, localPriority.prioritySort),

                  syncedServerPriorityIds.add(localPriority.serverId),
                } else if (datetimeServerPriority.compareTo(datetimeLocalPriority) > 0) {
                  // syncDT > lastModified : update locally
                  localPriority.priorityName = prioritiesMapFromServer.elementAt(i)['todoPriorityName'],
                  localPriority.prioritySort = prioritiesMapFromServer.elementAt(i)['todoPrioritySort'],
                  localPriority.lastModifiedDT = prioritiesMapFromServer.elementAt(i)['syncDT'],
                  repository.updatePriority(localPriority),

                  syncedServerPriorityIds.add(localPriority.serverId),
                } else {
                  // local and server are in sync
                  syncedServerPriorityIds.add(localPriority.serverId),
                },
              }
            },

            // if local priority wasn't found from back then remove priority from local
            if (!foundPriorityFromBack) {
              repository.deletePriority(localPriority.id),
            }
          }
        }
      },
      for (var serverPriority in prioritiesMapFromServer) {
        // if priority from server has not been synced yet, it means it's not in local DB yet
        if (!syncedServerPriorityIds.contains(serverPriority['id'])) {
          // priority from server will be added to local database
          repository.insert(DatabaseHelper.tablePriorities,
              new TodoPriority(
                  null,
                  serverPriority['todoPriorityName'],
                  serverPriority['todoPrioritySort'],
                  serverPriority['syncDT'],
                  serverPriority['id']).toMap()),
        }
      }
    }),
  });
}

syncTodoTasksFetchItems(String token) async {
  Future<Iterable> tasksMapFromServer = fetchAllTasks(token);
  Future<List<TodoTask>> taskListFuture = repository.getTaskList();

  if (tasksMapFromServer != null && taskListFuture != null) {
    await syncTodoTasks(token, tasksMapFromServer, taskListFuture);
  }
}

syncTodoTasks(String token, Future<Iterable> categoriesMapFromServerFuture, Future<List<TodoTask>> todoCategoryListFuture) async {
  Iterable tasksMapFromServer;
  List<TodoTask> tasksListFromLocalDB;

  Future<int> backId;  // for storing backId when adding local task to back
  DateTime datetimeLocalTask;  // for storing local task last modified DT
  DateTime datetimeServerTask;  // for storing server task last modified DT
  List<int> syncedServerTaskIds = [];  // for storing server ID's of already synced tasks

  // for storing whether task was found from back
  // necessary for identifying whether task was synced yet or not
  bool foundTaskFromBack = false;

  // get tasks from server
  categoriesMapFromServerFuture.then((value) => {
    tasksMapFromServer = value,

    // get tasks from local database list
    todoCategoryListFuture.then((value) => {
      tasksListFromLocalDB = value,

      if (tasksListFromLocalDB != null) {
        // go through local tasks
        for (var localTask in tasksListFromLocalDB) {
          foundTaskFromBack = false,

          if (localTask.serverId == -1) {
            // this task currently isn't in server
            // add task to back
            repository.getPriorityById(localTask.taskPriority).then((priority) => {
              repository.getCategoryById(localTask.taskCategory).then((category) => {
                if (priority.serverId != -1 && category.serverId != -1) {
                  backId = addTaskToServer(
                      token,
                      localTask.taskName,
                      localTask.taskSort,
                      localTask.taskDueDT,
                      localTask.isCompletedAsBoolean,
                      localTask.isArchivedAsBoolean,
                      category.serverId,
                      priority.serverId),

                  if (backId != null) {
                    backId.then((value) => {
                      // add backId to local database
                      localTask.serverId = value,
                      repository.updateTask(localTask),
                    })
                  }
                },
              },
              ),
            }),
          } else {
            // this task is in server

            // go through tasks received from server
            for (var i = 0; i < tasksMapFromServer.length; i++) {

              // found corresponding task from server response
              if (tasksMapFromServer.elementAt(i)['id'] == localTask.serverId) {
                foundTaskFromBack = true,

                // get last modified dates for both local and server task
                datetimeLocalTask = DateTime.parse(localTask.lastModifiedDT),
                datetimeServerTask = DateTime.parse(tasksMapFromServer.elementAt(i)['syncDT']),


                if (datetimeServerTask.compareTo(datetimeLocalTask) < 0) {
                  // syncDT < lastModified : update in server
                  repository.getPriorityById(localTask.taskPriority).then((priority) => {
                    repository.getCategoryById(localTask.taskCategory).then((category) => {
                      if (priority.serverId != -1 && category.serverId != -1) {
                        updateTaskInServer(
                            token,
                            localTask.serverId,
                            localTask.taskName,
                            localTask.taskSort,
                            localTask.taskDueDT,
                            localTask.isCompletedAsBoolean,
                            localTask.isArchivedAsBoolean,
                            category.serverId,
                            priority.serverId),
                      },
                    },
                    ),
                  }),
                  syncedServerTaskIds.add(localTask.serverId),
                } else if (datetimeServerTask.compareTo(datetimeLocalTask) > 0) {
                  // syncDT > lastModified : update locally
                  localTask.taskName = tasksMapFromServer.elementAt(i)['todoTaskName'],
                  localTask.taskSort = tasksMapFromServer.elementAt(i)['todoTaskSort'],
                  localTask.taskDueDT = tasksMapFromServer.elementAt(i)['dueDT'],
                  localTask.isCompleted = tasksMapFromServer.elementAt(i)['isCompleted'] ? 1 : 0,
                  localTask.isArchived = tasksMapFromServer.elementAt(i)['isArchived'] ? 1 : 0,
                  localTask.lastModifiedDT = tasksMapFromServer.elementAt(i)['syncDT'],

                  repository.getPriorityByServerId(tasksMapFromServer.elementAt(i)['todoPriorityId']).then((priority) => {
                    repository.getCategoryByServerId(tasksMapFromServer.elementAt(i)['todoCategoryId']).then((category) => {
                      localTask.taskCategory = category.id,
                      localTask.taskPriority = priority.id,

                      repository.updateTask(localTask),
                    })
                  }),

                  syncedServerTaskIds.add(localTask.serverId),
                } else {
                  // local and server are in sync
                  syncedServerTaskIds.add(localTask.serverId),
                },
              }
            },

            // if local task wasn't found from back then remove task from local
            if (!foundTaskFromBack) {
              repository.deleteTask(localTask.id),
            }
          }
        }
      },
      for (var serverTask in tasksMapFromServer) {
        // if task from server has not been synced yet, it means it's not in local DB yet
        if (!syncedServerTaskIds.contains(serverTask['id'])) {
          // task from server will be added to local database
          repository.getPriorityByServerId(serverTask['todoPriorityId']).then((priority) => {
            repository.getCategoryByServerId(serverTask['todoCategoryId']).then((category) => {
              repository.insert(DatabaseHelper.tableTodoTasks, new TodoTask(
                  null,
                  serverTask['todoTaskName'],
                  serverTask['todoTaskSort'],
                  serverTask['dueDT'],
                  serverTask['isCompleted'] ? 1 : 0,
                  serverTask['isArchived'] ? 1 : 0,
                  category.id,
                  priority.id,
                  serverTask['syncDT'],
                  serverTask['id']).toMap()),
            })
          }),
        }
      }
    }),
  });
}
