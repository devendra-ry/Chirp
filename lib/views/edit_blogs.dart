import 'package:blogging_app/custom_widgets/edit_post_list.dart';
import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/services/authentication_service.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditBlogs extends StatefulWidget {
  const EditBlogs({Key? key}) : super(key: key);

  @override
  _EditBlogsState createState() => _EditBlogsState();
}

class _EditBlogsState extends State<EditBlogs> {
  // Get the info about logged in user
  final AuthService _authService = AuthService();

  // Variables
  User? _user; // Made nullable
  QuerySnapshot? userSnap; // Made nullable
  String? _userName; // Made nullable
  String? _userEmail; // Made nullable
  Stream? _blogPosts; // Made nullable
  String profilePic = '';
  final String defaultPic =
      'https://firebasestorage.googleapis.com/v0/b/blogging-app-e918a.appspot.com/o/profiles%2Fblank-profile-picture-973460_960_720.png?alt=media&token=bfd3784e-bfd2-44b5-93cb-0c26e3090ba4';

  // initState
  @override
  void initState() {
    super.initState();
    _getBlogPosts();
  }

  _getBlogPosts() async {
    // Get the current user
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      // Get the name of the user stored locally
      _userName = await Helper.getUserNameSharedPreference() ?? '';

      // Get the email of the user stored locally
      _userEmail = await Helper.getUserEmailSharedPreference() ?? '';

      // Get the blogs of the user
      _blogPosts = DatabaseService(uid: _user!.uid).getUserBlogPosts();

      setState(() {}); // Update the UI after fetching data

    } else {
      // Handle the case where the user is not logged in
      print("User is not logged in.");
    }
  }

  Widget noBlogPostWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20.0),
          Center(
            child: Text(
              "No blogs",
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget blogPostsList() {
    return StreamBuilder(
      stream: _blogPosts,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.docs != null && snapshot.data.docs.length != 0) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                // Access data safely
                Map<String, dynamic> data =
                snapshot.data.docs[index].data() as Map<String, dynamic>;
                return Column(
                  children: <Widget>[
                    EditPostView(
                      userId: _user!.uid, // Use null-aware operator
                      blogPostId: data['blogPostId'],
                      blogPostTitle: data['blogPostTitle'],
                      blogPostContent: data['blogPostContent'],
                      date: data['date'],
                      postImage: data['postImage'] ??
                          'https://media.sproutsocial.com/uploads/2017/02/10x-featured-social-media-image-size.png',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Divider(height: 0.0),
                    ),
                  ],
                );
              },
            );
          } else {
            return noBlogPostWidget();
          }
        } else {
          return noBlogPostWidget();
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Blogs',
          style: TextStyle(fontFamily: 'OpenSans', color: Colors.white),
        ),
      ),
      body: blogPostsList(),
    );
  }
}