import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/constansts.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:blogging_app/views/post_page.dart';
import 'package:flutter/material.dart';

class CreateBlogPage extends StatefulWidget {
  //variables
  final String uid;
  final String userName;
  final String userEmail;

  CreateBlogPage({this.uid, this.userName, this.userEmail});

  @override
  _CreateBlogPageState createState() => _CreateBlogPageState();
}

class _CreateBlogPageState extends State<CreateBlogPage> {
  //Text fields
  TextEditingController _titleEditingController = new TextEditingController();
  TextEditingController _contentEditingController = new TextEditingController();

  //form
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  //save data to firestore
  _onPublish() async {
    //check if entered info is correct
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      //
      await DatabaseService(uid: widget.uid)
          .saveBlogPost(_titleEditingController.text, widget.userName,
              widget.userEmail, _contentEditingController.text)
          .then((res) async {
        //after saving data navigate to show the BlogPost
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                BlogPostPage(userId: widget.uid, blogPostId: res),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("Create a Post"),
              elevation: 0.0,
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                children: <Widget>[
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      hintText: "Blog Title",
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black87, width: 2.0)),
                    ),
                    validator: (val) =>
                        val.length < 1 ? 'This field cannot be blank' : null,
                    controller: _titleEditingController,
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    maxLines: 20,
                    decoration: textInputDecoration.copyWith(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black87, width: 2.0)),
                      hintText: "Start writing...",
                    ),
                    validator: (val) =>
                        val.length < 1 ? 'This field cannot be blank' : null,
                    controller: _contentEditingController,
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: RaisedButton(
                        elevation: 0.0,
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Text('Publish',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0)),
                        onPressed: () {
                          _onPublish();
                        }),
                  ),
                ],
              ),
            ),
          );
  }
}
