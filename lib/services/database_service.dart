import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:blogging_app/models/blogpost.dart';

class DatabaseService {
  // Unique id for the document stored in collection
  final String? uid;

  // Firestore instance references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseService({this.uid});

  // Reference to users collection
  CollectionReference get userCollection => _firestore.collection('users');

  // Reference to blog posts collection
  CollectionReference get blogCollection => _firestore.collection('blogPosts');

  // Reference to comments collection
  CollectionReference get commentCollection => _firestore.collection('comments');

  // Create user data
  Future<void> createUserData(String fullName, String email, String password) async {
    await userCollection.doc(uid).set({
      'userId': uid,
      'fullName': fullName,
      'fullNameArray': fullName.toLowerCase().split(" "),
      'email': email,
      'password': password,
      'likedPosts': [],
      'dislikedPosts': [],
      'posts': [],
      'follow': [],
      'followers': [],
      'location': '',
      'totalLikes': [],
      'totalDisLikes': [],
      'profileImage': 'https://firebasestorage.googleapis.com/v0/b/blogging-app-e918a.appspot.com/o/profiles%2Fblank-profile-picture-973460_960_720.png?alt=media&token=bfd3784e-bfd2-44b5-93cb-0c26e3090ba4',
    });
  }

  // Get user data by email
  Future<QuerySnapshot> getUserData(String email) async {
    return await userCollection.where('email', isEqualTo: email).get();
  }

  // Get user data by ID
  Future<QuerySnapshot> getUserDataById(String id) async {
    return await userCollection.where('userId', isEqualTo: id).get();
  }

  // Update user data
  Future<String> updateUserData(String name, String location, String url) async {
    DocumentReference userRef = userCollection.doc(uid);
    await userRef.update({
      'fullName': name,
      'location': location,
      'profileImage': url,
    });
    return userRef.id;
  }

  // Save blog post
  Future<String> saveBlogPost({
    required String title,
    required String author,
    required String authorEmail,
    required String content,
    required String url,
    required String category
  }) async {
    DocumentReference blogPostRef = await blogCollection.add({
      'userId': uid,
      'blogPostId': '', // Will be updated immediately after creation
      'blogPostTitle': title,
      'blogPostTitleArray': title.toLowerCase().split(" "),
      'blogPostAuthor': author,
      'blogPostAuthorEmail': authorEmail,
      'blogPostContent': content,
      'postImage': url,
      'likedBy': [],
      'dislikedBy': [],
      'createdAt': DateTime.now(),
      'category': category,
      'categoryArray': category.toLowerCase().split(" "),
      'favourite': false,
      'date': DateFormat.yMMMd('en_US').format(DateTime.now())
    });

    // Update the blogPostId with the document's ID
    await blogPostRef.update({'blogPostId': blogPostRef.id});

    // Add blog post ID to user's posts
    await userCollection.doc(uid).update({
      'posts': FieldValue.arrayUnion([blogPostRef.id])
    });

    return blogPostRef.id;
  }

  // Update blog post
  Future<String> updateBlogPost({
    required String id,
    required String title,
    required String content,
    required String url
  }) async {
    DocumentReference blogRef = blogCollection.doc(id);
    await blogRef.update({
      'blogPostTitle': title,
      'blogPostTitleArray': title.toLowerCase().split(" "),
      'blogPostContent': content,
      'postImage': url,
    });

    return blogRef.id;
  }

  // Delete blog post
  Future<void> deleteBlogPost(String id) async {
    await userCollection.doc(uid).update({
      'posts': FieldValue.arrayRemove([id]),
    });

    // Delete associated comments
    await commentCollection.doc(id).delete();

    // Delete blog post
    await blogCollection.doc(id).delete();
  }

  // Get user's blog posts
  Stream<QuerySnapshot> getUserBlogPosts() {
    return blogCollection
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get blog post details
  Future<BlogPost> getBlogPostDetails(String blogPostId) async {
    QuerySnapshot snapshot = await blogCollection
        .where('blogPostId', isEqualTo: blogPostId)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Blog post not found');
    }

    var data = snapshot.docs.first.data() as Map<String, dynamic>;
    return BlogPost(
      blogPostTitle: data['blogPostTitle'],
      blogPostAuthor: data['blogPostAuthor'],
      blogPostAuthorEmail: data['blogPostAuthorEmail'],
      blogPostContent: data['blogPostContent'],
      date: data['date'],
    );
  }

  // Search blog posts by name
  Future<QuerySnapshot> searchBlogPostsByName(String blogPostName) async {
    List<String> searchList = blogPostName.toLowerCase().split(" ");
    return await blogCollection
        .where('blogPostTitleArray', arrayContainsAny: searchList)
        .get();
  }

  // Search blog posts by category
  Future<QuerySnapshot> searchBlogPostsByCategory(String category) async {
    List<String> searchList = category.toLowerCase().split(" ");
    return await blogCollection
        .where('categoryArray', arrayContainsAny: searchList)
        .get();
  }

  // Search users by name
  Future<QuerySnapshot> searchUsersByName(String userName) async {
    List<String> searchList = userName.toLowerCase().split(" ");
    return await userCollection
        .where('fullNameArray', arrayContainsAny: searchList)
        .get();
  }

  // Toggle likes
  Future<void> toggleLikes(String blogPostId) async {
    DocumentReference userRef = userCollection.doc(uid);
    DocumentReference blogPostRef = blogCollection.doc(blogPostId);

    DocumentSnapshot userSnap = await userRef.get();
    List<dynamic> likedPosts = userSnap.get('likedPosts') ?? [];

    if (likedPosts.contains(blogPostId)) {
      // Unlike the post
      await userRef.update({
        'likedPosts': FieldValue.arrayRemove([blogPostId]),
        'totalLikes': FieldValue.arrayRemove([blogPostId]),
      });
      await blogPostRef.update({
        'likedBy': FieldValue.arrayRemove([uid])
      });
    } else {
      // Like the post
      await userRef.update({
        'likedPosts': FieldValue.arrayUnion([blogPostId]),
        'totalLikes': FieldValue.arrayUnion([blogPostId]),
      });
      await blogPostRef.update({
        'likedBy': FieldValue.arrayUnion([uid])
      });
    }
  }

  // Toggle dislikes
  Future<void> toggleDislikes(String blogPostId) async {
    DocumentReference userRef = userCollection.doc(uid);
    DocumentReference blogPostRef = blogCollection.doc(blogPostId);

    DocumentSnapshot userSnap = await userRef.get();
    List<dynamic> dislikedPosts = userSnap.get('dislikedPosts') ?? [];

    if (dislikedPosts.contains(blogPostId)) {
      // Remove dislike
      await userRef.update({
        'dislikedPosts': FieldValue.arrayRemove([blogPostId]),
        'totalDisLikes': FieldValue.arrayRemove([blogPostId]),
      });
      await blogPostRef.update({
        'dislikedBy': FieldValue.arrayRemove([uid])
      });
    } else {
      // Dislike the post
      await userRef.update({
        'dislikedPosts': FieldValue.arrayUnion([blogPostId]),
        'totalDisLikes': FieldValue.arrayUnion([blogPostId]),
      });
      await blogPostRef.update({
        'dislikedBy': FieldValue.arrayUnion([uid])
      });
    }
  }

  // Follow a user
  Future<void> follow(String currentUserId, String targetUserId) async {
    DocumentReference targetUserRef = userCollection.doc(targetUserId);
    DocumentReference currentUserRef = userCollection.doc(currentUserId);

    DocumentSnapshot targetUserSnap = await targetUserRef.get();
    List<dynamic> targetFollowers = targetUserSnap.get('followers') ?? [];

    if (!targetFollowers.contains(currentUserId)) {
      await targetUserRef.update({
        'followers': FieldValue.arrayUnion([currentUserId]),
      });
      await currentUserRef.update({
        'follow': FieldValue.arrayUnion([targetUserId]),
      });
    }
  }

  // Unfollow a user
  Future<void> unfollow(String currentUserId, String targetUserId) async {
    DocumentReference targetUserRef = userCollection.doc(targetUserId);
    DocumentReference currentUserRef = userCollection.doc(currentUserId);

    DocumentSnapshot targetUserSnap = await targetUserRef.get();
    List<dynamic> targetFollowers = targetUserSnap.get('followers') ?? [];

    if (targetFollowers.contains(currentUserId)) {
      await targetUserRef.update({
        'followers': FieldValue.arrayRemove([currentUserId]),
      });
      await currentUserRef.update({
        'follow': FieldValue.arrayRemove([targetUserId]),
      });
    }
  }

  // Get top blog posts
  Stream<QuerySnapshot> getTopBlogPosts() {
    return blogCollection
        .orderBy('likedBy', descending: true)
        .snapshots();
  }

  // Get liked blog posts
  Stream<QuerySnapshot> getLikedBlogPosts() {
    return blogCollection
        .where('favourite', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add to favorites
  Future<String> addFavorite(String id) async {
    DocumentReference blogRef = blogCollection.doc(id);
    await blogRef.update({
      'favourite': true,
    });
    return blogRef.id;
  }

  // Remove from favorites
  Future<String> removeFavorite(String id) async {
    DocumentReference blogRef = blogCollection.doc(id);
    await blogRef.update({
      'favourite': false,
    });
    return blogRef.id;
  }

  // Save comment
  Future<void> saveComment({
    required String uid,
    required String name,
    required String blogId,
    required String comment
  }) async {
    await commentCollection.doc(blogId).set({
      'userId': uid,
      'userName': name,
      'comID': blogId,
      'comment': comment,
      'createdAt': DateTime.now(),
      'date': DateFormat.yMMMd('en_US').format(DateTime.now()),
    });
  }

  // Get comments
  Stream<QuerySnapshot> getComments(String id) {
    return commentCollection
        .where('comID', isEqualTo: id)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}