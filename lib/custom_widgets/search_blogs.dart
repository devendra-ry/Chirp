import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchBlogPosts extends StatefulWidget {
  const SearchBlogPosts({Key? key}) : super(key: key);

  @override
  _SearchBlogPostsState createState() => _SearchBlogPostsState();
}

class _SearchBlogPostsState extends State<SearchBlogPosts> {
  final TextEditingController searchEditingController = TextEditingController();
  QuerySnapshot<Map<String, dynamic>>? searchResultSnapshot;
  bool _isLoading = false;
  bool _hasUserSearched = false;

  Future<void> _initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        final snapshot = await DatabaseService()
            .searchBlogPostsByName(searchEditingController.text);
        setState(() {
          searchResultSnapshot = snapshot;
          _hasUserSearched = true;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error searching posts: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget blogPostsList() {
    if (_hasUserSearched) {
      if (searchResultSnapshot == null || searchResultSnapshot!.docs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
          child: Center(child: Text('No results found...')),
        );
      } else {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searchResultSnapshot!.docs.length,
          itemBuilder: (context, index) {
            final postData = searchResultSnapshot!.docs[index].data();
            return Column(
              children: <Widget>[
                PostTile(
                  userId: postData['userId'],
                  blogPostId: postData['blogPostId'],
                  blogPostTitle: postData['blogPostTitle'],
                  blogPostContent: postData['blogPostContent'],
                  date: postData['date'],
                  postImage: postData['postImage'],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Divider(height: 0.0),
                ),
              ],
            );
          },
        );
      }
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Search Blogs',
          style: TextStyle(fontFamily: 'OpenSans', color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: height * 0.04),
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.black38.withAlpha(10),
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchEditingController,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search blog posts...",
                      hintStyle: TextStyle(
                        color: Colors.black.withAlpha(120),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _initiateSearch,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(child: blogPostsList()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchEditingController.dispose();
    super.dispose();
  }
}