import 'package:blogging_app/custom_widgets/delete_post_list.dart';
import 'package:blogging_app/custom_widgets/edit_post_list.dart';
import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/services/authentication_service.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class DeleteBlogs extends StatefulWidget {
  @override
  _DeleteBlogsState createState() => _DeleteBlogsState();
}

class _DeleteBlogsState extends State<DeleteBlogs> {
  //get the info about logged in user
  final AuthService _authService = new AuthService();

  //variables
  FirebaseUser _user;
  QuerySnapshot userSnap;
  String _userName = '';
  String _userEmail = '';
  Stream _blogPosts;
  String profilePic = '';
  String defaultPic =
      'https://firebasestorage.googleapis.com/v0/b/blogging-app-e918a.appspot.com/o/profiles%2Fblank-profile-picture-973460_960_720.png?alt=media&token=bfd3784e-bfd2-44b5-93cb-0c26e3090ba4';

  // initState
  @override
  void initState() {
    super.initState();
    _getBlogPosts();
  }

  _getBlogPosts() async {
    //get the current user
    _user = await FirebaseAuth.instance.currentUser();
    //get the name of the user stored locally
    await Helper.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });
    //get the email of the user stored locally
    await Helper.getUserEmailSharedPreference().then((value) {
      setState(() {
        _userEmail = value;
      });
    });
    //get the blogs of the user
    DatabaseService(uid: _user.uid).getUserBlogPosts().then((snapshots) {
      setState(() {
        _blogPosts = snapshots;
      });
    });
  }

  Widget noBlogPostWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20.0),
          Center(
            child: Text(
              "No blogs",style: TextStyle(
              fontSize: 30.0,
            ),),
          ),
        ],
      ),
    );
  }

  Widget blogPostsList() {
    return StreamBuilder(
      stream: _blogPosts,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents != null &&
              snapshot.data.documents.length != 0) {
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  // return ListTile(
                  //   title: Text(snapshot.data.documents[index].data['blogPostTitle']),
                  //   subtitle: Text(snapshot.data.documents[index].data['blogPostContent']),
                  //   trailing: Text(snapshot.data.documents[index].data['date']),
                  // );
                  return Column(
                    children: <Widget>[
                      DeletePostView(
                          userId: _user.uid,
                          blogPostId:
                          snapshot.data.documents[index].data['blogPostId'],
                          blogPostTitle: snapshot
                              .data.documents[index].data['blogPostTitle'],
                          blogPostContent: snapshot
                              .data.documents[index].data['blogPostContent'],
                          date: snapshot.data.documents[index].data['date'],
                          postImage: (snapshot.data.documents[index].data['postImage'] != null)? snapshot.data.documents[index].data['postImage']:'https://media.sproutsocial.com/uploads/2017/02/10x-featured-social-media-image-size.png'),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Divider(height: 0.0)),
                    ],
                  );
                });
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
      appBar: AppBar(
        title: Text(
          'Delete Blogs',
          style: TextStyle(fontFamily: 'OpenSans'),
        ),
      ),
      body: blogPostsList(),
    );
  }
}
