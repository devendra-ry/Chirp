import 'package:blogging_app/views/search_blog.dart';
import 'package:blogging_app/views/search_user.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20,vertical: 52),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Search",style: TextStyle(
                    fontSize: 40,
                  ),),
                ],
              ),
              SizedBox(height: 10.0,),
              SizedBox(
                width: double.infinity,
                height: height * 0.12,
                child: RaisedButton(
                    elevation: 0.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Text('Search Users',
                        style: TextStyle(
                            color: Colors.blue, fontSize: 16.0)),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => SearchUser()));
                    }),
              ),
              SizedBox(height: 10.0,),
              SizedBox(
                width: double.infinity,
                height: height * 0.12,
                child: RaisedButton(
                    elevation: 0.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Text('Search Blogs',
                        style: TextStyle(
                            color: Colors.blue, fontSize: 16.0)),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => SearchBlog()));
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
