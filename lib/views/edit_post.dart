import 'package:blogging_app/models/blogpost.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/constansts.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';
import 'ArticlePage.dart';

class EditPost extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? blogPostId;
  final String? postImage;

  const EditPost({
    Key? key,
    this.userId,
    this.blogPostId,
    this.postImage,
    this.userName,
    this.userEmail,
  }) : super(key: key);

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  BlogPost? blogPostDetails;
  bool _isLoading = true;
  DocumentReference? blogPostRef;
  DocumentSnapshot? blogPostSnap;

  // Text fields
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _image;
  final picker = ImagePicker();
  String? newURL;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _getBlogPostDetails();
  }

  _getBlogPostDetails() async {
    try {
      blogPostDetails = await DatabaseService(uid: widget.userId)
          .getBlogPostDetails(widget.blogPostId);

      if (blogPostDetails != null) {
        blogPostRef = FirebaseFirestore.instance
            .collection('blogPosts')
            .doc(widget.blogPostId);
        blogPostSnap = await blogPostRef?.get();

        if (blogPostSnap != null && blogPostSnap!.exists) {
          _titleEditingController.text =
              blogPostSnap?.get('blogPostTitle') ?? '';
          _contentEditingController.text =
              blogPostSnap?.get('blogPostContent') ?? '';
          newURL = blogPostSnap?.get('postImage') ?? '';
        } else {
          if (mounted) { // Check if the widget is still in the tree
            print("Blog post document does not exist.");
          }
        }
      } else {
        if (mounted) {
          print("Blog post not found.");
        }
      }
    } catch (e) {
      if (mounted) {
        print('Error getting blog post details: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Save data to Firestore
  _onUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await DatabaseService(uid: widget.userId).updateBlogPost(
          widget.blogPostId,
          _titleEditingController.text,
          _contentEditingController.text,
          newURL ?? '',
        );

        // Use pushAndRemoveUntil to prevent going back to the EditPost screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => ArticlePage(
              userId: widget.userId,
              blogPostId: widget.blogPostId,
              postImage: newURL,
            ),
          ),
              (route) => false, // Remove all previous routes
        );
      } catch (e) {
        print("Error updating blog post: $e");
        setState(() {
          _isLoading = false;
        });
        // Consider showing an error message to the user
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
    if (_image == null) return;
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
        ? const Loading()
        : Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(154, 183, 211, 1.0),
        title: const Text(
          "Update Post",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
          const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          children: <Widget>[
            TextFormField(
              decoration: textInputDecoration.copyWith(
                hintText: "Blog Title",
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black87,
                    width: 2.0,
                  ),
                ),
              ),
              validator: (val) =>
              val!.isEmpty ? 'This field cannot be blank' : null,
              controller: _titleEditingController,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              maxLines: 20,
              decoration: textInputDecoration.copyWith(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black87,
                    width: 2.0,
                  ),
                ),
                hintText: "Start writing...",
              ),
              validator: (val) =>
              val!.isEmpty ? 'This field cannot be blank' : null,
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
                  'Update blog',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                onPressed: () {
                  _onUpdate();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}