import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/views/authenticate_page.dart';
import 'package:blogging_app/views/home_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _getUserLoggedInStatus();
  }

  _getUserLoggedInStatus() async {
    await Helper.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        _isLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blogging App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: (_isLoggedIn != null) ? _isLoggedIn ? HomePage() : Authenticate() : Authenticate(),
    );
  }
}


//home: (_isLoggedIn != null) ? _isLoggedIn ? HomePage() : Authenticate() : Authenticate(),