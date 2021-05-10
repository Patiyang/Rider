import 'dart:io';

import 'package:delivery_boy/services/userServices.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customButton.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:delivery_boy/widgets&helpers/widgets/loading.dart';
import 'package:delivery_boy/widgets&helpers/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:delivery_boy/constant/constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebaseStorage;

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String profilePicture = '';
  String imageUrl = '';
  PickedFile imageToUpload;
  String vehicleType = '';
  // String phone = '123456789';
  // String email = 'test@abc.com';
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = new TextEditingController();
  UserServices userServices = new UserServices();
  FirebaseAuth _auth = FirebaseAuth.instance;

  ImagePicker _picker = new ImagePicker();
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  bool loading = false;
  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: blackColor),
          onPressed: () {
            Navigator.of(context).pop(phoneNumberController.text);
          },
        ),
        // actions: <Widget>[
        //   InkWell(
        //     onTap: () {
        //     },
        //     child: Container(
        //       height: 20,
        //       width: 70,
        //       padding: EdgeInsets.symmetric(horizontal: 8),
        //       decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.all(Radius.circular(20))),
        //       margin: EdgeInsets.all(8),
        //       alignment: Alignment.center,
        //       child: CustomText(text: 'Save', size: 16, fontWeight: FontWeight.w400, color: whiteColor),
        //     ),
        //   ),
        // ],
      ),
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              primary: false,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => _selectOptionBottomSheet(),
                      child: CircleAvatar(radius: 60, child: userImage()),
                    ),
                    LoginTextField(
                      validator: (v) {
                        if (v.isEmpty) return 'email cannot be empty';
                        Pattern pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regex = new RegExp(pattern);
                        if (!regex.hasMatch(v)) return 'Please use a valid email format without spaces';
                      },
                      radius: 5,
                      controller: emailAddressController,
                      hint: 'Edit email address',
                    ),
                    LoginTextField(
                      iconOne: Container(
                          alignment: Alignment.center,
                          height: 20,
                          width: 30,
                          child: CustomText(
                            text: '+234',
                            textAlign: TextAlign.center,
                            size: 16,
                          )),
                      validator: (v) {
                        if (v.isEmpty) return 'PhoneNumber cannot be empty';
                      },
                      radius: 5,
                      controller: phoneNumberController,
                      hint: 'Update your Phone Number',
                    ),
                    LoginTextField(
                      validator: (v) {
                        if (v.isEmpty) return 'First name cannot be empty';
                      },
                      radius: 5,
                      controller: firstNameController,
                      hint: 'First Name',
                    ),
                    LoginTextField(
                      validator: (v) {
                        if (v.isEmpty) return 'Last name cannot be empty';
                      },
                      radius: 5,
                      controller: lastNameController,
                      hint: 'Last Name',
                    ),
                    SizedBox(height: 20),
                    CustomFlatButton(
                      radius: 20,
                      text: 'Update Profile',
                      callback: () => updateData(),
                    )
                  ],
                ),
              ),
            ),
            Visibility(
                visible: loading == true,
                child: Loading(
                  text: 'Saving your information',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ))
          ],
        ),
      ),
    );
  }

  // Bottom Sheet for Select Options (Camera or Gallery) Start Here
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

  getCurrentUserDetails() async {
    await userServices.getUserById(_auth.currentUser.uid).then((value) {
      print(value.profilePicture);
      setState(() {
        vehicleType = value.vehicleType ?? '';
        profilePicture = value.profilePicture;
        phoneNumberController.text = value.phoneNumber;
        emailAddressController.text = value.email;
        firstNameController.text = value.firstName;
        lastNameController.text = value.lastName;
      });
    });
  }

  userImage() {
    return ClipOval(
      child: imageToUpload == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image),
                SizedBox(
                  height: 10,
                ),
                CustomText(
                  text: 'Update Profile Picture',
                  color: whiteColor,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  size: 14,
                  fontWeight: FontWeight.w400,
                ),
              ],
            )
          : Image.file(File(imageToUpload.path), fit: BoxFit.cover, height: 120, width: 120),
    );
  }

  selectProfileImage(Future<PickedFile> pickImage) async {
    PickedFile selectedProfileImage = await pickImage;
    setState(() {
      imageToUpload = selectedProfileImage;
    });
  }

  updateData() async {
    if (formKey.currentState.validate()) {
      setState(() {
        loading = true;
      });
      if (imageToUpload != null) {
        String imageName = imageToUpload.path + DateTime.now().microsecondsSinceEpoch.toString();
        firebaseStorage.TaskSnapshot snapshot =
            await firebaseStorage.FirebaseStorage.instance.ref().child('ProfilePictures/$imageName').putFile(File(imageToUpload.path)); //path to the image
        imageUrl = await snapshot.ref.getDownloadURL();
        await userServices
            .updateUser(
                _auth.currentUser.uid, emailAddressController.text, phoneNumberController.text, firstNameController.text, lastNameController.text, imageUrl)
            .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: CustomText(
                  text: 'Data Updated Successfully',
                  textAlign: TextAlign.center,
                  color: Colors.green,
                ))));
      } else {
        // print(profilePicture);

        await userServices
            .updateUser(_auth.currentUser.uid, emailAddressController.text, phoneNumberController.text, firstNameController.text, lastNameController.text,
                profilePicture)
            .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: CustomText(
                  text: 'Data Updated Successfully',
                  textAlign: TextAlign.center,
                  color: Colors.green,
                ))));
      }

      setState(() {
        loading = false;
      });
    }
  }
  // Bottom Sheet for Select Options (Camera or Gallery) Ends Here
}
