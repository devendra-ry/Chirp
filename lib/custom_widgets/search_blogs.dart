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
  late QuerySnapshot<Map<String, dynamic>> searchResultSnapshot;
  bool _isLoading = false;
  bool _hasUserSearched = false;

  Future<void> _initiateSearch() async {
    if(searchEditingController.text.isNotEmpty){
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error searching posts: $e'))
        );
      }
    }
  }

  Widget blogPostsList() {
    return _hasUserSearched
        ? (searchResultSnapshot.docs.isEmpty)
        ? const Padding(
      padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: Center(child: Text('No results found...')),
    )
        : ListView.builder(
        shrinkWrap: true,
        itemCount: searchResultSnapshot.docs.length,
        itemBuilder: (context, index) {
          final postData = searchResultSnapshot.docs[index].data();
          return Column(
            children: <Widget>[
              PostTile(
                userId: postData['userId'],
                blogPostId: postData['blogPostId'],
                blogPostTitle: postData['blogPostTitle'],
                blogPostContent: postData['blogPostContent'],
                date: postData['date'],
              ),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Divider(height: 0.0)
              ),
            ],
          );
        }
    )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              color: Colors.black87,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchEditingController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                          hintText: "Search blog posts...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: InputBorder.none
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
                              borderRadius: BorderRadius.circular(40)
                          ),
                          child: const Icon(Icons.search, color: Colors.white)
                      )
                  )
                ],
              ),
            ),
            _isLoading
                ? const Padding(
              padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
              child: Center(child: CircularProgressIndicator()),
            )
                : blogPostsList()
          ]
      ),
    );
  }

  @override
  void dispose() {
    searchEditingController.dispose();
    super.dispose();
  }
}