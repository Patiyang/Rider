import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/models/userModel.dart';
import 'package:delivery_boy/services/userServices.dart';
import 'package:delivery_boy/views/login_signup/login.dart';
import 'package:delivery_boy/views/login_signup/otp_screen.dart';
import 'package:delivery_boy/widgets&helpers/helpers/changeScreen.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:delivery_boy/widgets&helpers/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

// ignore: camel_case_types
class _RegisterState extends State<Register> {
  String phoneNumber = '';
  String smssent, verificationId;
  FirebaseAuth auth = FirebaseAuth.instance;
  //String _chosenValue;
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('NG');
  String selectedVehicle;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  final firstNameController = new TextEditingController();
  final lastNameController = new TextEditingController();
  final phoneNumberController = new TextEditingController();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  final couponCodeController = new TextEditingController();
  final confirmPasswordController = new TextEditingController();

  UserServices userServices = new UserServices();
  List<UserModel> users = [];
  List<String> phoneNumbers = [];
  List<String> emailAddresses = [];
  @override
  void initState() {
    super.initState();
    getUserList();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 20),
                Image.asset(HelperClass.logo, height: 50, width: MediaQuery.of(context).size.width, fit: BoxFit.contain),
                CustomRegisterTextField(
                  readOnly: loading == true ? true : false,
                  text: 'First Name',
                  controller: firstNameController,
                  validator: (v) {
                    if (v.isEmpty) return 'First Name cannot be empty';
                  },
                ),
                CustomRegisterTextField(
                  readOnly: loading == true ? true : false,
                  text: 'Last Name',
                  controller: lastNameController,
                  validator: (v) {
                    if (v.isEmpty) return 'Last Name cannot be empty';
                  },
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _openCountryPickerDialog,
                      child: Container(
                        margin: EdgeInsets.only(left: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Color(0xffF6F6F6), borderRadius: BorderRadius.all(Radius.circular(25.7))),
                        width: 70,
                        height: 40,
                        child: Center(
                          child: _selectedCountry(
                            CountryPickerUtils.getCountryByIsoCode(_selectedDialogCountry.isoCode),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: CustomRegisterTextField(
                        readOnly: loading == true ? true : false,
                        controller: phoneNumberController,
                        text: 'Phone',
                        validator: (v) {
                          if (v.isEmpty) return 'Mobile number cannot be empty';
                          if (phoneNumbers.contains(phoneNumberController.text)) return 'Phone Number is already registered';

                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xffF6F6F6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                            hint: Text('-Select Vehicle Type-'),
                            value: selectedVehicle,
                            items: [
                              // bike, van, truck, towing van,
                              DropdownMenuItem(value: 'BIKE', child: Text('Bike')),
                              DropdownMenuItem(value: 'VAN', child: Text('Van')),
                              DropdownMenuItem(value: 'TRUCK', child: Text('Truck')),
                              DropdownMenuItem(value: 'TOWING VAN', child: Text('Towing van')),
                            ].cast<DropdownMenuItem<String>>(),
                            onChanged: (value) {
                              setState(() {
                                selectedVehicle = value;
                              });
                              print('changed to $value');
                            }),
                      )),
                ),
                CustomRegisterTextField(
                  readOnly: loading == true ? true : false,
                  controller: emailController,
                  validator: (v) {
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
                        icon: obscurePassword == true ? Icon(Icons.lock) : Icon(Icons.lock_open)),
                    obscure: obscurePassword,
                    text: 'Password(Not less than 6 characters)',
                    controller: passwordController,
                    validator: Validators.compose([
                      Validators.required('password field cannot be empty'),
                      Validators.minLength(6, 'The password must be greater than 6'),
                      Validators.patternRegExp(RegExp(r'[!@#$%^&*(),.?":{}|<>]'), 'Password must have one special character'),
                      Validators.patternRegExp(RegExp(r'[a-z]'), 'Password must have at least one lower case letter'),
                      Validators.patternRegExp(RegExp(r'[A-Z]'), 'Password must have at least one upper case letter'),
                      Validators.patternRegExp(RegExp(r'[0-9]'), 'Password must have at least one integer')
                    ])),
                CustomRegisterTextField(
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                      icon: obscureConfirmPassword == true ? Icon(Icons.lock) : Icon(Icons.lock_open)),
                  obscure: obscureConfirmPassword,
                  text: 'Confirm Password',
                  controller: confirmPasswordController,
                  validator: (v) {
                    if (passwordController.text != confirmPasswordController.text) return 'The passwords you entered do not match';
                  },
                ),
                CustomRegisterTextField(
                  readOnly: loading == true ? true : false,
                  controller: couponCodeController,
                  text: 'Referral Code (Optional)',
                ),
                Container(
                  height: height * 0.07,
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0), side: BorderSide(color: primaryColor)),
                        )),
                    onPressed: () => signInUser(context),
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
                              text: 'SIGN UP',
                              fontWeight: FontWeight.bold,
                              color: whiteColor,
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                CartItemRich(
                  lightFont: 'Already have an account? ',
                  boldFont: 'Sign In',
                  callback: () => changeScreenReplacement(context, Login()),
                  lightFontSize: 13,
                  boldFontSize: 17,
                ),
                SizedBox(
                  height: 30,
                )
                // Column(
                //   children: [],
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  signInUser(BuildContext context) async {
    // print(phoneNumber = '+${_selectedDialogCountry.phoneCode}${phoneNumberController.text}');
    // if (formKey.currentState.validate()) {
    //   setState(() {
    //     phoneNumber = '+${_selectedDialogCountry.phoneCode}${phoneNumberController.text}';
    //   });
    //   if (selectedVehicle == null) {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //         content: CustomText(
    //       text: 'YOU NEED TO SELECT A VEHICLE TYPE',
    //       color: Colors.red,
    //       textAlign: TextAlign.center,
    //     )));
    //   } else {
    //     setState(() {
    //       loading = true;
    //     });
    //     await verfiyPhone().onError((error, stackTrace) => () {
    //           print(error.toString());
    //         });
    //     setState(() {
    //       loading = false;
    //     });
    //   }
    // }
    //
    if (formKey.currentState.validate()) {
      setState(() {
        loading = true;
      });
      await userServices
          .createUser(emailController.text, firstNameController.text, lastNameController.text, selectedVehicle, phoneNumberController.text,
              passwordController.text, context)
          .then((value) {
        setState(() {
          loading = false;
        });
      });
    }
  }

  Future<void> verfiyPhone() async {
    {
      final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
        this.verificationId = verId;
      };
      final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResent]) {
        this.verificationId = verId;
        print(verificationId);
        print("Code Sent");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: phoneNumber,
                verificationId: this.verificationId,
                emailAddress: emailController.text,
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                vehicleType: selectedVehicle,
              ),
            ));
      };
      final PhoneVerificationCompleted verifiedSuccess = (AuthCredential auth) {};
      final PhoneVerificationFailed verifyFailed = (FirebaseAuthException e) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => Register()));
        Fluttertoast.showToast(msg: 'ERROR ENCOUTERED WHILE SENDING OTP');
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

  Widget _selectedCountry(Country country) => Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2, left: 4),
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

  Future getUserList() async {
    users = await userServices.getAllDrivers();
    setState(() {});
    for (int i = 0; i < users.length; i++) {
      phoneNumbers.add(users[i].phoneNumber);
      emailAddresses.add(users[i].email);
    }
    // print(phoneNumbers);
  }
}
