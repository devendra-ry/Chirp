import 'package:blogging_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:randomizer_null_safe/randomizer_null_safe.dart';

class DeletePostView extends StatefulWidget {
  final String userId;
  final String blogPostId;
  final String blogPostTitle;
  final String blogPostContent;
  final String date;
  final String postImage;

  const DeletePostView({required Key key, required this.userId, required this.blogPostId, required this.blogPostTitle, required this.blogPostContent, required this.date, required this.postImage}) : super(key: key);

  @override
  _DeletePostViewState createState() => _DeletePostViewState();
}

class _DeletePostViewState extends State<DeletePostView> {
  late User _user;

  Randomizer randomizer = Randomizer.instance();

  // initState
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  _getCurrentUser() async {
    _user = await FirebaseAuth.instance.currentUser!;
  }

  _onDelete() async {
    await DatabaseService(uid: widget.userId)
        .deleteBlogPost(widget.blogPostId)
        .then((res) async {
      //after saving data navigate to show the BlogPost
      Navigator.of(context).pop();
      print('-------------result-------------------');
      print(res);
    });
  }

  showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed:  () {
        _onDelete();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm?"),
      content: Text("Would you like to continue deleting this blog?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditPost(userId: _user.uid, blogPostId: widget.blogPostId,postImage: widget.postImage)));
        showAlertDialog(context);
      },
      child: Container(
        margin: EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(154, 183, 211, 1.0)),
          borderRadius: BorderRadius.all(Radius.circular(18.0)),
        ),
        child: Column(
          children: [
            header(),
            Divider(
              color: Color.fromRGBO(154, 183, 211, 1.0),
            ),
            Container(
              constraints: BoxConstraints.expand(height: height * 0.3),
              child: Image.network(widget.postImage),
            ),
          ],
        ),
      ),
    );
  }

  header (){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: randomizer.randomColor(),
          child: Text(widget.blogPostTitle.substring(0, 1).toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        ),
        title: Text(
          widget.blogPostTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Text(widget.date, style: TextStyle(color: Colors.grey, fontSize: 12.0)),
      ),
    );
  }
}