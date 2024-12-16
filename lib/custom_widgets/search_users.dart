import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/views/user_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchUsers extends StatefulWidget {
  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  TextEditingController searchEditingController = TextEditingController();
  QuerySnapshot? searchResultSnapshot;
  bool _isLoading = false;
  bool _hasUserSearched = false;

  // Removed Randomizer (not needed for basic functionality)

  _initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService()
          .searchUsersByName(searchEditingController.text)
          .then((snapshot) {
        setState(() {
          searchResultSnapshot = snapshot;
          _isLoading = false;
          _hasUserSearched = true;
        });
      });
    }
  }

  Widget blogPostsList() {
    return _hasUserSearched
        ? (searchResultSnapshot?.docs.isNotEmpty ?? false) // Use null-aware operator and check for empty list
        ? ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // Added to prevent scrolling issues within parent listview
      itemCount: searchResultSnapshot!.docs.length,
      itemBuilder: (context, index) {
        // Access data safely using a Map
        Map<String, dynamic> data =
        searchResultSnapshot!.docs[index].data() as Map<String, dynamic>;
        return Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserDetailsPage(
                      userId: data['userId'],
                      fullName: data['fullName'],
                      email: data['email'],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5.0, vertical: 10.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Colors.blue, // Placeholder color
                    child: Text(
                      data['fullName']
                          .substring(0, 1)
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    data['fullName'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Divider(height: 0.0),
            ),
          ],
        );
      },
    )
        : const Padding(
      padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: Center(child: Text('No results found...')),
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
            color: const Color.fromRGBO(154, 183, 211, 1.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchEditingController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                        hintText: "Search users...",
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        border: InputBorder.none),
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      _initiateSearch();
                    },
                    child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40)),
                        child: const Icon(Icons.search, color: Colors.black)))
              ],
            ),
          ),
          _isLoading
              ? const Padding(
            padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
            child: Center(child: CircularProgressIndicator()),
          )
              : Expanded(child: blogPostsList()) // Added Expanded
        ],
      ),
    );
  }
}