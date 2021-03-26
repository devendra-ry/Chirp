import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/constansts.dart';
import 'package:flutter/material.dart';

class CreateComment extends StatefulWidget {
  final String userId;
  final String userName;
  final String blogPostId;
  CreateComment({Key key, this.userId, this.blogPostId, this.userName});
  @override
  _CreateCommentState createState() => _CreateCommentState();
}

class _CreateCommentState extends State<CreateComment> {
  final _formKey = GlobalKey<FormState>();
  String _error = '';
  TextEditingController _commentEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          child: ListView(
            padding:
            EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.05),
                  TextFormField(
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'OpenSans',
                    ),
                    controller: _commentEditingController,
                    decoration: textInputDecoration.copyWith(
                      prefixIcon: Icon(Icons.comment,
                          color: Colors.blue),
                    ),
                    validator: (val) {
                      return RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(val)
                          ? null
                          : "Please enter a valid comment";
                    },
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
                          'Comment',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        onPressed: () async{
                              await DatabaseService(uid: widget.userId).saveComment(widget.userId,widget.userName, widget.blogPostId, _commentEditingController.text).then((value) => Navigator.of(context).pop());
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
