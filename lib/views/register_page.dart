import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/services/authentication_service.dart';
import 'package:blogging_app/shared/constansts.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  final Function toggleView;
  RegisterPage({this.toggleView});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //Authentication
  final AuthService _authService = new AuthService();

  //Text Fields
  TextEditingController _fullNameEditingController =
      new TextEditingController();
  TextEditingController _emailEditingController = new TextEditingController();
  TextEditingController _passwordEditingController =
      new TextEditingController();
  TextEditingController _confirmPasswordEditingController =
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

  _onRegister() async {
    //check if the user entered correct info
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      //if yes register the user
      await _authService
          .registerWithEmailAndPassword(_fullNameEditingController.text,
              _emailEditingController.text, _passwordEditingController.text)
          .then((result) async {
        if (result != null) {
          //save data locally for caching
          await Helper.saveUserLoggedInSharedPreference(true);
          await Helper.saveUserEmailSharedPreference(
              _emailEditingController.text);
          await Helper.saveUserNameSharedPreference(
              _fullNameEditingController.text);

          //after registering navigate to homepage
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          setState(() {
            _error = 'Error while registering the user!';
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
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30.0,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.05),
                          Text(
                            "Full Name",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          TextFormField(
                              style: TextStyle(color: Colors.white),
                              controller: _fullNameEditingController,
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Full Name',
                                  hintStyle: TextStyle(color: Colors.white70),
                                  prefixIcon:
                                      Icon(Icons.person, color: Colors.white)),
                              validator: (val) => val.isEmpty
                                  ? 'This field cannot be blank'
                                  : null),
                          SizedBox(height: height * 0.02),
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
                            style: TextStyle(color: Colors.white),
                            controller: _emailEditingController,
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Colors.white70),
                                prefixIcon: Icon(Icons.alternate_email,
                                    color: Colors.white)),
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
                            style: TextStyle(color: Colors.white),
                            controller: _passwordEditingController,
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Password',
                                hintStyle: TextStyle(color: Colors.white70),
                                prefixIcon:
                                    Icon(Icons.lock, color: Colors.white),
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
                            obscureText: _passwordVisible,
                          ),
                          SizedBox(height: height * 0.02),
                          Text(
                            "Confirm Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: _confirmPasswordEditingController,
                            decoration: textInputDecoration.copyWith(
                              hintText: 'Confirm Password',
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
                            validator: (val) =>
                                val == _passwordEditingController.text
                                    ? null
                                    : 'Does not match the password',
                            obscureText: _passwordVisible,
                          ),
                          SizedBox(height: height * 0.05),
                          SizedBox(
                            width: double.infinity,
                            height: height * 0.072,
                            child: RaisedButton(
                                elevation: 0.0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                                child: Text('Sign Up',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 16.0)),
                                onPressed: () {
                                  _onRegister();
                                }),
                          ),
                          SizedBox(height: height * 0.05),
                          Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'OpenSans',
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Sign In',
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
                )),
          );
  }
}
