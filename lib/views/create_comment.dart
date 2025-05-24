import 'package:blogging_app/services/database_service.dart';
import 'package:flutter/material.dart';

class CreateComment extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? blogPostId;

  const CreateComment({Key? key, this.userId, this.blogPostId, this.userName})
      : super(key: key);

  @override
  _CreateCommentState createState() => _CreateCommentState();
}

class _CreateCommentState extends State<CreateComment> {
  final _formKey = GlobalKey<FormState>();
  String _error = '';
  final TextEditingController _commentEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Comment',
          style: TextStyle(fontFamily: 'OpenSans', color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.05),
                  TextFormField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.comment),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(),
                      ),
                      hintText: "Enter your comment here",
                      //fillColor: Colors.green
                    ),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontFamily: 'OpenSans',
                    ),
                    controller: _commentEditingController,
                    validator: (val) {
                      // Simplified validation - check if it's not empty
                      if (val == null || val.isEmpty) {
                        return "Please enter a comment";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: height * 0.05),
                  SizedBox(
                    width: double.infinity,
                    height: height * 0.072,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'Comment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Check if form is valid
                          await DatabaseService(uid: widget.userId)
                              .saveComment(
                              uid: widget.userId!,
                              name: widget.userName!,
                              blogId: widget.blogPostId!,
                              comment: _commentEditingController.text);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  Text(
                    _error,
                    style: const TextStyle(
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