import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/views/user_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchUser extends StatefulWidget {
  final String? cuid; // Made nullable

  const SearchUser({Key? key, this.cuid}) : super(key: key); // Made key nullable

  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  TextEditingController searchEditingController = TextEditingController();
  QuerySnapshot? searchResultSnapshot;
  bool _isLoading = false;
  bool _hasUserSearched = false;

  // Removed Randomizer (not essential for core functionality)

  @override
  void initState() {
    super.initState();
    print("++++++++++++++++++++++++++++++++");
    print(widget.cuid);
  }

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
        ? (searchResultSnapshot?.docs.isNotEmpty ?? false)
        ? ListView.builder(
      physics: NeverScrollableScrollPhysics(), // Added for nested scrolling
      shrinkWrap: true,
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
                      cuid: widget.cuid,
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
                    backgroundColor: Colors.grey, // Placeholder color
                    child: Text(
                      data['fullName'].substring(0, 1).toUpperCase(),
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
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Search Users',
          style: TextStyle(fontFamily: 'OpenSans', color: Colors.white),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(children: [
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
                          hintText: "Search users...",
                          hintStyle: TextStyle(
                            color: Colors.black.withAlpha(120),
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
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            _isLoading
                ? const Padding(
              padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
              child: Center(child: CircularProgressIndicator()),
            )
                : blogPostsList() // No need for Expanded here
          ]),
        ),
      ),
    );
  }
}