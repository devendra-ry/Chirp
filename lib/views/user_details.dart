import 'package:blogging_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:randomizer_null_safe/randomizer_null_safe.dart';

class UserDetailsPage extends StatefulWidget {
  final String? cuid;
  final String? userId;
  final String? fullName;
  final String? email;

  const UserDetailsPage({
    Key? key,
    this.userId,
    this.fullName,
    this.email,
    this.cuid
  }) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  QuerySnapshot? userSnap;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  _getUserDetails() async {
    try {
      if (widget.userId != null && widget.email != null) {
        final res = await DatabaseService(uid: widget.userId).getUserData(widget.email!);
        setState(() {
          userSnap = res;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
    }
  }

  _follow() async {
    try {
      if (widget.cuid != null && widget.userId != null) {
        await DatabaseService(uid: widget.cuid).follow(widget.cuid!, widget.userId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Followed successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error following user: $e')),
      );
    }
  }

  _unfollow() async {
    try {
      if (widget.cuid != null && widget.userId != null) {
        await DatabaseService(uid: widget.cuid).unfollow(widget.cuid!, widget.userId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unfollowed successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error unfollowing user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final Randomizer randomizer = Randomizer.instance();

    // Null check for fullName
    final displayName = widget.fullName ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          displayName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: randomizer.randomColor(),
                    child: Text(
                      displayName.substring(0, 1).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 25.0),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Text(displayName),
                  Text(widget.email ?? 'No email'),
                  const SizedBox(height: 20.0),
                  _buildFollowButton(height, "Follow", _follow),
                  _buildFollowButton(height, "Unfollow", _unfollow),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(34),
                      bottom: const Radius.circular(34),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: userSnap != null && userSnap!.docs.isNotEmpty
                        ? Column(
                      children: [
                        _buildStatRow("Total posts",
                            (userSnap!.docs[0].data() as Map<String, dynamic>)['posts']?.length ?? 0),
                        _buildStatRow("Total likes",
                            (userSnap!.docs[0].data() as Map<String, dynamic>)['totalLikes']?.length ?? 0),
                        _buildStatRow("Total dislikes",
                            (userSnap!.docs[0].data() as Map<String, dynamic>)['totalDisLikes']?.length ?? 0),
                        _buildStatRow("Total followers",
                            (userSnap!.docs[0].data() as Map<String, dynamic>)['followers']?.length ?? 0),
                      ],
                    )
                        : const Center(child: Text('No user statistics available')),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(double height, String text, VoidCallback onPressed) {
    return Center(
      child: Container(
        height: height * 0.070,
        margin: const EdgeInsets.all(5),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80.0),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
              alignment: Alignment.center,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontSize: 30.0),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(fontSize: 30.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}