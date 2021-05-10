import 'dart:async';

import 'package:delivery_boy/services/userServices.dart';
import 'package:delivery_boy/widgets&helpers/helpers/changeScreen.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/views/home.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String emailAddress;
  final String firstName;
  final String lastName;
  final String vehicleType;

  const OTPScreen({Key key, this.phoneNumber, this.verificationId, this.emailAddress, this.firstName, this.lastName, this.vehicleType}) : super(key: key);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  var appBarheight = 0.0;
  var otpController = new TextEditingController();
  bool errorEncountered = false;
  bool loading = false;
  String smssent, verificationId;

  UserServices userServices = new UserServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Container(
        padding: EdgeInsets.all(fixPadding * 2),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    child: Image.asset(
                      HelperClass.pinInput,
                      height: 170,
                      width: 150,
                      fit: BoxFit.cover,
                    )),
                SizedBox(
                  height: 10,
                ),
                PinCodeTextField(
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  // enableActiveFill: true,
                  // errorAnimationController: errorController,
                  controller: otpController,
                  validator: (v) {
                    if (v.isEmpty) {
                      return 'The OTP field cannot be empty';
                    }
                    return null;
                  },
                  onCompleted: (v) {
                    print("Completed");
                  },
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      otpController.text = value;
                    });
                  },
                  beforeTextPaste: (text) {
                    print("Allowing to paste $text");

                    return true;
                  },
                  appContext: context,
                ),
                SizedBox(height: 10),
                CartItemRich(
                  lightFont: 'Didn\'t get an OTP code? ',
                  boldFont: 'Resend',
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: fixPadding),
                  child: InkWell(
                    onTap: () => signIn(otpController.text),
                    child: Container(
                      height: 50.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35.0),
                        color: primaryColor,
                      ),
                      child: Text(
                        'Submit',
                        style: wbuttonWhiteTextStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  loadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Dialog(
          elevation: 0.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            height: 150.0,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SpinKitPulse(
                  color: primaryColor,
                  size: 50.0,
                ),
                heightSpace,
                heightSpace,
                Text('Please Wait..', style: lightGreyStyle),
              ],
            ),
          ),
        );
      },
    );
    Timer(Duration(seconds: 3), () => changeScreenReplacement(context, Home()));
  }

//
//
//
  // String smssent;
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> signIn(String smsCode) async {
    print(widget.verificationId);
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );
    FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
      widget.firstName != null
          ? await userServices.createUser(value.user.uid, widget.emailAddress, widget.firstName, widget.lastName, widget.vehicleType,
              widget.phoneNumber.substring(4, widget.phoneNumber.length), context)
          : print('Logging in');
    }).catchError((onError) {
      setState(() {
        errorEncountered = true;
      });
      print(onError.toString());
      Fluttertoast.showToast(msg: 'WRONG OTP PLEASE RETRY AGAIN!!');
      // print(auth.currentUser.uid);
    }).then((user) async {
      if (errorEncountered == false) {
        loadingDialog();
        Fluttertoast.showToast(msg: 'OTP CODE VERIFIED');
      }
    });
  }
//
//
//

  Future<void> verfiyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResent]) {
      setState(() {
        this.verificationId = verId;
        // loading = true;
      });
      print(verificationId);
      changeScreen(
          context,
          OTPScreen(
            phoneNumber: widget.phoneNumber,
            verificationId: verificationId,
          ));
    };
    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential auth) {};
    final PhoneVerificationFailed verifyFailed = (FirebaseAuthException e) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => OTPScreen()));
      Fluttertoast.showToast(msg: 'ERROR ENCOUTERED WHILE SENDING OTP'); //0700803354
      // print(widget.phoneNumber);
      print(e.toString());
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 45),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verifyFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }
}
