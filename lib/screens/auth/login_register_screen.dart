import 'package:HW3/api/api.dart';
import 'package:HW3/domain/account.dart';
import 'package:HW3/database/database_helper.dart';
import 'package:HW3/database/repository.dart';
import 'package:HW3/screens/menu_items.dart';
import 'package:flutter/material.dart';
import 'package:HW3/providers/model.dart';
import 'package:provider/provider.dart';

class LoginRegisterScreen extends StatefulWidget {
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

enum FormType { login, register }

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final repository = Repository();

  final textControllerEmail = TextEditingController();
  final textControllerPassword = TextEditingController();
  final textControllerPasswordRepeat = TextEditingController();

  FormType _form = FormType.login;

  String _email = "";
  String _password = "";
  String _passwordRepeat = "";

  _LoginRegisterScreenState() {
    textControllerEmail.addListener(_emailListener);
    textControllerPassword.addListener(_passwordListener);
    textControllerPasswordRepeat.addListener(_passwordRepeatListener);
  }

  @override
  void initState() {
    super.initState();

    // cancel timer
    Provider.of<Model>(context, listen: false).cancelTimer();
  }

  void _emailListener() {
    if (textControllerEmail.text.isEmpty) {
      _email = "";
    } else {
      _email = textControllerEmail.text;
    }
  }

  void _passwordListener() {
    if (textControllerPassword.text.isEmpty) {
      _password = "";
    } else {
      _password = textControllerPassword.text;
    }
  }

  void _passwordRepeatListener() {
    if (textControllerPasswordRepeat.text.isEmpty) {
      _passwordRepeat = "";
    } else {
      _passwordRepeat = textControllerPasswordRepeat.text;
    }
  }

  void _formChange() {
    setState(() {
      _form = _form == FormType.login ? FormType.register : FormType.login;
    });
  }

  void _buttonLoginRegisterPressed() async {
    if (_email.length == 0) {
      _showAlertDialog('Status', 'Provide a email!');
      return;
    }

    if (_password.length == 0) {
      _showAlertDialog('Status', 'Provide a password!');
      return;
    }

    if (_form == FormType.register && _password != _passwordRepeat) {
      _showAlertDialog('Status', 'Passwords do not match!');
      return;
    }

    // get token from server
    var jwt = await fetchToken(_email, _password, _form);

    if (jwt.token.isNotEmpty) {
      // save state
      Provider.of<Model>(context, listen: false).updateToken(jwt.token);

      // save logged in user data to database
      await repository.insert(
          DatabaseHelper.tableAccount, Account(1, _email, _password).toMap());

      // navigate to todos page, remove navigation history
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/display-todos', (Route<dynamic> route) => false);
    }
  }

  @override
  void dispose() {
    textControllerEmail.dispose();
    textControllerPassword.dispose();
    textControllerPasswordRepeat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          children: [
            _buildTextFields(),
            Divider(color: Colors.transparent),
            _buildButtons(),
          ],
        ),
      ),
      drawer: MenuItems(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(_form == FormType.login ? "Login" : "Register"),
    );
  }

  Widget _buildTextFields() {
    return Container(
      child: Column(
        children: [
          // email text field
          TextField(
            controller: textControllerEmail,
            decoration:
                InputDecoration(labelText: "Email", icon: Icon(Icons.mail)),
            keyboardType: TextInputType.emailAddress,
          ),

          Divider(color: Colors.transparent),

          // password text field
          TextField(
            controller: textControllerPassword,
            decoration: InputDecoration(
                labelText: "Password", icon: Icon(Icons.vpn_key)),
            obscureText: true,
          ),

          Divider(color: Colors.transparent),

          // repeat password text field, visible while registering
          Visibility(
            visible: _form == FormType.register,
            child: TextField(
              controller: textControllerPasswordRepeat,
              decoration: InputDecoration(
                  labelText: "Repeat password", icon: Icon(Icons.repeat)),
              obscureText: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    var buttonLoginRegisterText =
        _form == FormType.login ? "Login" : "Register";
    var buttonChangeFormTypeText = _form == FormType.login
        ? "Do you need to register?"
        : "Already have an account? Switch to login.";
    return Column(
      children: [
        ElevatedButton(
            onPressed: _buttonLoginRegisterPressed,
            child: Text(buttonLoginRegisterText)),
        TextButton(
            onPressed: _formChange, child: Text(buttonChangeFormTypeText))
      ],
    );
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
