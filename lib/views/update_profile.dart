import 'dart:io';
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

  const EditProfilePage({Key? key, this.uid, this.userEmail}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  QuerySnapshot? userSnap;
  bool _isLoading = true;
  String _error = '';

  final TextEditingController _fullNameEditingController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _image;
  final ImagePicker picker = ImagePicker();

  String newURL = 'https://firebasestorage.googleapis.com/v0/b/blogging-app-e918a.appspot.com/o/profiles%2Fblank-profile-picture-973460_960_720.png?alt=media&token=bfd3784e-bfd2-44b5-93cb-0c26e3090ba4';
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  @override
  void dispose() {
    _fullNameEditingController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _updateDetails() async {
    try {
      if (_fullNameEditingController.text.trim().isNotEmpty ||
          _locationController.text.trim().isNotEmpty ||
          newURL.isNotEmpty) {
        await DatabaseService(uid: widget.uid).updateUserData(
          _fullNameEditingController.text.trim(),
          _locationController.text.trim(),
          newURL,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = 'Error Updating: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserDetails() async {
    try {
      final res = await DatabaseService(uid: widget.uid).getUserData(widget.userEmail!);

      if (res.docs.isNotEmpty) {
        setState(() {
          userSnap = res;
          _fullNameEditingController.text = (res.docs[0].data() as Map<String, dynamic>)['fullName']?.toString() ?? '';
          _locationController.text = (res.docs[0].data() as Map<String, dynamic>)['location']?.toString() ?? '';
          profileImage = (res.docs[0].data() as Map<String, dynamic>)['profileImage']?.toString() ?? newURL;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching user details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        await _uploadPic();
      }
    } catch (e) {
      setState(() {
        _error = 'Error selecting image: $e';
      });
      print('Error selecting image: $e');
    }
  }

  Future<void> _uploadPic() async {
    if (_image == null) return;

    try {
      final fileName = Path.basename(_image!.path);
      final storageReference = FirebaseStorage.instance.ref().child('profiles/$fileName');
      final uploadTask = storageReference.putFile(_image!);

      final snapshot = await uploadTask;
      final downloadURL = await snapshot.ref.getDownloadURL();

      setState(() {
        newURL = downloadURL;
        profileImage = downloadURL;
        print('Image uploaded successfully: $newURL');
      });
    } catch (error) {
      setState(() {
        _error = 'Error uploading image: $error';
        _isLoading = false;
      });
      print('Error uploading image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return _isLoading
        ? Loading()
        : Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit profile',
          style: TextStyle(fontFamily: 'OpenSans', color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
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
                            color: Theme.of(context).scaffoldBackgroundColor
                        ),
                        boxShadow: const [
                          BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.white,
                              offset: Offset(0, 10)
                          )
                        ],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            profileImage ?? newURL,
                          ),
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
                          onTap: _getImage,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: TextFormField(
                  controller: _fullNameEditingController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(bottom: 3),
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: (userSnap?.docs[0].data() as Map<String, dynamic>)['fullName']?.toString() ?? '',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  validator: (val) => val?.isEmpty == true
                      ? 'This field cannot be blank'
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(bottom: 3),
                    labelText: 'Location',
                    labelStyle: const TextStyle(color: Colors.black),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: (userSnap?.docs[0].data() as Map<String, dynamic>)['location']?.toString() ?? '',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  validator: (val) => val?.isEmpty == true
                      ? 'This field cannot be blank'
                      : null,
                ),
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: height * 0.070,
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0)
                          ),
                          padding: const EdgeInsets.all(0.0),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff374ABE),
                                  Color(0xff64B6FF)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                          child: Container(
                            constraints: const BoxConstraints(
                                maxWidth: 250.0,
                                minHeight: 50.0
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Cancel",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: height * 0.070,
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: _updateDetails,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0)
                          ),
                          padding: const EdgeInsets.all(0.0),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff374ABE),
                                  Color(0xff64B6FF)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30.0)
                          ),
                          child: Container(
                            constraints: const BoxConstraints(
                                maxWidth: 250.0,
                                minHeight: 50.0
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Save",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Text(
                _error,
                style: const TextStyle(
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