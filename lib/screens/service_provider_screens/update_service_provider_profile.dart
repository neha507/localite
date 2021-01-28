import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localite/constants.dart';
import 'package:localite/models/custom_user.dart';
import 'package:localite/models/service_provider_data.dart';
import 'package:localite/models/user_data.dart';
import 'package:localite/services/database.dart';
import 'package:localite/widgets/def_profile_pic.dart';

class UpdateSPProfile extends StatefulWidget {
  @override
  _UpdateSPProfileState createState() => _UpdateSPProfileState();
}

class _UpdateSPProfileState extends State<UpdateSPProfile> {

  ServiceProviderData currentSP=GlobalServiceProviderDetail.spData;
  File _imageFile;
  String name;
  String contact;
  String photoUrl,address;

  _getImage(BuildContext context, ImageSource source) async {
    final image = await ImagePicker.pickImage(source: source, maxWidth: 400.0);
    setState(() {
      _imageFile = image;
    });
    await uploadPic(context);
    Navigator.pop(context);
  }

  uploadPic(BuildContext context) async {
    String fileName = _imageFile.path;
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
      FirebaseFirestore.instance
          .collection(currentSP.service)
          .doc(currentSP.uid)
          .update({
        'photoUrl': newImageDownloadUrl,
      });
    });
  }

  // user can choose camera as well as gallery to upload their profile picture
  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            width: 300.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Pick an Image",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  child: Text(
                    "Use Camera",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  onPressed: () {
                    _getImage(context, ImageSource.camera);
                  },
                ),
                SizedBox(
                  height: 5.0,
                ),
                FlatButton(
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                  child: Text(
                    "From Gallery",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService().getSPProfile(currentSP.uid,currentSP.service),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            photoUrl = snapshot.data.data()['photoUrl'].toString();
            name = snapshot.data.data()['name'].toString();
            contact = snapshot.data.data()['contact'].toString();
            address = snapshot.data.data()['address'].toString();
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 100.0,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: getDefaultProfilePic(photoUrl, name, 40),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 50.0,
                        ),
                        RaisedButton(
                          onPressed: () => _openImagePicker(context),
                          child: Text('Upload New Image'),
                          elevation: 4,
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        RaisedButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection(currentSP.service)
                                .doc(currentSP.uid)
                                .update({
                              'photoUrl': null,
                            });
                          },
                          child: Text('Delete Image'),
                          elevation: 4,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    SizedBox(
                      width: 50.0,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: TextFormField(
                        initialValue: name,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          name = val;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: TextFormField(
                        initialValue: contact,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          contact = val;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: TextFormField(
                        initialValue: address,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          address = val;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    RaisedButton(
                        child: Text('Done'),
                        elevation: 4,
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection(currentSP.service)
                              .doc(currentSP.uid)
                              .update({
                            'name': name,
                            'contact': contact,
                            'address': address,
                          });
                          Navigator.pop(context);
                        })
                  ],
                ),
              ),
            );
          } else
            return Container();
        });
  }
}
