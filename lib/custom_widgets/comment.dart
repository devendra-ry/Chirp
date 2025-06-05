import 'package:flutter/material.dart';

class CommentTile extends StatefulWidget {
  final String userName;
  final String blogPostId;
  final String comment;
  final String date;

  const CommentTile({required Key key, required this.userName, required this.blogPostId, required this.comment, required this.date}) : super(key: key);

  @override
  _CommentTileState createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  Color getAvatarColor(String userName) {
    if (userName.isEmpty) {
      return Colors.grey; // Default color for empty username
    }
    final int hash = userName.codeUnits.fold(0, (prev, curr) => prev + curr);
    final List<Color> predefinedColors = [
      Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple,
      Colors.pink, Colors.teal, Colors.indigo, Colors.brown, Colors.cyan,
    ];
    return predefinedColors[hash % predefinedColors.length];
  }

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
          backgroundColor: getAvatarColor(widget.userName),
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