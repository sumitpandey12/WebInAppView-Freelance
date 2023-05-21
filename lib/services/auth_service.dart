import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ptoject1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSevice {
  void login(BuildContext context, String email, password) async {
    try {
      Response response = await post(Uri.parse('https://reqres.in/api/login'),
          body: {'email': email, 'password': password});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data['token']);
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("token", data['token']);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(title: "Start with Grow"),
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Login credential failed"),
        ));
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
