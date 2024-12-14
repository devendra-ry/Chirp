import 'package:blogging_app/models/blogpost.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:blogging_app/views/comments.dart';
import 'package:blogging_app/views/create_comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share/share.dart';
import 'package:flutter/material.dart';

class ArticlePage extends StatefulWidget {
  final String userId;
  final String blogPostId;
  final String postImage;

  ArticlePage({Key key, this.userId, this.blogPostId, this.postImage});

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  BlogPost blogPostDetails = new BlogPost();
  bool _isLoading = true;
  bool _isLiked;
  bool _isdisLiked;
  bool _isFavourite;
  DocumentReference blogPostRef;
  DocumentSnapshot blogPostSnap;
  String userName;
  QuerySnapshot userSnap;

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

    List<dynamic> dislikedBy = blogPostSnap.data['dislikedBy'];
    if (dislikedBy.contains(widget.userId)) {
      setState(() {
        _isdisLiked = true;
      });
    } else {
      setState(() {
        _isdisLiked = false;
      });
    }

    _isFavourite = blogPostSnap.data['favourite'];
    if(_isFavourite){
      setState(() {
        _isFavourite = true;
      });
    }else{
      setState(() {
        _isFavourite = false;
      });
    }

    print(blogPostSnap.data);
    print('----------------------${blogPostSnap.data['blogPostId']}');

    await DatabaseService(uid: widget.userId).getUserDataID(widget.userId).then((res) {
      setState(() {
        userSnap = res;
        userName = userSnap.documents[0].data['fullName'].toString();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return _isLoading ? Loading() : Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(blogPostDetails.blogPostTitle,
          style: TextStyle(fontFamily: 'OpenSans',color: Colors.white),),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.share), onPressed: (){
            share(context);
          },)
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                  constraints: BoxConstraints.expand(height: height * 0.3),
                  child: Image.network(widget.postImage)),
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
                                  ? Icon(Icons.thumb_up,color: Colors.pinkAccent,
                                  size: 17.0)
                                  : Icon(Icons.thumb_up, size: 17.0))
                                  : Text(''),
                              // Icon(Icons.thumb_up, size: 17.0),
                              SizedBox(width: 20.0),
                              blogPostSnap != null
                                  ? Text(
                                  '${blogPostSnap.data['likedBy'].length}',
                                  style: TextStyle(fontSize: 13.0))
                                  : Text(''),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await DatabaseService(uid: widget.userId)
                              .togglingDisLikes(widget.blogPostId);
                          blogPostSnap = await blogPostRef.get();
                          setState(() {
                            _isdisLiked = !_isdisLiked;
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
                              _isdisLiked != null
                                  ? (_isdisLiked
                                  ? Icon(Icons.thumb_down,color: Colors.pinkAccent,
                                  size: 17.0)
                                  : Icon(Icons.thumb_down, size: 17.0))
                                  : Text('wrong'),
                              // Icon(Icons.thumb_up, size: 17.0),
                              SizedBox(width: 6.0),
                              blogPostSnap != null
                                  ? Text(
                                  '${blogPostSnap.data['dislikedBy'].length}',
                                  style: TextStyle(fontSize: 13.0))
                                  : Text(''),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0,),
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => Comments(userId:widget.userId,blogPostId: widget.blogPostId,)),
                          );
                        },
                        child: Icon(Icons.comment),
                      ),

                      SizedBox(width: 5.0,),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _isFavourite = !_isFavourite;
                          });
                          if (_isFavourite){
                            await DatabaseService(uid: widget.userId).addFavourite(blogPostSnap.data['blogPostId']);
                          }else{
                            await DatabaseService(uid: widget.userId).removeFavourite(blogPostSnap.data['blogPostId']);
                          }
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
                              _isFavourite != null
                                  ? (_isFavourite
                                  ? Icon(Icons.favorite,color: Colors.pinkAccent,
                                  size: 17.0)
                                  : Icon(Icons.favorite, size: 17.0))
                                  : Text(''),
                              // Icon(Icons.thumb_up, size: 17.0),
                              SizedBox(width: 20.0),
                            ],
                          ),
                        ),
                      ),
                    ],),
                    SizedBox(height: 10.0,),
                    Text(blogPostDetails.blogPostContent, textAlign: TextAlign.justify,),
                    SizedBox(height: 5.0,),
                    RaisedButton(
                        elevation: 5.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text(
                          'Comment',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => CreateComment(userId: widget.userId,userName: userName,blogPostId: widget.blogPostId,)),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  share(BuildContext context) {
    final RenderBox box = context.findRenderObject();

    Share.share("${blogPostDetails.blogPostTitle} - ${blogPostDetails.blogPostContent}",
        subject: blogPostDetails.blogPostContent,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}