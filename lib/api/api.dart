import 'dart:convert';
import 'dart:core';

import 'package:HW3/domain/jwt.dart';
import 'package:HW3/screens/auth/login_register_screen.dart';

import 'package:http/http.dart' as http;

const url = 'https://taltech.akaver.com/api/v1';

Future<JWT> fetchToken(String email, String password, FormType action) async {
  // get token from server
  Map<String, String> headers = {"Content-Type": "application/json"};
  final response = await http.post(
      '$url/account/${action == FormType.login ? 'login' : 'register'}',
      headers: headers,
      body: jsonEncode({
        "email": email,
        "password": password,
      }));
  if (response.statusCode == 200) {
    return JWT.fromJson(json.decode(response.body));
  } else {
    return JWT(token: "", status: response.reasonPhrase);
  }
}

Future<JWT> updateLoggedInUserToken(String email, String password) async {
  // login user to get new fresh token
  return fetchToken(email, password, FormType.login);
}

// CATEGORY

Future<Iterable> fetchAllCategories(String token) async {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };
  final response = await http.get(
    '$url/ToDoCategories',
    headers: headers,
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return null;
  }
}

Future<int> addCategoryToServer(
    String token, String categoryName, int categorySort) async {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };
  final response = await http.post('$url/ToDoCategories',
      headers: headers,
      body: jsonEncode({
        "todoCategoryName": categoryName,
        "todoCategorySort": categorySort
      }));
  if (response.statusCode == 201) {
    // return category's server id
    return json.decode(response.body)['id'];
  } else {
    return null;
  }
}

Future<void> deleteCategoryFromServer(String token, int categoryId) async {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };
  await http.delete('$url/ToDoCategories/$categoryId', headers: headers);
}

Future<void> updateCategoryInServer(
    String token, int categoryId, String categoryName, int categorySort) async {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };
  await http.put('$url/ToDoCategories/$categoryId',
      headers: headers,
      body: jsonEncode({
        "id": categoryId,
        "todoCategoryName": categoryName,
        "todoCategorySort": categorySort
      }));
}

// PRIORITY

Future<Iterable> fetchAllPriorities(String token) async {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };
  final response = await http.get(
    '$url/ToDoPriorities',
    headers: headers,
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return null;
  }
}

Future<int> addPriorityToServer(
    String token, String priorityName, int prioritySort) async {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };
  final response = await http.post('$url/ToDoPriorities',
      headers: headers,
      body: jsonEncode({
        "todoPriorityName": priorityName,
        "todoPrioritySort": prioritySort
      }));
  if (response.statusCode == 201) {
    // return priorities server id
    return json.decode(response.body)['id'];
  } else {
    return null;
  }
}

Future<void> deletePriorityFromServer(String token, int priorityId) async {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };
  await http.delete('$url/ToDoPriorities/$priorityId', headers: headers);
}

Future<void> updatePriorityInServer(
    String token, int priorityId, String priorityName, int prioritySort) async {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };
  await http.put('$url/ToDoPriorities/$priorityId',
      headers: headers,
      body: jsonEncode({
        "id": priorityId,
        "todoPriorityName": priorityName,
        "todoPrioritySort": prioritySort
      }));
}

// TodoTasks

Future<Iterable> fetchAllTasks(String token) async {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };
  final response = await http.get(
    '$url/ToDoTasks',
    headers: headers,
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return null;
  }
}

Future<int> addTaskToServer(
    String token,
    String taskName,
    int taskSort,
    String dueDT,
    bool isCompleted,
    bool isArchived,
    int todoCategoryId,
    int todoPriorityId) async {

  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };

  var body = {
    "todoTaskName": taskName,
    "todoTaskSort": taskSort,
    "isCompleted": isCompleted,
    "isArchived": isArchived,
    "todoCategoryId": todoCategoryId,
    "todoPriorityId": todoPriorityId
  };
  if (dueDT != null) {
    if (dueDT.length != 0) {
      body["dueDT"] = dueDT;
    }
  }

  final response = await http.post('$url/ToDoTasks',
      headers: headers,
      body: jsonEncode({body}));
  if (response.statusCode == 201) {
    // return created tasks server id
    return json.decode(response.body)['id'];
  } else {
    return null;
  }
}

Future<void> deleteTaskFromServer(String token, int taskId) async {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };
  await http.delete('$url/ToDoTasks/$taskId', headers: headers);
}

Future<void> updateTaskInServer(
    String token,
    int taskId,
    String taskName,
    int taskSort,
    String dueDT,
    bool isCompleted,
    bool isArchived,
    int todoCategoryId,
    int todoPriorityId) async {

  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };
  var body = {
    "id": taskId,
    "todoTaskName": taskName,
    "todoTaskSort": taskSort,
    "isCompleted": isCompleted,
    "isArchived": isArchived,
    "todoCategoryId": todoCategoryId,
    "todoPriorityId": todoPriorityId
  };
  if (dueDT != null) {
    if (dueDT.length != 0) {
      body["dueDT"] = dueDT;
    }
  }
  await http.put('$url/ToDoTasks/$taskId',
      headers: headers, body: jsonEncode(body));
}
