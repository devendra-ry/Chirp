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

  //get the reference of collection blogs in the database
  final CollectionReference blogCollection =
  Firestore.instance.collection('blogPosts');

  //get the reference of collection comments in the database
  final CollectionReference commentCollection =
  Firestore.instance.collection('comments');

  // create user data
  Future createUserData(String fullName, String email, String password) async {
    return await userCollection.document(uid).setData({
      'userId': uid,
      'fullName': fullName,
      'fullNameArray': fullName.toLowerCase().split(" "),
      'email': email,
      'password': password,
      'likedPosts': [],
      'dislikedPosts' : [],
      'posts': [],
      'follow': [],
      'followers': [],
      'location': '',
      'totalLikes': [],
      'totalDisLikes': [],
      'profileImage' : 'https://firebasestorage.googleapis.com/v0/b/blogging-app-e918a.appspot.com/o/profiles%2Fblank-profile-picture-973460_960_720.png?alt=media&token=bfd3784e-bfd2-44b5-93cb-0c26e3090ba4',
    });
  }

  // get user data
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).getDocuments();
    print(snapshot.documents[0].data);
    return snapshot;
  }

  Future getUserDataID(String id) async {
    QuerySnapshot snapshot =
    await userCollection.where('userId', isEqualTo: id).getDocuments();
    print(snapshot.documents[0].data);
    return snapshot;
  }

  Future updateUserData(String name,String location, String url) async{
    DocumentReference userRef = userCollection.document(uid);
    await userRef.updateData({
      'fullname': name,
      'location': location,
      'profileImage' : url,
    });
    return userRef.documentID;
  }

  // save blog post
  Future saveBlogPost(
      String title, String author, String authorEmail, String content, String url,String category) async {

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
      'postImage' : url,
      'likedBy': [],
      'dislikedBy' : [],
      'createdAt': new DateTime.now(),
      'category' : category,
      'categoryArray' :category.toLowerCase().split(" "),
      'favourite': false,
      'date': DateFormat.yMMMd('en_US').format(new DateTime.now())
    });

    await blogPostsRef.updateData({'blogPostId': blogPostsRef.documentID});

    await userRef.updateData({
      'posts': FieldValue.arrayUnion([blogPostsRef.documentID])
    });

    return blogPostsRef.documentID;
  }

  //update blog post
  Future updateBlogPost(String id, String title, String content, String url) async{
    DocumentReference blogRef = blogCollection.document(id);
    await blogRef.updateData({
      'blogPostTitle': title,
      'blogPostTitleArray': title.toLowerCase().split(" "),
      'blogPostContent': content,
      'postImage' : url,
    });

    return blogRef.documentID;
  }

  //delete blog post
  Future deleteBlogPost(String id) async {
    DocumentReference userRef = userCollection.document(uid);
    DocumentReference blogRef = blogCollection.document(id);
    DocumentReference comRef = commentCollection.document(id);
    await userRef.updateData({
      'posts': FieldValue.arrayRemove([id]),
    });
    await comRef.delete();
    await blogRef.delete();
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

  //search blogposts by category
  searchBlogPostsByCategory(String category) async {
    List<String> searchList = category.toLowerCase().split(" ");
    QuerySnapshot snapshot = await Firestore.instance
        .collection('blogPosts')
        .where('categoryArray', arrayContainsAny: searchList)
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
        'likedPosts': FieldValue.arrayRemove([blogPostId]),
        'totalLikes': FieldValue.arrayRemove([blogPostId]),
      });
      blogPostRef.updateData({
        'likedBy': FieldValue.arrayRemove([uid])
      });
    } else {
      userRef.updateData({
        'likedPosts': FieldValue.arrayUnion([blogPostId]),
        'totalLikes': FieldValue.arrayUnion([blogPostId]),
      });
      blogPostRef.updateData({
        'likedBy': FieldValue.arrayUnion([uid])
      });
    }
  }

  // liked blog posts
  Future togglingDisLikes(String blogPostId) async {
    DocumentReference userRef = userCollection.document(uid);
    DocumentSnapshot userSnap = await userRef.get();

    DocumentReference blogPostRef =
    Firestore.instance.collection('blogPosts').document(blogPostId);

    List<dynamic> dislikedPosts = await userSnap.data['dislikedPosts'];

    if (dislikedPosts.contains(blogPostId)) {
      userRef.updateData({
        'dislikedPosts': FieldValue.arrayRemove([blogPostId]),
        'totalDisLikes' : FieldValue.arrayRemove([blogPostId]),
      });
      blogPostRef.updateData({
        'dislikedBy': FieldValue.arrayRemove([uid])
      });
    } else {
      userRef.updateData({
        'dislikedPosts': FieldValue.arrayUnion([blogPostId]),
        'totalDisLikes' : FieldValue.arrayUnion([blogPostId]),
      });
      blogPostRef.updateData({
        'dislikedBy': FieldValue.arrayUnion([uid])
      });
    }
  }


  //follow
  Future follow(String cuid, String userId) async {
    DocumentReference userRef = userCollection.document(userId);
    DocumentSnapshot userSnap = await userRef.get();
    DocumentReference cuserRef = userCollection.document(cuid);
    DocumentSnapshot cuserSnap = await cuserRef.get();
    List<dynamic> follow = await userSnap.data['follow'];
    if (follow.contains(cuid)) {

    } else {
      userRef.updateData({
        'followers': FieldValue.arrayUnion([cuid]),
      });
      cuserRef.updateData({
        'follow': FieldValue.arrayUnion([uid]),
      });
    }
  }

  //unfollow
  Future unfollow(String cuid, String userId) async {
    DocumentReference userRef = userCollection.document(userId);
    DocumentSnapshot userSnap = await userRef.get();
    DocumentReference cuserRef = userCollection.document(cuid);
    DocumentSnapshot cuserSnap = await cuserRef.get();
    List<dynamic> follow = await userSnap.data['followers'];
    if (follow.contains(cuid)) {
      userRef.updateData({
        'followers': FieldValue.arrayRemove([cuid]),
      });
      cuserRef.updateData({
        'follow': FieldValue.arrayRemove([uid]),
      });
    } else {

    }
  }

  // get user blogposts
  getTopBlogPosts() async {
    // return await Firestore.instance.collection("users").where('email', isEqualTo: email).snapshots();
    return Firestore.instance
        .collection('blogPosts')
        .orderBy('likedBy', descending: true)
        .snapshots();
  }

  //get liked blogposts
  getLikedBlogPosts() async {
    // return await Firestore.instance.collection("users").where('email', isEqualTo: email).snapshots();
    return Firestore.instance
        .collection('blogPosts')
        .where('favourite', isEqualTo: true).orderBy('createdAt', descending: true)
        .snapshots();
  }

  //add to favourite
  Future addFavourite(String id) async {
    DocumentReference blogRef = blogCollection.document(id);
    await blogRef.updateData({
      'favourite': true,
    });
    return blogRef.documentID;
  }

  //remove from favourite
  Future removeFavourite(String id) async {
    DocumentReference blogRef = blogCollection.document(id);
    await blogRef.updateData({
      'favourite': false,
    });
    return blogRef.documentID;
  }

  //save comments
  Future saveComment(String uid,String name, String blogID, String comment) async{
    commentCollection.document(blogID).setData({
      'userId': uid,
      'userName': name,
      'comID': blogID,
      'comment': comment,
      'createdAt': new DateTime.now(),
      'date': DateFormat.yMMMd('en_US').format(new DateTime.now()),
    });
  }

  //get comments
  Future getComments(String id) async {
    return Firestore.instance
        .collection('comments')
        .where('comID', isEqualTo: id)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}