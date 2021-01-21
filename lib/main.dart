import 'package:HW3/screens/auth/account_screen.dart';
import 'package:HW3/screens/category/categories_display_screen.dart';
import 'package:HW3/screens/priority/priorities_display_screen.dart';
import 'package:flutter/material.dart';
import 'package:HW3/providers/model.dart';
import 'package:HW3/screens/auth/login_register_screen.dart';
import 'package:HW3/screens/todo/todos_display_screen.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Model>(
      create: (_) => Model(),
      child: new MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Model>(context);

    return MaterialApp(
      title: "Navigation",
      debugShowCheckedModeBanner: false,
      initialRoute: '/display-todos',
      routes: {
        '/login': (context) => LoginRegisterScreen(),
        '/account': (context) => AccountScreen(),
        '/display-todos': (context) => TodosDisplayScreen(),
        '/display-priorities': (context) => PrioritiesDisplayScreen(),
        '/display-categories': (context) => CategoriesDisplayScreen(),
      },
      theme: theme.getTheme(),
    );
  }
}
