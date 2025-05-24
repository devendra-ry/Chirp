import 'package:blogging_app/models/blogpost.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPostPage extends StatefulWidget {
  final String? userId;
  final String? blogPostId;

  BlogPostPage({this.userId, this.blogPostId});

  @override
  _BlogPostPageState createState() => _BlogPostPageState();
}

class _BlogPostPageState extends State<BlogPostPage> {
  BlogPost blogPostDetails = new BlogPost();
  bool _isLoading = true;
  late bool _isLiked;
  late DocumentReference blogPostRef;
  late DocumentSnapshot blogPostSnap;

  @override
  void initState() {
    super.initState();
    _getBlogPostDetails();
  }

  _getBlogPostDetails() async {
    blogPostDetails = await DatabaseService(uid: widget.userId)
        .getBlogPostDetails(widget.blogPostId!);
    setState(() {
      _isLoading = false;
    });

    blogPostRef = FirebaseFirestore.instance.collection('blogPosts').doc(widget.blogPostId!);
    blogPostSnap = await blogPostRef.get();

    List<dynamic> likedBy = (blogPostSnap.data() as Map<String, dynamic>)['likedBy'];
    if (likedBy.contains(widget.userId)) {
      setState(() {
        _isLiked = true;
      });
    } else {
      setState(() {
        _isLiked = false;
      });
    }

    print(blogPostSnap.data());
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text(blogPostDetails.blogPostTitle!),
            ),
            body: Center(
                child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
              children: <Widget>[
                Text(blogPostDetails.blogPostTitle!,
                    style: TextStyle(
                        fontSize: 40.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 20.0),
                Text('Author - ${blogPostDetails.blogPostAuthor}',
                    style:
                        TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic)),
                SizedBox(height: 5.0),
                Text('Email - ${blogPostDetails.blogPostAuthorEmail}',
                    style:
                        TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic)),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Published on - ${blogPostDetails.date}',
                        style: TextStyle(fontSize: 14.0, color: Colors.grey)),
                    GestureDetector(
                      onTap: () async {
                        await DatabaseService(uid: widget.userId)
                            .toggleLikes(widget.blogPostId!);
                        blogPostSnap = await blogPostRef.get();
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 7.0),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _isLiked
                                ? Icon(Icons.thumb_up,
                                    size: 17.0, color: Colors.blueAccent)
                                : Icon(Icons.thumb_up, size: 17.0),
                            SizedBox(width: 7.0),
                            Text(
                              '${(blogPostSnap.data() as Map<String, dynamic>)['likedBy'].length} Like(s)',
                              style: TextStyle(fontSize: 13.0),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 40.0),
                Text(blogPostDetails.blogPostContent!,
                    style: TextStyle(fontSize: 16.0)),
              ],
            )),
          );
  }
}