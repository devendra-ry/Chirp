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

  const EditPost({Key key, this.userId, this.blogPostId, this.postImage, this.userName, this.userEmail}) : super(key: key);
  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  BlogPost blogPostDetails = new BlogPost();
  bool _isLoading = true;
  late DocumentReference blogPostRef;
  late DocumentSnapshot blogPostSnap;

  //Text fields
  TextEditingController _titleEditingController = new TextEditingController();
  TextEditingController _contentEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _image;
  final picker = ImagePicker();
  String newURL = '';
  String? profileImage;

  @override
  void initState() {
    super.initState();
    _getBlogPostDetails();
  }

  _getBlogPostDetails() async {
    await DatabaseService(uid: widget.userId)
        .getBlogPostDetails(widget.blogPostId)
        .then((res) {
      setState(() {
        blogPostDetails = res;
        _isLoading = false;
      });
    });

    blogPostRef = FirebaseFirestore.instance.collection('blogPosts').document(widget.blogPostId);
    blogPostSnap = await blogPostRef.get();
    print(blogPostSnap.data);

    //_titleEditingController.text = blogPostSnap.documents[0].data['profileImage'].toString();
    _titleEditingController.text = blogPostDetails.blogPostTitle;
    _contentEditingController.text = blogPostDetails.blogPostContent;

    print('---------------document id '+ widget.blogPostId);
  }

  //save data to firestore
  _onUpdate() async {
    //check if entered info is correct
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      await DatabaseService(uid: widget.userId)
          .updateBlogPost(widget.blogPostId, _titleEditingController.text, _contentEditingController.text, newURL)
          .then((res) async {
        //after saving data navigate to show the BlogPost
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                ArticlePage(userId: widget.userId, blogPostId: res,postImage: newURL),
          ),
        );
        print('-------------result-------------------');
        print(res);
      });
      print("------------------------Data Updated------------------------------");
    }
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
    Reference storageReference = FirebaseStorage.instance.ref().child('blogs/${Path.basename(_image.toString())}');
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
  return _isLoading
      ? Loading()
      : Scaffold(
    appBar: AppBar(
      title: Text("Update Post"),
      elevation: 0.0,
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
        children: <Widget>[
          TextFormField(
            decoration: textInputDecoration.copyWith(
              hintText: "Blog Title",
              enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.black87, width: 2.0)),
            ),
            validator: (val) =>
            val.length < 1 ? 'This field cannot be blank' : null,
            controller: _titleEditingController,
          ),
          SizedBox(height: 20.0),
          TextFormField(
            maxLines: 20,
            decoration: textInputDecoration.copyWith(
              enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.black87, width: 2.0)),
              hintText: "Start writing...",
            ),
            validator: (val) =>
            val.length < 1 ? 'This field cannot be blank' : null,
            controller: _contentEditingController,
          ),
          SizedBox(height: 20.0),
          SizedBox(
            width: double.infinity,
            height: 50.0,
            child: ElevatedButton(
                elevation: 0.0,
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                child: Text('Upload photo',
                    style:
                    TextStyle(color: Colors.white, fontSize: 16.0)),
                onPressed: () {
                  getImage().then((value) => uploadPic());
                }),
          ),
          SizedBox(height: 20.0),
          SizedBox(
            width: double.infinity,
            height: 50.0,
            child: ElevatedButton(
                elevation: 0.0,
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                child: Text('Update blog',
                    style:
                    TextStyle(color: Colors.white, fontSize: 16.0)),
                onPressed: () {
                  //uploadPic();
                  _onUpdate();
                }),
          ),
        ],
      ),
    ),
  );
  }
}