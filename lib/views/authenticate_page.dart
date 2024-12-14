import 'package:blogging_app/views/register_page.dart';
import 'package:blogging_app/views/signin_page.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  Authenticate({Key key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool _showSignIn = true;

  void _toggleView() {
    setState(() {
      _showSignIn = !_showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSignIn) {
      return SignInPage(toggleView: _toggleView);
    } else {
      return RegisterPage(toggleView: _toggleView);
    }
  }
}