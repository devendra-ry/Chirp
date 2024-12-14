import 'package:blogging_app/custom_widgets/comment.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:flutter/material.dart';

class Comments extends StatefulWidget {
  final String userId;
  final String blogPostId;

  const Comments({Key key, this.userId, this.blogPostId}) : super(key: key);
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  //variables
  Stream _comments;

  // initState
  @override
  void initState() {
    super.initState();
    _getComments();
  }

  _getComments () async{
    await DatabaseService(uid: widget.userId).getComments(widget.blogPostId).then((snapshots) {
      setState(() {
        _comments = snapshots;
      });
    });
  }


  Widget noComments() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20.0),
          Center(
            child: Text(
                "No Comments",style: TextStyle(
              fontSize: 30.0,
            ),),
          ),
        ],
      ),
    );
  }

  Widget commentsList() {
    return StreamBuilder(
      stream: _comments,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents != null &&
              snapshot.data.documents.length != 0) {
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      CommentTile(
                          userName: snapshot.data.documents[index].data['userName'],
                          blogPostId: snapshot.data.documents[index].data['comID'],
                          comment : snapshot.data.documents[index].data['comment'],
                          date: snapshot.data.documents[index].data['date']),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Divider(height: 0.0)),
                    ],
                  );
                });
          } else {
            return noComments();
          }
        } else {
          return noComments();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comments',
          style: TextStyle(fontFamily: 'OpenSans'),
        ),
      ),
      body: commentsList(),
    );
  }
}