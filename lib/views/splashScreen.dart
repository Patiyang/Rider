import 'dart:async';

import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/views/login_signup/login.dart';
import 'package:delivery_boy/widgets&helpers/helpers/changeScreen.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () => changeScreenReplacement(context, Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Padding(
        padding: EdgeInsets.all(fixPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                HelperClass.splashImage,
                width: 200.0,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(height: 50),
              SpinKitPulse(
                color: primaryColor,
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
