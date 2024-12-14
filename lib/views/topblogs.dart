import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/services/authentication_service.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TopBlogs extends StatefulWidget {
  @override
  _TopBlogsState createState() => _TopBlogsState();
}

class _TopBlogsState extends State<TopBlogs> {

  //get the info about logged in user
  final AuthService _authService = new AuthService();

  //variables
  late User _user;
  QuerySnapshot? userSnap;
  String _userName = '';
  String _userEmail = '';
  Stream? _blogPosts;
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
    DatabaseService(uid: _user.uid).getTopBlogPosts().then((snapshots) {
      setState(() {
        _blogPosts = snapshots;
      });
    });
    //get user data
    await DatabaseService(uid: _user.uid).getUserDataID(_user.uid).then((res) {
      setState(() {
        userSnap = res;
        profilePic = userSnap.docs[0].data['profileImage'].toString();
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
          if (snapshot.data.docs != null &&
              snapshot.data.docs.length != 0) {
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      PostTile(
                          userId: _user.uid,
                          blogPostId:
                          snapshot.data.docs[index].data['blogPostId'],
                          blogPostTitle: snapshot
                              .data.docs[index].data['blogPostTitle'],
                          blogPostContent: snapshot
                              .data.docs[index].data['blogPostContent'],
                          date: snapshot.data.docs[index].data['date'],
                          postImage: (snapshot.data.docs[index].data['postImage'] != null)? snapshot.data.docs[index].data['postImage']:'https://media.sproutsocial.com/uploads/2017/02/10x-featured-social-media-image-size.png'),
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
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Top Blogs',
          style: TextStyle(fontFamily: 'OpenSans',color: Colors.white),
        ),
      ),
      body: blogPostsList(),
    );
  }
}