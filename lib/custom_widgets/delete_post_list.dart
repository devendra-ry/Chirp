import 'package:blogging_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeletePostView extends StatefulWidget {
  final String userId;
  final String blogPostId;
  final String blogPostTitle;
  final String blogPostContent;
  final String date;
  final String postImage;

  const DeletePostView(
      {Key? key, // Added ? for null safety
        required this.userId,
        required this.blogPostId,
        required this.blogPostTitle,
        required this.blogPostContent,
        required this.date,
        required this.postImage})
      : super(key: key);

  @override
  _DeletePostViewState createState() => _DeletePostViewState();
}

class _DeletePostViewState extends State<DeletePostView> {
  User? _user; // Made nullable

  // Removed Randomizer (not essential for core functionality)

  // initState
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  _getCurrentUser() async {
    _user = FirebaseAuth.instance.currentUser; // No need for await
  }

  _onDelete() async {
    if (_user != null) {
      // Check if user is not null
      await DatabaseService(uid: widget.userId).deleteBlogPost(widget.blogPostId);
      // Consider adding error handling here if the delete operation fails
    } else {
      // Handle the case where the user is not logged in
      print("User is not logged in.");
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {
        _onDelete();
        Navigator.of(context).pop(); // Close the dialog after deleting
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirm?"),
      content: const Text("Would you like to continue deleting this blog?"),
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
        showAlertDialog(context);
      },
      child: Container(
        margin: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromRGBO(154, 183, 211, 1.0)),
          borderRadius: const BorderRadius.all(Radius.circular(18.0)),
        ),
        child: Column(
          children: [
            header(),
            const Divider(
              color: Color.fromRGBO(154, 183, 211, 1.0),
            ),
            Container(
              constraints: BoxConstraints.expand(height: height * 0.3),
              child: Image.network(
                widget.postImage,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    size: 50,
                  ); // Show an error icon if image loading fails
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: Colors.grey, // Placeholder color
          child: Text(
            widget.blogPostTitle.substring(0, 1).toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          widget.blogPostTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Text(widget.date,
            style: const TextStyle(color: Colors.grey, fontSize: 12.0)),
      ),
    );
  }
}