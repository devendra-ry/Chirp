import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/services/authentication_service.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/randomizer.dart';

class UserDetailsPage extends StatefulWidget {
  final String cuid;
  final String userId;
  final String fullName;
  final String email;

  UserDetailsPage({this.userId, this.fullName, this.email, this.cuid});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {

  QuerySnapshot userSnap;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    print(widget.cuid);
    print(widget.userId);
  }

  _getUserDetails () async{
    await DatabaseService(uid: widget.userId).getUserData(widget.email).then((res) {
      setState(() {
        userSnap = res;
        //_isLoading = false;
      });
    });
  }

  _follow() async {
    await DatabaseService(uid: widget.cuid).follow(widget.cuid, widget.userId).then((value) => {
    });
  }

  _unfollow() async{
    await DatabaseService(uid: widget.cuid).unfollow(widget.cuid, widget.userId).then((value) => {
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    Randomizer randomizer = Randomizer();
    List<Color> colorsList = [
      Color(0xFF083663),
      Color(0xFFFE161D),
      Color(0xFF682D27),
      Color(0xFF61538D),
      Color(0xFF08363B),
      Color(0xFF319B4B),
      Color(0xFFF4D03F)
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.fullName,style: TextStyle(
          color: Colors.white
        ),),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 10.0),
        child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: randomizer.getspecifiedcolor(colorsList),
                      child: Text(widget.fullName.substring(0, 1).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 25.0)),
                    ),
                    SizedBox(height: 25.0),
                    Text(widget.fullName),
                    //SizedBox(height: 5.0),
                    Text(widget.email),
                    SizedBox(height: 20.0),
                    Center(
                      child: Container(
                        height: height * 0.070,
                        margin: EdgeInsets.all(5),
                        child: RaisedButton(
                          onPressed: () {
                            _follow();
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0)),
                          padding: EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Container(
                              constraints:
                              BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                              alignment: Alignment.center,
                              child: Text(
                                "Follow",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: height * 0.070,
                        margin: EdgeInsets.all(5),
                        child: RaisedButton(
                          onPressed: () {
                            _unfollow();
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0)),
                          padding: EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Container(
                              constraints:
                              BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                              alignment: Alignment.center,
                              child: Text(
                                "Unfollow",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //SizedBox(height: 20.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    //margin: EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(34),bottom: Radius.circular(34))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text("Total posts",style: TextStyle(
                                      fontSize: 30.0,
                                    ),),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text('${userSnap.documents[0].data['posts'].length}',style: TextStyle(
                                      fontSize: 30.0,
                                    ),),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text("Total likes",style: TextStyle(
                                      fontSize: 30.0,
                                    ),),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text('${userSnap.documents[0].data['totalLikes'].length}',style: TextStyle(
                                      fontSize: 30.0,
                                    ),),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text("Total dislikes",style: TextStyle(
                                      fontSize: 30.0,
                                    ),),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text('${userSnap.documents[0].data['totalDisLikes'].length}',style: TextStyle(
                                      fontSize: 30.0,
                                    ),),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text("Total followers",style: TextStyle(
                                      fontSize: 30.0,
                                    ),),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text('${userSnap.documents[0].data['followers'].length}',style: TextStyle(
                                      fontSize: 30.0,
                                    ),),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}


/*
blogPostsList(),
Stream _blogPosts;

  @override
  void initState() {
    super.initState();
    _getUserBlogPosts();
  }





Widget noBlogPostWidget() {
    return Center(
      child: Text('This user did not publish any blog posts...'),
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
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      PostTile(
                          userId: widget.userId,
                          blogPostId:
                          snapshot.data.documents[index].data['blogPostId'],
                          blogPostTitle: snapshot
                              .data.documents[index].data['blogPostTitle'],
                          blogPostContent: snapshot
                              .data.documents[index].data['blogPostContent'],
                          date: snapshot.data.documents[index].data['date'],
                          postImage: (snapshot.data.documents[index].data['postImage'] != null)? snapshot.data.documents[index].data['postImage']:'https://media.sproutsocial.com/uploads/2017/02/10x-featured-social-media-image-size.png'),
                      /*
                      PostTile(
                          userId: widget.userId,
                          blogPostId:
                              snapshot.data.documents[index].data['blogPostId'],
                          blogPostTitle: snapshot
                              .data.documents[index].data['blogPostTitle'],
                          blogPostContent: snapshot
                              .data.documents[index].data['blogPostContent'],
                          date: snapshot.data.documents[index].data['date']),

                       */
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


  _getUserBlogPosts() {
    DatabaseService(uid: widget.userId).getUserBlogPosts().then((snapshots) {
      setState(() {
        _blogPosts = snapshots;
      });
      print(_blogPosts);
    });
  }




  Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromRGBO(154, 183, 211, 1.0)),
                  borderRadius: BorderRadius.all(Radius.circular(18.0)),
                ),
                //padding: const EdgeInsets.only(left: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Blog Posts',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 10.0),



 */

/*
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Blog Posts',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

               */


