import 'dart:io';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:delivery_boy/models/userModel.dart';
import 'package:delivery_boy/views/home.dart';
import 'package:delivery_boy/views/login_signup/passwordReset.dart';
import 'package:delivery_boy/views/login_signup/register.dart';
import 'package:delivery_boy/services/userServices.dart';
import 'package:delivery_boy/widgets&helpers/helpers/changeScreen.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:delivery_boy/widgets&helpers/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/views/login_signup/otp_screen.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');
  UserServices userServices = new UserServices();
  List<UserModel> drivers = [];
  List<String> phoneNumbers = [];
  List<String> emailAddresses = [];
  String smssent, verificationId;
  final phoneController = new TextEditingController();
  final key = new GlobalKey<FormState>();
  bool loading = false;
  String phoneNumber = '';
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  // String phoneIsoCode;
  DateTime currentBackPressTime;
  @override
  void initState() {
    getUserList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return SafeArea(
        maintainBottomViewPadding: true,
        child: Scaffold(
          backgroundColor: scaffoldBgColor,
          body: WillPopScope(
            child: Padding(
              padding: EdgeInsets.all(fixPadding),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  primary: false,
                  child: Form(
                    key: key,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(HelperClass.splashImage, width: 200.0, height: 130, fit: BoxFit.fill),
                          // SizedBox(height: 20),
                          // Text( style: greyHeadingStyle),
                          // CustomText(text: 'Signin with Phone Number', size: 16, letterSpacing: .2, fontWeight: FontWeight.w600),
                          // SizedBox(height: 10),
                          // Row(
                          //   children: [
                          //     GestureDetector(
                          //       onTap: _openCountryPickerDialog,
                          //       child: Container(
                          //         margin: EdgeInsets.only(left: 8),
                          //         padding: EdgeInsets.all(8),
                          //         decoration: BoxDecoration(
                          //             color: greyColor[200], border: Border.all(color: whiteColor), borderRadius: BorderRadius.all(Radius.circular(25.7))),
                          //         width: 70,
                          //         height: 40,
                          //         child: Center(
                          //           child: _selectedCountry(
                          //             CountryPickerUtils.getCountryByIsoCode(_selectedDialogCountry.isoCode),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       width: 10,
                          //     ),
                          //     Expanded(
                          //       child: CustomRegisterTextField(
                          //         textInputType: TextInputType.numberWithOptions(),
                          //         readOnly: loading == true ? true : false,
                          //         fillColor: whiteColor,
                          //         controller: phoneController,
                          //         text: 'Phone',
                          //         validator: (v) {
                          //           if (v.isEmpty) return 'Mobile number cannot be empty';
                          //           if (!phoneNumbers.contains(phoneController.text)) return 'Phone Number is not yet registered';

                          //           return null;
                          //         },
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          CustomRegisterTextField(
                            readOnly: loading == true ? true : false,
                            controller: emailController,
                            prefixIcon: Icon(Icons.email),
                            validator: (v) {
                              if (!emailAddresses.contains(emailController.text)) return 'This email is not registered';
                              if (v.isEmpty) return 'The email address cannot be empty';
                              Pattern pattern =
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                              RegExp regex = new RegExp(pattern);
                              if (!regex.hasMatch(v)) return 'Please make sure your email address format is valid';
                            },
                            text: 'Email',
                          ),
                    
                          CustomRegisterTextField(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                icon: obscurePassword == true ? Icon(Icons.visibility): Icon(Icons.visibility_off)),
                            obscure: obscurePassword,
                            text: 'Password(Not less than 6 characters)',
                            controller: passwordController,
                            validator: (v) {
                              if (v.isEmpty) return 'the password cannot be empty';
                              if (v.length < 6) return 'this password is to short';
                            },
                          ),
                          //   Row(
                          //     children: <Widget>[
                          //       Container(
                          //         width: 86,
                          //         child: ListTile(
                          //           onTap: _openCountryPickerDialog,
                          //           title: _selectedCountry(
                          //             CountryPickerUtils.getCountryByIsoCode(_selectedDialogCountry.isoCode),
                          //           ),
                          //         ),
                          //       ),
                          //       Expanded(
                          //         child: TextFormField(
                          //           controller: phoneController,
                          //           validator: (v) {
                          //             if (v.isEmpty) return 'the Phone Number cannot be empty';
                          //             if (!phoneNumbers.contains(phoneController.text)) return 'Phone Number is not registered';
                          //           },
                          //           autofocus: false,
                          //           style: TextStyle(fontSize: 15),
                          //           keyboardType: TextInputType.number,
                          //           decoration: InputDecoration(
                          //             labelText: 'Mobile Number',
                          //             hintStyle: TextStyle(color: greyColor[500]),
                          //             border: InputBorder.none,
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3),
                            child: Stack(
                              children: [
                                MaterialButton(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                  onPressed: () => loginUser(),
                                  color: primaryColor,
                                  // minWidth: 200,
                                  child: loading == true
                                      ? Container(
                                          width: 200,
                                          child: SpinKitCircle(
                                            color: whiteColor,
                                            size: 20,
                                          ))
                                      : Container(
                                          width: 200,
                                          child: CustomText(
                                            textAlign: TextAlign.center,
                                            text: 'LOG IN',
                                            fontWeight: FontWeight.bold,
                                            color: whiteColor,
                                          ),
                                        ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: ()async{
                                       final reset = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => PasswordReset()));
                        if(reset!=null){
                          if (reset == true) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: CustomText(
                            text: 'Please check your email to reset your password',
                            color: Colors.greenAccent[700],
                            textAlign: TextAlign.center,
                          )));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: CustomText(
                            text: 'Sorry, we\'re unable to process your request',
                            color: Colors.red,
                            textAlign: TextAlign.center,
                          )));
                        }
                        }
                        

                        print(reset);
                            },
                            child: CustomText(text: 'FORGOT PASSWORD', letterSpacing: .3, fontWeight: FontWeight.bold,size: 19)),
                          SizedBox(height: 10),
                          CartItemRich(
                            lightFont: 'Don\'t have an account? ',
                            boldFont: 'Sign Up',
                            callback: () => changeScreenReplacement(context, Register()),
                            lightFontSize: 13,
                            boldFontSize: 17,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            onWillPop: () async {
              bool backStatus = onWillPop();
              if (backStatus) {
                exit(0);
              }
              return false;
            },
          ),
        ),
      );
    } else {
      return Home();
    }
  }

  Widget _selectedCountry(Country country) => Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: CountryPickerUtils.getDefaultFlagImage(country),
                height: 20,
                width: 20,
              ),
              SizedBox(
                width: 6,
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
              )
            ],
          ),
        ),
      );

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => CountryPickerDialog(
            searchCursorColor: Theme.of(context).primaryColor,
            searchInputDecoration: InputDecoration(hintText: 'Search...'),
            isSearchable: true,
            title: Text(
              'Select your phone code',
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).textTheme.headline6.color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            onValuePicked: (Country country) => setState(
                  () => _selectedDialogCountry = country,
                ),
            itemBuilder: _buildDialogItem),
      );

  Widget _buildDialogItem(Country country) => Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              getCountryString(country.name),
            ),
          ),
          Container(
            child: Text(
              "+${country.phoneCode}",
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );

  String getCountryString(String str) {
    var newString = '';
    var isFirstdot = false;
    for (var i = 0; i < str.length; i++) {
      if (isFirstdot == false) {
        if (str[i] != ',') {
          newString = newString + str[i];
        } else {
          isFirstdot = true;
        }
      }
    }
    return newString;
  }

  onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: 'Press Back Once Again to Exit.',
        backgroundColor: Colors.black,
        textColor: whiteColor,
      );
      return false;
    } else {
      return true;
    }
  }

  Future getUserList() async {
    drivers = await userServices.getAllDrivers();
    setState(() {});
    for (int i = 0; i < drivers.length; i++) {
      phoneNumbers.add(drivers[i].phoneNumber);
      emailAddresses.add(drivers[i].email);
      // print(drivers[i].phoneNumber);
    }
    // print(drivers);
  }

  loginUser() async {
    print(phoneNumber = '+${_selectedDialogCountry.phoneCode}${phoneController.text}');
    if (key.currentState.validate()) {
      setState(() {
        loading = true;
      });
      // setState(() {
      //   phoneNumber = '+${_selectedDialogCountry.phoneCode}${phoneController.text}';
      // });
      // await verfiyPhone().onError((error, stackTrace) => () {
      //       print(error.toString());
      //     });
      userServices.loginUser(emailController.text, passwordController.text, context).then((value) {
        setState(() {
          loading = true;
        });
      });
    }
  }

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
            phoneNumber: phoneNumber,
            verificationId: verificationId,
          ));
    };
    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential auth) {};
    final PhoneVerificationFailed verifyFailed = (FirebaseAuthException e) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Login()));
      Fluttertoast.showToast(msg: 'ERROR ENCOUTERED WHILE SENDING OTP'); //0700803354
      // print(widget.phoneNumber);
      print(e.toString());
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 45),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verifyFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }
}
