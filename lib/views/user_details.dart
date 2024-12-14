import 'package:blogging_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:randomizer_null_safe/randomizer_null_safe.dart';

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
    Randomizer randomizer = Randomizer.instance();

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
                      backgroundColor: randomizer.randomColor(),
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