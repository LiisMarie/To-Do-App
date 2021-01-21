import 'package:flutter/widgets.dart';

class JWT {
  final String token;
  final String status;

  JWT({@required this.token, @required this.status});

  factory JWT.fromJson(Map<String, dynamic> jsonObject) {
    return JWT(token: jsonObject['token'], status: jsonObject['status']);
  }
}
