import 'package:blogging_app/views/ArticlePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostTile extends StatefulWidget {
  final String? userId; // Made nullable
  final String? blogPostId; // Made nullable
  final String? blogPostTitle; // Made nullable
  final String? blogPostContent; // Made nullable
  final String? date; // Made nullable
  final String? postImage; // Made nullable

  const PostTile({
    Key? key, // Made nullable
    required this.userId,
    required this.blogPostId,
    required this.blogPostTitle,
    required this.blogPostContent,
    required this.date,
    this.postImage,
  }) : super(key: key);

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  User? _user; // Made nullable

  // initState
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  _getCurrentUser() async {
    _user = FirebaseAuth.instance.currentUser; // Removed await
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        if (widget.userId != null &&
            widget.blogPostId != null &&
            widget.postImage != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ArticlePage(
                userId: widget.userId!,
                blogPostId: widget.blogPostId!,
                postImage: widget.postImage,
              ),
            ),
          );
        } else {
          // Handle cases where required data is missing
          print("Missing data for ArticlePage navigation");
        }
      },
      child: Container(
        margin: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromRGBO(154, 183, 211, 1.0)),
          borderRadius: const BorderRadius.all(Radius.circular(18.0)),
        ),
        child: Column(
          children: [
            header(),
            const Divider(
              color: Color.fromRGBO(154, 183, 211, 1.0),
            ),
            Container(
              constraints: BoxConstraints.expand(height: height * 0.3),
              child: Image.network(
                widget.postImage ?? '', // Provide a default value if null
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error); // Show an error icon if image loading fails
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: Colors.grey, // Placeholder color
          child: Text(
            widget.blogPostTitle?.substring(0, 1).toUpperCase() ??
                '', // Handle null title
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          widget.blogPostTitle ?? '', // Handle null title
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Text(
          widget.date ?? '', // Handle null date
          style: const TextStyle(color: Colors.grey, fontSize: 12.0),
        ),
      ),
    );
  }
}