import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchBlogPosts extends StatefulWidget {

  @override
  _SearchBlogPostsState createState() => _SearchBlogPostsState();
}

class _SearchBlogPostsState extends State<SearchBlogPosts> {
   
  TextEditingController searchEditingController = new TextEditingController();
  late QuerySnapshot searchResultSnapshot;
  bool _isLoading = false;
  bool _hasUserSearched = false;

  _initiateSearch() async {
    if(searchEditingController.text.isNotEmpty){
      setState(() {
        _isLoading = true;
      });
      await DatabaseService().searchBlogPostsByName(searchEditingController.text).then((snapshot) {
        searchResultSnapshot = snapshot;
        // print(searchResultSnapshot.documents.length);
        setState(() {
          _isLoading = false;
          _hasUserSearched = true;
        });
      });
    }
  }

  Widget blogPostsList() {
    return _hasUserSearched ? (searchResultSnapshot.docs.length == 0) ?
    Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: Center(child: Text('No results found...')),
    )
    : 
    ListView.builder(
      shrinkWrap: true,
      itemCount: searchResultSnapshot.docs.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            PostTile(
              userId: searchResultSnapshot.docs[index].data["userId"],
              blogPostId: searchResultSnapshot.docs[index].data['blogPostId'],
              blogPostTitle: searchResultSnapshot.docs[index].data['blogPostTitle'],
              blogPostContent: searchResultSnapshot.docs[index].data['blogPostContent'],
              date: searchResultSnapshot.docs[index].data['date'],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(height: 0.0)
            ),
          ],
        );
      }
    )
  :
  Container();
  }

   @override
   Widget build(BuildContext context) {
     return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            color: Colors.black87,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchEditingController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
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
                  onTap: (){
                    _initiateSearch();
                  },
                  child: Container(
                    height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(40)
                      ),
                      child: Icon(Icons.search, color: Colors.white)
                  )
                )
              ],
            ),
          ),
          _isLoading ? Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
            child: Center(child: CircularProgressIndicator()),
          ) : blogPostsList()
        ]
      ),
    );
  }
}