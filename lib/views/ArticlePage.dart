import 'package:blogging_app/models/blogpost.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ArticlePage extends StatefulWidget {
  final String userId;
  final String blogPostId;

  ArticlePage({Key key, this.userId, this.blogPostId});

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  BlogPost blogPostDetails = new BlogPost();
  bool _isLoading = true;
  bool _isLiked;
  DocumentReference blogPostRef;
  DocumentSnapshot blogPostSnap;

  @override
  void initState() {
    super.initState();
    _getBlogPostDetails();
  }

  _getBlogPostDetails() async {
    await DatabaseService(uid: widget.userId)
        .getBlogPostDetails(widget.blogPostId)
        .then((res) {
      setState(() {
        blogPostDetails = res;
        _isLoading = false;
      });
    });

    blogPostRef =
        Firestore.instance.collection('blogPosts').document(widget.blogPostId);
    blogPostSnap = await blogPostRef.get();

    List<dynamic> likedBy = blogPostSnap.data['likedBy'];
    if (likedBy.contains(widget.userId)) {
      setState(() {
        _isLiked = true;
      });
    } else {
      setState(() {
        _isLiked = false;
      });
    }

    print(blogPostSnap.data);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return _isLoading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text(blogPostDetails.blogPostTitle),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.share), onPressed: (){},)
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                  constraints: BoxConstraints.expand(height: height * 0.3),
                  child: Image.network("https://media.sproutsocial.com/uploads/2017/02/10x-featured-social-media-image-size.png")),
              Container(
                margin: EdgeInsets.fromLTRB(16.0, 200.0,16.0,16.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0)
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(blogPostDetails.blogPostTitle, style: Theme.of(context).textTheme.title,),
                    SizedBox(height: 10.0),
                    Text("${blogPostDetails.date} By ${blogPostDetails.blogPostAuthor}"),
                    SizedBox(height: 10.0),
                    Divider(),
                    SizedBox(height: 10.0,),
                    Row(children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          await DatabaseService(uid: widget.userId)
                              .togglingLikes(widget.blogPostId);
                          blogPostSnap = await blogPostRef.get();
                          setState(() {
                            _isLiked = !_isLiked;
                          });
                        },
                        child: Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 7.0),
                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _isLiked != null
                                  ? (_isLiked
                                  ? Icon(Icons.favorite,color: Colors.pinkAccent,
                                  size: 17.0)
                                  : Icon(Icons.favorite_border, size: 17.0))
                                  : Text(''),
                              // Icon(Icons.thumb_up, size: 17.0),
                              SizedBox(width: 7.0),
                              blogPostSnap != null
                                  ? Text(
                                  '${blogPostSnap.data['likedBy'].length} Like(s)',
                                  style: TextStyle(fontSize: 13.0))
                                  : Text(''),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0,),
                      Icon(Icons.comment),
                      SizedBox(width: 5.0,),
                      Text("2.2k"),
                    ],),
                    SizedBox(height: 10.0,),
                    Text(blogPostDetails.blogPostContent, textAlign: TextAlign.justify,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
