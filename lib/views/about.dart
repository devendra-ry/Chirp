import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("About",style: TextStyle(
            fontFamily: 'OpenSans',color: Colors.white,
        ),),
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('About',
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 30.0),
            Text(
                "This is a blogging app made using Flutter and Firebase. Users can now start posting content very easily. Search for other users around the globe and also see other people's content. Like other people's blog posts.",
                style: TextStyle(fontSize: 18.0)),
          ],
        ),
      ),
    );
  }
}
