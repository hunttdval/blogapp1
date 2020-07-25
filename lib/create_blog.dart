
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog/services/crud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class CreateBlog extends StatefulWidget {
  @override
  _CreateBlogState createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {

  String authorName, title, desc;

  bool _isLoading = false;

  CrudMethods crudMethods = new CrudMethods();

  ///image picker from https://pub.dev/packages/image_picker installation
  File selectedImage;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery  );

    setState(() {
      selectedImage = File(pickedFile.path);
    });
  }
///uplaoding the blog to firestore database
  uploadBlog() async {
    if(selectedImage != null){
      setState(() {
        _isLoading = true;
      });
///uploading image to firestore
      StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('blogImages')
          .child('${randomAlphaNumeric(9)}.jpg');
      final StorageUploadTask task = firebaseStorageRef.putFile(selectedImage);

      var downloadUrl = await (await task.onComplete).ref.getDownloadURL();
      print('This is url: $downloadUrl');
      Navigator.pop(context);
  }else{
      print('No image upload');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Flutter', style: TextStyle(
                fontSize: 22
            ),
            ),
            Text('Blog', style:TextStyle(fontSize: 22, color: Colors.blue))
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              uploadBlog();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.file_upload)
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
            )
          :Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10,),
            GestureDetector(
              onTap: () {
                getImage();
              },
              child: selectedImage != null ?
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                height: 150,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(
                      selectedImage,
                      fit:BoxFit.cover,
                  ),
                ),
              )
                  : Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6)
                ),
                width: MediaQuery.of(context).size.width,
                child: Icon(Icons.add_a_photo,
                color: Colors.black45,
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(hintText: 'Author Name'),
                    onChanged: (val) {
                      authorName = val;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Title'),
                    onChanged: (val) {
                      title = val;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Description'),
                    onChanged: (val) {
                      desc = val;
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
