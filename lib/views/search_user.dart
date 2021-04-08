import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/views/user_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/randomizer.dart';

class SearchUser extends StatefulWidget {

  final String cuid;

  const SearchUser({Key key, this.cuid}) : super(key: key);

  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {

  TextEditingController searchEditingController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;
  bool _isLoading = false;
  bool _hasUserSearched = false;
  Randomizer randomizer = Randomizer();
  List<Color> colorsList = [Color(0xFF083663), Color(0xFFFE161D), Color(0xFF682D27),
    Color(0xFF61538D), Color(0xFF08363B), Color(0xFF319B4B), Color(0xFFF4D03F)];

  @override
  void initState() {
    super.initState();
    print("++++++++++++++++++++++++++++++++");
    print(widget.cuid);
  }

  _initiateSearch() async {
    if(searchEditingController.text.isNotEmpty){
      setState(() {
        _isLoading = true;
      });
      await DatabaseService().searchUsersByName(searchEditingController.text).then((snapshot) {
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
    return _hasUserSearched ? (searchResultSnapshot.documents.length == 0) ?
    Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: Center(child: Text('No results found...')),
    )
        :
    ListView.builder(
        shrinkWrap: true,
        itemCount: searchResultSnapshot.documents.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserDetailsPage(cuid: widget.cuid, userId: searchResultSnapshot.documents[index].data['userId'], fullName: searchResultSnapshot.documents[index].data['fullName'], email: searchResultSnapshot.documents[index].data['email'],)));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: randomizer.getspecifiedcolor(colorsList),
                      child: Text(searchResultSnapshot.documents[index].data['fullName'].substring(0, 1).toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                    ),
                    title: Text(
                      searchResultSnapshot.documents[index].data['fullName'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Divider(height: 0.0)
              ),
            ],
          );
        }
    )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body:Container(
      child: SingleChildScrollView(
        child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: height * 0.06),
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.black38.withAlpha(10),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchEditingController,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                            hintText: "Search users...",
                            hintStyle: TextStyle(
                              color: Colors.black.withAlpha(120),
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
      ),
    ),
    );
  }
}