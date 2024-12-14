import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:blogging_app/views/update_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  final String userEmail;
  final String visitedUserId;
  ProfilePage({Key key, this.uid, this.userEmail, this.visitedUserId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  QuerySnapshot userSnap;
  bool _isLoading = true;


  int _followersCount = 0;
  int _followingCount = 0;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    print(widget.uid);
  }

  _getUserDetails () async{
    await DatabaseService(uid: widget.uid).getUserData(widget.userEmail).then((res) {
      setState(() {
        userSnap = res;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading?Loading():Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(fontFamily: 'OpenSans',color: Colors.white),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back,
              color: Colors.white// add custom icons also
          ),
        ),
        elevation: 0,
        //backgroundColor: Color(0xff09031d),
        actions: [
          Padding(padding: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditProfilePage(uid: widget.uid,userEmail: widget.userEmail,),
                  ),
                ).then((value) => setState((){
                  _getUserDetails();
                }));
              },
              child: Icon(Icons.create,color: Colors.white),
            ),
          ),
        ],
      ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0,top:7),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(userSnap.documents[0].data['profileImage'].toString()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 38.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userSnap.documents[0].data['fullName'].toString(),
                            style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Colors.black,
                          ),
                          ),
                          Padding(padding: EdgeInsets.only(left: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on,
                                color: Colors.black,size:17),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: (userSnap.documents[0].data['location'] != null)?Text(userSnap.documents[0].data['location'].toString(),style: TextStyle(
                                    color: Colors.black,
                                  ),):Text('Not Provided',style: TextStyle(
                                    color: Colors.black,
                                  ),),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 15),
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