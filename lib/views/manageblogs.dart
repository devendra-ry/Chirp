import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/services/authentication_service.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/views/delete_blogs.dart';
import 'package:blogging_app/views/edit_blogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageBlogs extends StatefulWidget {
  @override
  _ManageBlogsState createState() => _ManageBlogsState();
}

class _ManageBlogsState extends State<ManageBlogs> {

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20,vertical: 52),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Manage your blogs",style: TextStyle(
                    fontSize: 34,
                  ),),
                ],
              ),
              SizedBox(height: 10.0,),
              SizedBox(
                width: double.infinity,
                height: height * 0.12,
                child: RaisedButton(
                    elevation: 0.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Text('Edit blogs',
                        style: TextStyle(
                            color: Colors.blue, fontSize: 16.0)),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => EditBlogs()));
                    }),
              ),
              SizedBox(height: 10.0,),
              SizedBox(
                width: double.infinity,
                height: height * 0.12,
                child: RaisedButton(
                    elevation: 0.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Text('Delete blogs',
                        style: TextStyle(
                            color: Colors.blue, fontSize: 16.0)),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => DeleteBlogs()));
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
