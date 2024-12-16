import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/views/authenticate_page.dart';
import 'package:blogging_app/views/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
      if (value != null) {
        // Check for null before assigning
        setState(() {
          _isLoggedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(154, 183, 211, 1.0),
    ));
    return MaterialApp(
      title: 'Blogging App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(154, 183, 211, 1.0),
      ),
      // Use a ternary operator with a condition that handles null
      home: _isLoggedIn ? const HomePage() : const Authenticate(),
    );
  }
}