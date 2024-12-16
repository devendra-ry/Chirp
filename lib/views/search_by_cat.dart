import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Category extends StatefulWidget {
  const Category({Key? key}) : super(key: key);

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final TextEditingController searchEditingController = TextEditingController();
  QuerySnapshot? searchResultSnapshot;
  bool _isLoading = false;
  bool _hasUserSearched = false;

  Future<void> _initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      try {
        setState(() {
          _isLoading = true;
        });

        final snapshot = await DatabaseService().searchBlogPostsByCategory(searchEditingController.text);

        setState(() {
          searchResultSnapshot = snapshot;
          _isLoading = false;
          _hasUserSearched = true;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _hasUserSearched = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching posts: $e')),
        );
      }
    }
  }

  Widget _blogPostsList() {
    if (!_hasUserSearched) {
      return const SizedBox.shrink();
    }

    if (searchResultSnapshot == null || searchResultSnapshot!.docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Center(child: Text('No results found...')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: searchResultSnapshot!.docs.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1.0,
        indent: 20.0,
        endIndent: 20.0,
      ),
      itemBuilder: (context, index) {
        final postData = searchResultSnapshot!.docs[index].data() as Map<String, dynamic>;

        return PostTile(
          userId: postData['userId'],
          blogPostId: postData['blogPostId'],
          blogPostTitle: postData['blogPostTitle'],
          blogPostContent: postData['blogPostContent'],
          date: postData['date'],
          postImage: postData['postImage'],
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
      body: SingleChildScrollView(
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
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _blogPostsList(),
          ],
        ),
      ),
    );
  }
}