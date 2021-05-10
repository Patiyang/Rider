import 'dart:io';

import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/services/userServices.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customButton.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:delivery_boy/widgets&helpers/widgets/loading.dart';
import 'package:delivery_boy/widgets&helpers/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebaseStorage;

class AccountVerification extends StatefulWidget {
  @override
  _AccountVerificationState createState() => _AccountVerificationState();
}

class _AccountVerificationState extends State<AccountVerification> {
  UserServices userServices = new UserServices();
  FirebaseAuth _auth = FirebaseAuth.instance;
  ImagePicker _picker = new ImagePicker();
  String userNames = '';
  String gender = '';
  String identification = '';
  String identityPicture = '';
  String imageUrl = '';
  PickedFile imageToUpload;
  final formKey = GlobalKey<FormState>();
  final identityController = new TextEditingController();
  List<String> identificationDocs = ['National Id', 'Passport'];
  List<String> genders = ['Male', 'Female'];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: CustomText(
          text: 'Account Verification',
          color: whiteColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    CustomText(
                      text:
                          'Hello $userNames It\'s nice to have you as one of ours. Just a few more steps and you\'ll enjoy the full previlages of the Armotale community',
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.bold,
                      color: greyColor,
                      size: 17,
                      letterSpacing: .2,
                      maxLines: 4,
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _selectOptionBottomSheet(),
                      child: Container(
                          decoration: BoxDecoration(color: greyColor[300], borderRadius: BorderRadius.all(Radius.circular(15))),
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: userImage()),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: greyColor[300]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: DropdownButtonHideUnderline(
                              child: FittedBox(
                                // fit: BoxFit.scaleDown,
                                child: DropdownButton(
                                    icon: Icon(Icons.arrow_drop_down, color: blackColor),
                                    style: TextStyle(color: Colors.white),
                                    hint: CustomText(
                                      text: 'Identification Doc..',
                                    ),
                                    value: identification.isNotEmpty ? identification : null,
                                    onChanged: (val) {
                                      setState(() {
                                        identification = val;
                                      });
                                    },
                                    items: identificationDocs
                                        .map(
                                          (e) => DropdownMenuItem(
                                            child: CustomText(text: e, size: 16),
                                            value: e,
                                          ),
                                        )
                                        .toList()),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            child: LoginTextField(
                          validator: (v) {
                            if (v.isEmpty) {
                              return identification == identificationDocs[0] || identification == ''
                                  ? 'Your National Id Number cannot be empty'
                                  : 'Your Passport Number cannot be empty';
                            }
                          },
                          controller: identityController,
                          hint: identification == identificationDocs[0] || identification == '' ? 'National Id Number' : 'Passport Number',
                          textInputType: TextInputType.numberWithOptions(),
                        ))
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: greyColor[300]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: DropdownButtonHideUnderline(
                          child: FittedBox(
                            // fit: BoxFit.scaleDown,
                            child: DropdownButton(
                                icon: Icon(Icons.arrow_drop_down, color: blackColor),
                                style: TextStyle(color: Colors.white),
                                hint: CustomText(
                                  text: 'Choose a gender',
                                ),
                                value: gender.isNotEmpty ? gender : null,
                                onChanged: (val) {
                                  setState(() {
                                    gender = val;
                                  });
                                },
                                items: genders
                                    .map(
                                      (e) => DropdownMenuItem(
                                        child: CustomText(text: e, size: 16),
                                        value: e,
                                      ),
                                    )
                                    .toList()),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomFlatButton(
                      // color: Colors.green,
                      icon: Icons.send,
                      radius: 30,
                      text: 'Upload Data',
                      textColor: whiteColor,
                      fontSize: 20,
                      callback: () async {
                        updateData();
                      },
                      iconSize: 22,
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
                visible: loading == true,
                child: Loading(
                  text: 'Uploading your credentials',
                ))
          ],
        ),
      ),
    );
  }

  getCurrentUserDetails() async {
    await userServices.getUserById(_auth.currentUser.uid).then((value) {
      print(value.firstName);
      setState(() {
        userNames = value.firstName + ' ' + value.lastName;
      });
    });
  }

  userImage() {
    return imageToUpload == null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image,
                size: 35,
              ),
              SizedBox(
                height: 10,
              ),
              CustomText(
                text: 'Update Profile Picture',
                color: blackColor,
                maxLines: 2,
                textAlign: TextAlign.center,
                size: 22,
                fontWeight: FontWeight.w400,
              ),
            ],
          )
        : Image.file(File(imageToUpload.path), fit: BoxFit.cover);
  }

  selectProfileImage(Future<PickedFile> pickImage) async {
    PickedFile selectedUploadImage = await pickImage;
    setState(() {
      imageToUpload = selectedUploadImage;
    });
  }

  updateData() async {
    if (gender != '' && identification != '') {
      print(gender);
      if (formKey.currentState.validate()) {
        setState(() {
          loading = true;
        });
        if (imageToUpload != null) {
          String imageName = _auth.currentUser.uid + DateTime.now().microsecondsSinceEpoch.toString();
          firebaseStorage.TaskSnapshot snapshot =
              await firebaseStorage.FirebaseStorage.instance.ref().child('IdentityPictures/$imageName').putFile(File(imageToUpload.path)); //path to the image
          imageUrl = await snapshot.ref.getDownloadURL();
          await userServices.verifyUser(identification, identityController.text, imageUrl, gender, context);
        } else {
          Fluttertoast.showToast(msg: 'Your identity Inage cannot be emptu');
        }
        setState(() {
          loading = false;
        });
      }
    } else {
      Fluttertoast.showToast(msg: 'GENDER AND/OR IDENTITY TYPE IS NOT CHOSEN');
    }
  }

  void _selectOptionBottomSheet() {
    double width = MediaQuery.of(context).size.width;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: whiteColor,
            child: new Wrap(
              children: <Widget>[
                Container(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: width,
                          padding: EdgeInsets.all(10.0),
                          child: Text('Choose Option', textAlign: TextAlign.center, style: headingStyle),
                        ),
                        InkWell(
                          onTap: () {
                            selectProfileImage(_picker.getImage(source: ImageSource.camera));
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: width,
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.camera_alt, color: Colors.black.withOpacity(0.7), size: 18.0),
                                SizedBox(width: 10.0),
                                Text('Camera', style: listItemTitleStyle),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            selectProfileImage(_picker.getImage(source: ImageSource.gallery));
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: width,
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.photo_album, color: Colors.black.withOpacity(0.7), size: 18.0),
                                SizedBox(width: 10.0),
                                Text('Upload from Gallery', style: listItemTitleStyle),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}
