import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:blogging_app/views/update_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatefulWidget {
  final String uid;
  final String userEmail;

  ProfilePage({Key key, this.uid, this.userEmail});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  QuerySnapshot userSnap;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _getUserDetails();
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
      backgroundColor: Color(0xff09031d),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back,  // add custom icons also
          ),
        ),
        elevation: 0,
        backgroundColor: Color(0xff09031d),
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
              child: Icon(Icons.create),
            ),
          ),
        ],
      ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
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
                        color: Colors.white,
                      ),
                      ),
                      Padding(padding: EdgeInsets.only(left: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on,
                            color: Colors.white,size:17),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: (userSnap.documents[0].data['location'] != null)?Text(userSnap.documents[0].data['location'].toString(),style: TextStyle(
                                color: Colors.white,
                              ),):Text('Not Provided',style: TextStyle(
                                color: Colors.white,
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
            Padding(
              padding: const EdgeInsets.only(right: 38.0,left: 38.0,top:15.0,bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${userSnap.documents[0].data['posts'].length}',style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),),
                      Text('Posts',
                        style: TextStyle(
                        color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    width: 0.2,
                    height: 22,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('388',style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),),
                      Text('following',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    width: 0.2,
                    height: 22,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 18,right: 18,top: 8,bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(33)),
                      gradient: LinearGradient(colors: [Color(0xff6D0EB5),Color(0xff4059F1)],
                      begin: Alignment.bottomRight,end: Alignment.centerLeft),
                    ),
                    child: FlatButton(onPressed: null,child: Text('Follow',style: TextStyle(
                      color: Colors.white,fontWeight: FontWeight.bold,
                    ),
                    ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(34))
              ),
                child: Column(),
            ),
            ),
          ],
        ),
    );
  }
}


