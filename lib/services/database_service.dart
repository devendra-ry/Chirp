import 'package:blogging_app/models/blogpost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  //unique id if the document stored in collection
  final String uid;
  DatabaseService({this.uid});

  //get the reference of collection users in the database
  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  // create user data
  Future createUserData(String fullName, String email, String password) async {
    return await userCollection.document(uid).setData({
      'userId': uid,
      'fullName': fullName,
      'fullNameArray': fullName.toLowerCase().split(" "),
      'email': email,
      'password': password,
      'likedPosts': [],
      'posts': [],
      'follow': [],
      'followers': [],
    });
  }

  // get user data
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).getDocuments();
    print(snapshot.documents[0].data);
    return snapshot;
  }

  // save blog post
  Future saveBlogPost(
      String title, String author, String authorEmail, String content) async {

    DocumentReference userRef = userCollection.document(uid);

    DocumentReference blogPostsRef =
        await Firestore.instance.collection('blogPosts').add({
      'userId': uid,
      'blogPostId': '',
      'blogPostTitle': title,
      'blogPostTitleArray': title.toLowerCase().split(" "),
      'blogPostAuthor': author,
      'blogPostAuthorEmail': authorEmail,
      'blogPostContent': content,
      'likedBy': [],
      'createdAt': new DateTime.now(),
      'date': DateFormat.yMMMd('en_US').format(new DateTime.now())
    });

    await blogPostsRef.updateData({'blogPostId': blogPostsRef.documentID});

    await userRef.updateData({
      'posts': FieldValue.arrayUnion([title])
    });

    return blogPostsRef.documentID;
  }

  // get user blog posts
  getUserBlogPosts() async {
    // return await Firestore.instance.collection("users").where('email', isEqualTo: email).snapshots();
    return Firestore.instance
        .collection('blogPosts')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // get blog post details
  Future getBlogPostDetails(String blogPostId) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection('blogPosts')
        .where('blogPostId', isEqualTo: blogPostId)
        .getDocuments();
    BlogPost blogPostDetails = new BlogPost(
      blogPostTitle: snapshot.documents[0].data['blogPostTitle'],
      blogPostAuthor: snapshot.documents[0].data['blogPostAuthor'],
      blogPostAuthorEmail: snapshot.documents[0].data['blogPostAuthorEmail'],
      blogPostContent: snapshot.documents[0].data['blogPostContent'],
      date: snapshot.documents[0].data['date'],
    );

    return blogPostDetails;
  }

  // search blogposts
  searchBlogPostsByName(String blogPostName) async {
    List<String> searchList = blogPostName.toLowerCase().split(" ");
    QuerySnapshot snapshot = await Firestore.instance
        .collection('blogPosts')
        .where('blogPostTitleArray', arrayContainsAny: searchList)
        .getDocuments();
    // print(snapshot.documents.length);

    return snapshot;
  }

  // search users by name
  searchUsersByName(String userName) async {
    List<String> searchList = userName.toLowerCase().split(" ");
    QuerySnapshot snapshot = await Firestore.instance
        .collection('users')
        .where('fullNameArray', arrayContainsAny: searchList)
        .getDocuments();
    print(snapshot.documents.length);

    return snapshot;
  }

  // liked blog posts
  Future togglingLikes(String blogPostId) async {
    DocumentReference userRef = userCollection.document(uid);
    DocumentSnapshot userSnap = await userRef.get();

    DocumentReference blogPostRef =
        Firestore.instance.collection('blogPosts').document(blogPostId);

    List<dynamic> likedPosts = await userSnap.data['likedPosts'];

    if (likedPosts.contains(blogPostId)) {
      userRef.updateData({
        'likedPosts': FieldValue.arrayRemove([blogPostId])
      });
      blogPostRef.updateData({
        'likedBy': FieldValue.arrayRemove([uid])
      });
    } else {
      userRef.updateData({
        'likedPosts': FieldValue.arrayUnion([blogPostId])
      });
      blogPostRef.updateData({
        'likedBy': FieldValue.arrayUnion([uid])
      });
    }
  }
}
