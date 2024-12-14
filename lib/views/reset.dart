import 'package:blogging_app/services/authentication_service.dart';
import 'package:blogging_app/shared/constansts.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:flutter/material.dart';

class ResetScreen extends StatefulWidget {
  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  bool _isLoading = false;
  String _error = '';
  TextEditingController _emailEditingController = new TextEditingController();
  final AuthService _authService = new AuthService();
  final _formKey = GlobalKey<FormState>();

  _onSend() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      await _authService
          .resetPassword(_emailEditingController.text)
          .then((res) async {
        Navigator.of(context).pop();
      });
    } else {
      setState(() {
        _error = 'Error sending reset link!';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return _isLoading
        ? Loading()
        : Scaffold(
            body: Form(
              key: _formKey,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
                child: ListView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.05),
                        Center(
                          child: Text(
                            "Password Reset",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.05),
                        Text(
                          "Email",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        TextFormField(
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'OpenSans',
                          ),
                          controller: _emailEditingController,
                          decoration: textInputDecoration.copyWith(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.alternate_email,
                                color: Colors.white),
                          ),
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "Please enter a valid email";
                          },
                        ),
                        SizedBox(height: height * 0.05),
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.072,
                          child: TextButton(
                              elevation: 5.0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Text(
                                'Send email',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                              onPressed: () {
                                _onSend();
                              }),
                        ),
                        SizedBox(height: height * 0.04),
                        Text(
                          _error,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.0,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
  }
}