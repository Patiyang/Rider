import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_boy/models/userModel.dart';
import 'package:delivery_boy/services/emailService.dart';
import 'package:delivery_boy/views/home.dart';
import 'package:delivery_boy/widgets&helpers/helpers/changeScreen.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserServices {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  EmailService _emailService = EmailService();
  Future<bool> createUser(
      String email, String firstName, String lastName, String vehicleType, String phoneNumber, String password, BuildContext context) async {
    try {
      await auth.createUserWithEmailAndPassword(email: email, password: password).then((value) {
        if (value != null) {
          _firestore.collection(UserModel.users).doc(auth.currentUser.uid).set(
            {
              UserModel.EMAIL: email,
              UserModel.PHONENUMBER: phoneNumber,
              UserModel.FIRSTNAME: firstName,
              UserModel.LASTNAME: lastName,
              UserModel.VEHICLETYPE: vehicleType,
              UserModel.UID: auth.currentUser.uid,
              UserModel.PASSWORD: password
            },
          );
          _emailService.sendWelcomeEmail(firstName + ' ' + lastName, email);
        }
      });
      changeScreenReplacement(context, Home());
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString().replaceAll('[firebase_auth/email-already-in-use] ', ''));
      print(e.toString());
      return false;
    }
  }

  Future<bool> loginUser(String emailAddress, String password, BuildContext context) async {
    // bool success = false;
    try {
      await auth.signInWithEmailAndPassword(email: emailAddress, password: password);
      changeScreenReplacement(context, Home());
      Fluttertoast.showToast(msg: 'Login Success');
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Invalid email or password');
      print(e.toString());
      return false;
    }
  }

  Future updateUser(String uid, String email, String phoneNumber, String firstName, String lastName, String profilePicture) async {
    try {
      await _firestore.collection(UserModel.users).doc(uid).update(
        {
          UserModel.EMAIL: email,
          UserModel.PHONENUMBER: phoneNumber,
          UserModel.FIRSTNAME: firstName,
          UserModel.LASTNAME: lastName,
          UserModel.PROFILEPICTURE: profilePicture,
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future verifyUser(String identificationType, String identificationNumber, String identificationPic, String gender, BuildContext context) async {
    try {
      await _firestore.collection(UserModel.users).doc(auth.currentUser.uid).update(
        {
          UserModel.VERIFIED: true,
          UserModel.IDENTIFICATIONUMBER: identificationNumber,
          UserModel.IDPHOTO: identificationPic,
          UserModel.GENDER: gender,
          UserModel.IDENTIFICATIONTYPE: identificationType,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: CustomText(
        text: '',
        textAlign: TextAlign.center,
        color: Colors.green,
      )));
      Navigator.of(context).pop(true);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<UserModel> getUserById(String id) => _firestore.collection(UserModel.users).doc(id).get().then((doc) {
        return UserModel.fromSnapshot(doc);
      });

  Future<UserModel> getCustomerById(String id) => _firestore.collection('users').doc(id).get().then((doc) {
        return UserModel.fromSnapshot(doc);
      });

  Future<List<UserModel>> getAllDrivers() async {
    List<UserModel> users = [];
    try {
      await _firestore.collection(UserModel.users).get().then((doc) {
        for (DocumentSnapshot user in doc.docs) {
          users.add(UserModel.fromSnapshot(user));
        }
      });
    } catch (e) {
      print(e.toString());
    }
    return users;
  }

  Future resetPassword(String email, BuildContext context) async {
    try {
      Navigator.of(context).pop(true);
      return auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      Navigator.of(context).pop(true);
      print(e.toString());
    }
  }
}
