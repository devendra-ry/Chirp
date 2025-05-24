import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:blogging_app/views/update_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  final String userEmail;
  final String visitedUserId;

  const ProfilePage(
      {Key? key,
        required this.uid,
        required this.userEmail,
        required this.visitedUserId})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  QuerySnapshot? userSnap;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _getUserDetails();
    print(widget.uid);
  }

  _getUserDetails() async {
    await DatabaseService(uid: widget.uid)
        .getUserData(widget.userEmail)
        .then((res) {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          userSnap = res;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontFamily: 'OpenSans', color: Colors.white),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back,
              color: Colors.white // add custom icons also
          ),
        ),
        elevation: 0,
        //backgroundColor: Color(0xff09031d),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      uid: widget.uid,
                      userEmail: widget.userEmail,
                    ),
                  ),
                ).then((value) => setState(() {
                  _getUserDetails();
                }));
              },
              child: const Icon(Icons.create, color: Colors.white),
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
                    padding: const EdgeInsets.only(left: 28.0, top: 7),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                          (userSnap?.docs[0].data() as Map<String, dynamic>)['profileImage']
                              .toString()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 38.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (userSnap?.docs[0].data() as Map<String, dynamic>)['fullName']
                              .toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.black, size: 17),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: ((userSnap?.docs[0].data()
                                as Map<String, dynamic>)[
                                'location'] !=
                                    null)
                                    ? Text(
                                  (userSnap?.docs[0].data()
                                  as Map<String, dynamic>)['location']
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                )
                                    : const Text(
                                  'Not Provided',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
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
                  margin: const EdgeInsets.only(top: 15),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(34),
                          bottom: Radius.circular(34))),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    "Total posts",
                                    style: TextStyle(
                                      fontSize: 30.0,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '${(userSnap?.docs[0].data() as Map<String, dynamic>)['posts'].length}',
                                    style: const TextStyle(
                                      fontSize: 30.0,
                                    ),
                                  ),
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
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    "Total likes",
                                    style: TextStyle(
                                      fontSize: 30.0,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '${(userSnap?.docs[0].data() as Map<String, dynamic>)['totalLikes'].length}',
                                    style: const TextStyle(
                                      fontSize: 30.0,
                                    ),
                                  ),
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
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    "Total dislikes",
                                    style: TextStyle(
                                      fontSize: 30.0,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '${(userSnap?.docs[0].data() as Map<String, dynamic>)['totalDisLikes'].length}',
                                    style: const TextStyle(
                                      fontSize: 30.0,
                                    ),
                                  ),
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
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    "Total followers",
                                    style: TextStyle(
                                      fontSize: 30.0,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '${(userSnap?.docs[0].data() as Map<String, dynamic>)['followers'].length}',
                                    style: const TextStyle(
                                      fontSize: 30.0,
                                    ),
                                  ),
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