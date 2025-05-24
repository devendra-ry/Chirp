import 'package:blogging_app/custom_widgets/comment.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:flutter/material.dart';

class Comments extends StatefulWidget {
  final String? userId;
  final String? blogPostId;

  const Comments({Key? key, this.userId, this.blogPostId}) : super(key: key); // Corrected Key?

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  //variables
  Stream? _comments;

  // initState
  @override
  void initState() {
    super.initState();
    _getComments();
  }

  _getComments() async {
    // No need for await here, just call the function
    _comments = DatabaseService(uid: widget.userId)
        .getComments(widget.blogPostId!);
  }

  Widget noComments() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20.0),
          Center(
            child: Text(
              "No Comments",
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget commentsList() {
    return StreamBuilder(
      stream: _comments,
      builder: (context, AsyncSnapshot snapshot) { // Added AsyncSnapshot
        if (snapshot.hasData) {
          if (snapshot.data.docs != null && snapshot.data.docs.length != 0) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                // Access data safely as a Map
                Map<String, dynamic> data =
                snapshot.data.docs[index].data() as Map<String, dynamic>;
                return Column(
                  children: <Widget>[
                    CommentTile(
                        key: ValueKey(data['comID']),
                        userName: data['userName'],
                        blogPostId: data['comID'],
                        comment: data['comment'],
                        date: data['date']),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Divider(height: 0.0),
                    ),
                  ],
                );
              },
            );
          } else {
            return noComments();
          }
        } else {
          return noComments(); // Or you can return a loading indicator
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Comments',
          style: TextStyle(fontFamily: 'OpenSans', color: Colors.white),
        ),
      ),
      body: commentsList(),
    );
  }
}