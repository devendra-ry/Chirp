import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Favourites extends StatefulWidget {
  const Favourites({Key? key}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  // Variables
  User? _user;
  QuerySnapshot? userSnap;
  Stream<QuerySnapshot>? _blogPosts;
  String profilePic = '';
  static const String defaultPic =
      'https://firebasestorage.googleapis.com/v0/b/blogging-app-e918a.appspot.com/o/profiles%2Fblank-profile-picture-973460_960_720.png?alt=media&token=bfd3784e-bfd2-44b5-93cb-0c26e3090ba4';

  @override
  void initState() {
    super.initState();
    _getBlogPosts();
  }

  Future<void> _getBlogPosts() async {
    // Get the current user
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      try {
        // Get the blogs of the user
        _blogPosts = DatabaseService(uid: _user!.uid).getLikedBlogPosts();

        // Get user data
        userSnap = await DatabaseService(uid: _user!.uid).getUserDataById(_user!.uid);

        profilePic = (userSnap!.docs[0].data() as Map<String, dynamic>)['profileImage'] as String? ?? defaultPic;

        // Trigger a rebuild to show the updated data
        if (mounted) setState(() {});
      } catch (e) {
        // Handle any errors that might occur during data fetching
        print('Error fetching user data: $e');
      }
    } else {
      // Handle the case where the user is not logged in
      print("User not logged in.");
      // You might want to redirect to a login screen or handle it differently
    }
  }

  Widget _noBlogPostWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20.0),
          Center(
            child: Text(
              "No favourites yet",
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blogPostsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _blogPosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _noBlogPostWidget();
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
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
          'Favourite Blogs',
          style: TextStyle(fontFamily: 'OpenSans', color: Colors.white),
        ),
      ),
      body: _blogPostsList(),
    );
  }
}