import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchBlog extends StatefulWidget {
  const SearchBlog({Key? key}) : super(key: key);

  @override
  _SearchBlogState createState() => _SearchBlogState();
}

class _SearchBlogState extends State<SearchBlog> {
  final TextEditingController searchEditingController = TextEditingController();
  QuerySnapshot? searchResultSnapshot;
  bool _isLoading = false;
  bool _hasUserSearched = false;

  Future<void> _initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final snapshot = await DatabaseService().searchBlogPostsByName(searchEditingController.text);
        setState(() {
          searchResultSnapshot = snapshot;
          _isLoading = false;
          _hasUserSearched = true;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Optionally show an error dialog or snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching blogs: $e')),
        );
      }
    }
  }

  Widget blogPostsList() {
    if (!_hasUserSearched) {
      return Container();
    }

    if (searchResultSnapshot == null || searchResultSnapshot!.docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Center(child: Text('No results found...')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: searchResultSnapshot!.docs.length,
      itemBuilder: (context, index) {
        final docData = searchResultSnapshot!.docs[index].data() as Map<String, dynamic>;
        return Column(
          children: <Widget>[
            PostTile(
              userId: docData['userId'],
              blogPostId: docData['blogPostId'],
              blogPostTitle: docData['blogPostTitle'],
              blogPostContent: docData['blogPostContent'],
              date: docData['date'],
              postImage: docData['postImage'],
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

  @override
  void dispose() {
    searchEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: height * 0.06),
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
                          hintText: "Search blogs...",
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
                    ),
                  ],
                ),
              ),
              _isLoading
                  ? const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Center(child: CircularProgressIndicator()),
              )
                  : blogPostsList(),
            ],
          ),
        ),
      ),
    );
  }
}