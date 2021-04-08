//import 'dart:html';

import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/services/authentication_service.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/views/manageblogs.dart';
import 'package:blogging_app/views/profile_page.dart';
import 'package:blogging_app/views/search.dart';
import 'package:blogging_app/views/topblogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'about.dart';
import 'authenticate_page.dart';
import 'create_blog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

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
    //get user data
    await DatabaseService(uid: _user.uid).getUserDataID(_user.uid).then((res) {
      setState(() {
        userSnap = res;
        profilePic = userSnap.documents[0].data['profileImage'].toString();
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateBlogPage(
                      uid: _user.uid,
                      userName: _userName,
                      userEmail: _userEmail),
                ),
              ).then((value) => setState(() {
                    _getBlogPosts();
                  }));
            },
            child: Icon(Icons.add_circle, color: Colors.grey[700], size: 100.0),
          ),
          SizedBox(height: 20.0),
          Text(
              "You have not created any blog posts, tap on the 'plus' icon present above or at the bottom-right to create your first blog post."),
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
                      PostTile(
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
      backgroundColor: Colors.grey[200],
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Home',
          style: TextStyle(fontFamily: 'OpenSans',color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(
                  _userName,
                  style: TextStyle(fontFamily: 'OpenSans',color: Colors.white),
                ),
                accountEmail: Text(
                  _userEmail,
                  style: TextStyle(fontFamily: 'OpenSans',color: Colors.white),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                      (profilePic == '') ? defaultPic : profilePic),
                ),
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                leading: Icon(Icons.home, color: Colors.blueGrey),
                title: Text(
                  'Home',
                  style:
                      TextStyle(fontFamily: 'OpenSans', color: Colors.blueGrey),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        uid: _user.uid,
                        userEmail: _userEmail,
                      ),
                    ),
                  );
                },
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                leading: Icon(Icons.person, color: Colors.blueGrey),
                title: Text(
                  'Profile',
                  style:
                      TextStyle(fontFamily: 'OpenSans', color: Colors.blueGrey),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(cuid: _user.uid,),
                    ),
                  );
                },
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                leading: Icon(Icons.search, color: Colors.blueGrey),
                title: Text(
                  'Search',
                  style:
                      TextStyle(fontFamily: 'OpenSans', color: Colors.blueGrey),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageBlogs(),
                    ),
                  );
                },
                contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                leading: Icon(Icons.edit, color: Colors.blueGrey),
                title: Text(
                  'Manage Blogs',
                  style:
                  TextStyle(fontFamily: 'OpenSans', color: Colors.blueGrey),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopBlogs(),
                    ),
                  );
                },
                contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                leading: Icon(Icons.arrow_drop_up, color: Colors.blueGrey),
                title: Text(
                  'Top Blogs',
                  style:
                  TextStyle(fontFamily: 'OpenSans', color: Colors.blueGrey),
                ),
              ),
              Divider(),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutPage(),
                    ),
                  );
                },
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                leading: Icon(Icons.info, color: Colors.blueGrey),
                title: Text(
                  'About',
                  style:
                      TextStyle(fontFamily: 'OpenSans', color: Colors.blueGrey),
                ),
              ),
              ListTile(
                onTap: () async {
                  await _authService.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => Authenticate(),
                      ),
                      (Route<dynamic> route) => false);
                },
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                leading: Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                ),
                title: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red[300], fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
      body: blogPostsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateBlogPage(
                  uid: _user.uid, userName: _userName, userEmail: _userEmail),
            ),
          ).then((value) => setState(() {
                _getBlogPosts();
              }));
        },
        child: Icon(Icons.create, color: Colors.white, size: 30.0),
        backgroundColor: Color.fromRGBO(154, 183, 211, 1.0),
        elevation: 10,
      ),
    );
  }
}

// GestureDetector(
//           child: blogPostsList(),
//           onVerticalDragDown: (DragDownDetails details) {
//             _getBlogPosts();
//             print("==============================");
//           }),

/*
GestureDetector(
child: Column(
children: [
Container(
width: 200,
height: 200,
color: Colors.amber,
),
Flexible(
child: blogPostsList(),
)
],
),
onVerticalDragDown: (DragDownDetails details) {
_getBlogPosts();
print("=================================================");
},
),
*/

/*
GestureDetector(
        child: Column(
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.amber,
            ),
            Flexible(
              child: blogPostsList(),
            )
          ],
        ),
        onVerticalDragDown: (DragDownDetails details) {
          _getBlogPosts();
          print("=================================================");
        },
      ),
*/
