import 'package:blogging_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/randomizer.dart';


class CommentTile extends StatefulWidget {
  final String userName;
  final String blogPostId;
  final String comment;
  final String date;

  const CommentTile({Key key, this.userName, this.blogPostId, this.comment, this.date}) : super(key: key);


  @override
  _CommentTileState createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  Randomizer randomizer = Randomizer();
  List<Color> colorsList = [Color(0xFF083663), Color(0xFFFE161D), Color(0xFF682D27),
    Color(0xFF61538D), Color(0xFF08363B), Color(0xFF319B4B), Color(0xFFF4D03F)];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        children: [
          header(),
        ],
      ),
    );
  }

  header (){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: randomizer.getspecifiedcolor(colorsList),
          child: Text(widget.userName.substring(0, 1).toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        ),
        title: Text(
          widget.comment,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Text(widget.date, style: TextStyle(color: Colors.grey, fontSize: 12.0)),
      ),
    );
  }
}
