import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;
  final String userEmail;

  EditProfilePage({this.uid, this.userEmail});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  QuerySnapshot userSnap;
  bool _isLoading = true;
  String _error = '';
  TextEditingController _fullNameEditingController = new TextEditingController();
  TextEditingController _location = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  _updateDetails() async{
    if (_fullNameEditingController.text != '' && _location.text != ''){
      await DatabaseService(uid: widget.uid).updateUserData(_fullNameEditingController.text,_location.text).then((res) {
        setState(() {
          if (res!= null) {
            _isLoading = true;
            Navigator.of(context).pop();
          }
          else {
            setState(() {
              _error = 'Error Updating';
              _isLoading = false;
            });
          }
        });
      } );
    }
  }

  _getUserDetails () async{
    await DatabaseService(uid: widget.uid).getUserData(widget.userEmail).then((res) {
      setState(() {
        userSnap = res;
        _isLoading = false;
      });
    } );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading?Loading():Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.green,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Text(
                "Edit Profile",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Sundar_Pichai_WEF_2020.png/330px-Sundar_Pichai_WEF_2020.png',
                              ))),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color: Colors.green,
                          ),
                          child: GestureDetector(
                            onTap: (){},
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: TextFormField(
                  controller: _fullNameEditingController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 3),
                    labelText: 'Full Name',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: userSnap.documents[0].data['fullName'].toString(),
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                    validator: (val) => val.isEmpty
                        ? 'This field cannot be blank'
                        : null
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: TextFormField(
                  controller: _location,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 3),
                    labelText: 'Location',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: (userSnap.documents[0].data['location'] != null)?userSnap.documents[0].data['location'].toString():'',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                    validator: (val) => val.isEmpty
                        ? 'This field cannot be blank'
                        : null
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlineButton(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("CANCEL",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.black)),
                  ),
                  FlatButton(
                    onPressed: () {
                      _updateDetails();
                    },
                    color: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 35,
              ),
              Text(
                _error,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}