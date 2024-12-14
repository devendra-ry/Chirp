import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as Path;
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String? uid;
  final String? userEmail;

  EditProfilePage({this.uid, this.userEmail});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  QuerySnapshot? userSnap;
  bool _isLoading = true;
  String _error = '';
  TextEditingController _fullNameEditingController = new TextEditingController();
  TextEditingController _location = new TextEditingController();
  File? _image;
  final picker = ImagePicker();
  String newURL = 'https://firebasestorage.googleapis.com/v0/b/blogging-app-e918a.appspot.com/o/profiles%2Fblank-profile-picture-973460_960_720.png?alt=media&token=bfd3784e-bfd2-44b5-93cb-0c26e3090ba4';
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  _updateDetails() async{
    if (_fullNameEditingController.text != '' || _location.text != '' || newURL != ''){
      await DatabaseService(uid: widget.uid).updateUserData(_fullNameEditingController.text,_location.text, newURL).then((res) {
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
        //newURL = userSnap.documents[0].data['profileImage'].toString();
        _fullNameEditingController.text = userSnap.docs[0].data['fullName'].toString();
        _location.text = userSnap.docs[0].data['location'].toString();
        profileImage = userSnap.docs[0].data['profileImage'].toString();
        _isLoading = false;
      });
    } );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery,imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('----------------Image Selected-------------------');
      } else {
        print('----------------------No image selected.--------------------------------');
      }
    });
  }

  Future uploadPic() async{
    print('------------------upload function called===============');
    Reference storageReference = FirebaseStorage.instance.ref().child('profiles/${Path.basename(_image.toString())}');
    UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('---------------File Uploaded-------------------------------');

    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        newURL = fileURL.toString();
        print(newURL);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return _isLoading?Loading():Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Edit profile',
          style: TextStyle(fontFamily: 'OpenSans',color: Colors.white),
        ),
        //elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            //color: Colors.blueAccent,
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
                                color: Colors.white,
                                offset: Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(profileImage,)
                          ),
                      ),
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
                            color: Colors.blueAccent,
                          ),
                          child: GestureDetector(
                            onTap: (){
                              getImage().then((value) => uploadPic());
                              print('edit button-------------------------------------');
                            },
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
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: userSnap.docs[0].data['fullName'].toString(),
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
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
                    labelStyle: TextStyle(color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: (userSnap.docs[0].data['location'] != null)?userSnap.docs[0].data['location'].toString():'',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
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
                  Expanded( 
                    child: Container(
                      height: height * 0.070,
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        padding: EdgeInsets.all(0.0),
                        child: Ink(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Container(
                            constraints:
                            BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                            alignment: Alignment.center,
                            child: Text(
                              "Cancel",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: height * 0.070,
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          _updateDetails();
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        padding: EdgeInsets.all(0.0),
                        child: Ink(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Container(
                            constraints:
                            BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                            alignment: Alignment.center,
                            child: Text(
                              "Save",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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