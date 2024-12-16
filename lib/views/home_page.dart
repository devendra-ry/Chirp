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
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Get the info about logged in user
  final AuthService _authService = AuthService();

  // Variables
  User? _user;
  QuerySnapshot? userSnap;
  String _userName = '';
  String _userEmail = '';
  Stream<QuerySnapshot>? _blogPosts; // Ensure the stream is of type QuerySnapshot
  String profilePic = '';
  final String defaultPic =
      'https://firebasestorage.googleapis.com/v0/b/blogging-app-e918a.appspot.com/o/profiles%2Fblank-profile-picture-973460_960_720.png?alt=media&token=bfd3784e-bfd2-44b5-93cb-0c26e3090ba4';

  // initState
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Get the current user
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      // Get the name and email of the user stored locally
      _userName = await Helper.getUserNameSharedPreference() ?? '';
      _userEmail = await Helper.getUserEmailSharedPreference() ?? '';

      // Get user data
      userSnap = await DatabaseService(uid: _user!.uid).getUserDataID(_user!.uid);
      profilePic =
          (userSnap!.docs[0].data() as Map<String, dynamic>)['profileImage'] ??
              defaultPic;

      // Get the blogs of the user using a stream
      setState(() {
        _blogPosts = DatabaseService(uid: _user!.uid).getUserBlogPosts();
      });
    } else {
      // Handle the case where the user is not logged in
      print("User is not logged in.");
    }
  }

  Widget noBlogPostWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (_user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateBlogPage(
                      uid: _user!.uid,
                      userName: _userName,
                      userEmail: _userEmail,
                    ),
                  ),
                ).then((value) {
                  // Refresh the blog posts after returning from CreateBlogPage
                  _loadUserData();
                });
              } else {
                // Handle the case where the user is not logged in
                print("User is not logged in.");
              }
            },
            child: Icon(Icons.add_circle, color: Colors.grey[700], size: 100.0),
          ),
          const SizedBox(height: 20.0),
          const Text(
            "You have not created any blog posts, tap on the 'plus' icon present above or at the bottom-right to create your first blog post.",
          ),
        ],
      ),
    );
  }

  Widget blogPostsList() {
    return StreamBuilder<QuerySnapshot>( // Specify the type for StreamBuilder
      stream: _blogPosts,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs; // Access docs safely
          if (docs.isNotEmpty) {
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                docs[index].data() as Map<String, dynamic>;
                return Column(
                  children: <Widget>[
                    PostTile(
                      userId: _user!.uid,
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
        } else if (snapshot.hasError) {
          // Handle error state
          return Text('Error: ${snapshot.error}');
        } else {
          return noBlogPostWidget(); // Or a loading indicator
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
        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(fontFamily: 'OpenSans', color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(154, 183, 211, 1.0),
              ),
              accountName: Text(
                _userName,
                style:
                const TextStyle(fontFamily: 'OpenSans', color: Colors.white),
              ),
              accountEmail: Text(
                _userEmail,
                style:
                const TextStyle(fontFamily: 'OpenSans', color: Colors.white),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(profilePic),
              ),
            ),
            ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
              leading: const Icon(Icons.home, color: Colors.blueGrey),
              title: const Text(
                'Home',
                style:
                TextStyle(fontFamily: 'OpenSans', color: Colors.blueGrey),
              ),
            ),
            ListTile(
              onTap: () {
                if (_user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        uid: _user!.uid,
                        userEmail: _userEmail,
                      ),
                    ),
                  );
                } else {
                  // Handle the case where the user is not logged in
                  print("User is not logged in.");
                }
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
              leading: const Icon(Icons.person, color: Colors.blueGrey),
              title: const Text(
                'Profile',
                style:
                TextStyle(fontFamily: 'OpenSans', color: Colors.blueGrey),
              ),
            ),
            ListTile(
              onTap: () {
                if (_user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(
                        cuid: _user!.uid,
                      ),
                    ),
                  );
                } else {
                  // Handle the case where the user is not logged in
                  print("User is not logged in.");
                }
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
              leading: const Icon(Icons.search, color: Colors.blueGrey),
              title: const Text(
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
                    builder: (context) => const ManageBlogs(),
                  ),
                );
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
              leading: const Icon(Icons.edit, color: Colors.blueGrey),
              title: const Text(
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
                    builder: (context) => const TopBlogs(),
                  ),
                );
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
              leading: const Icon(Icons.arrow_drop_up, color: Colors.blueGrey),
              title: const Text(
                'Top Blogs',
                style:
                TextStyle(fontFamily: 'OpenSans', color: Colors.blueGrey),
              ),
            ),
            const Divider(),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutPage(),
                  ),
                );
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
              leading: const Icon(Icons.info, color: Colors.blueGrey),
              title: const Text(
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
                    builder: (context) => const Authenticate(),
                  ),
                      (Route<dynamic> route) => false,
                );
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
              leading: const Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red, fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
      body: blogPostsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateBlogPage(
                  uid: _user!.uid,
                  userName: _userName,
                  userEmail: _userEmail,
                ),
              ),
            ).then((value) {
              // Refresh the blog posts after returning from CreateBlogPage
              _loadUserData();
            });
          } else {
            // Handle the case where the user is not logged in
            print("User is not logged in.");
          }
        },
        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
        elevation: 10,
        child: const Icon(Icons.create, color: Colors.white, size: 30.0),
      ),
    );
  }
}