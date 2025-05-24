import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;

import 'ArticlePage.dart';

class CreateBlogPage extends StatefulWidget {
  //variables
  final String? uid;
  final String? userName;
  final String? userEmail;

  const CreateBlogPage({Key? key, this.uid, this.userName, this.userEmail})
      : super(key: key);

  @override
  _CreateBlogPageState createState() => _CreateBlogPageState();
}

class _CreateBlogPageState extends State<CreateBlogPage> {
  //Text fields
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();
  final TextEditingController _categoryEditingController = TextEditingController();

  //form
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  File? _image;
  final picker = ImagePicker();
  String newURL =
      'https://t4.ftcdn.net/jpg/00/89/55/15/240_F_89551596_LdHAZRwz3i4EM4J0NHNHy2hEUYDfXc0j.jpg';
  String? profileImage;

  //save data to firestore
  _onPublish() async {
    //check if entered info is correct
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? blogPostId = await DatabaseService(uid: widget.uid).saveBlogPost(
          title: _titleEditingController.text,
          author: widget.userName!,
          authorEmail: widget.userEmail!,
          content: _contentEditingController.text,
          url: newURL,
          category: _categoryEditingController.text,
        );

        // Navigate to ArticlePage and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => ArticlePage(
              userId: widget.uid,
              blogPostId: blogPostId!,
              postImage: newURL,
            ),
          ),
              (route) => false, // Remove all previous routes
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Error saving blog post: $e");
        // Show an error message to the user
      }
    }
  }

  Future getImage() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('Image Selected');
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadPic() async {
    print('upload function called');
    if (_image == null) {
      print('No image to upload');
      return;
    }
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('blogs/${Path.basename(_image!.path)}');
    UploadTask uploadTask = storageReference.putFile(_image!);
    await uploadTask.whenComplete(() {});
    print('File Uploaded');

    await storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        newURL = fileURL;
        print(newURL);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Create a Post",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0.0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
          const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                hintText: "Blog title",
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(),
                ),
              ),
              validator: (val) => val!.isEmpty
                  ? 'This field cannot be blank'
                  : null,
              controller: _titleEditingController,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              decoration: InputDecoration(
                hintText: "Category",
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(),
                ),
              ),
              validator: (val) => val!.isEmpty
                  ? 'This field cannot be blank'
                  : null,
              controller: _categoryEditingController,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              maxLines: 20,
              decoration: InputDecoration(
                hintText: "Start writing...",
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(),
                ),
              ),
              validator: (val) => val!.isEmpty
                  ? 'This field cannot be blank'
                  : null,
              controller: _contentEditingController,
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Upload photo',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                onPressed: () {
                  getImage().then((value) => uploadPic());
                },
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Publish',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                onPressed: () {
                  _onPublish();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}