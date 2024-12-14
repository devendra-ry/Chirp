import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/services/authentication_service.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/constansts.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:blogging_app/views/home_page.dart';
import 'package:blogging_app/views/reset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInPage extends StatefulWidget {
  final Function? toggleView;
  SignInPage({this.toggleView});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  //Authentication
  final AuthService _authService = new AuthService();

  //TextFields
  TextEditingController _emailEditingController = new TextEditingController();
  TextEditingController _passwordEditingController =
      new TextEditingController();

  //form
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _error = '';
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  //SignIn method
  _onSignIn() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      //login if user entered correct info
      await _authService
          .signInWithEmailAndPassword(
              _emailEditingController.text, _passwordEditingController.text)
          .then((result) async {
        if (result != null) {
          //get user info from database
          QuerySnapshot userInfo =
              await DatabaseService().getUserData(_emailEditingController.text);

          //Save data locally for caching
          await Helper.saveUserLoggedInSharedPreference(true);
          await Helper.saveUserEmailSharedPreference(
              _emailEditingController.text);
          await Helper.saveUserNameSharedPreference(
              userInfo.docs[0].data['fullName']);
          //Navigate to HomePage after login
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          setState(() {
            _error = 'Error signing in!';
            _isLoading = false;
          });
        }
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
                      children: <Widget>[
                        SizedBox(height: height * 0.05),
                        Center(
                          child: Text(
                            "Sign In",
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
                        SizedBox(height: height * 0.02),
                        Text(
                          "Password",
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
                          controller: _passwordEditingController,
                          decoration: textInputDecoration.copyWith(
                            hintText: '********',
                            hintStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                // Based on passwordVisible state choose the icon
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Update the state i.e. toogle the state of passwordVisible variable
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (val) => val.length < 6
                              ? 'Password not strong enough'
                              : null,
                          obscureText: !_passwordVisible,
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ResetScreen()),
                          ),
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.05),
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.072,
                          child: RaisedButton(
                              elevation: 5.0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                              onPressed: () {
                                _onSignIn();
                              }),
                        ),
                        SizedBox(height: height * 0.05),
                        Text.rich(
                          TextSpan(
                            text: 'Don\'t have an Account? ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'OpenSans',
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Register here',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    widget.toggleView();
                                  },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.10),
                        Text(
                          _error,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.0,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}