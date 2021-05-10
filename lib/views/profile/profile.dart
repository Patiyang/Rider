import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/services/userServices.dart';
import 'package:delivery_boy/views/login_signup/login.dart';
import 'package:delivery_boy/widgets&helpers/helpers/changeScreen.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:delivery_boy/views/profile/edit_profile.dart';
import 'package:delivery_boy/views/notification.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  FirebaseAuth auth = FirebaseAuth.instance;
  UserServices userServices = new UserServices();
  String phoneNumber = '';
  String profilePicture ;
  String firstName = '';
  String lastName = '';
  @override
  void initState() {
    getCurrentUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: whiteColor,
        elevation: 0.0,
        title: Text(
          'Profile',
          style: bigHeadingStyle,
        ),
      ),
      body: ListView(
        children: <Widget>[
          InkWell(
            onTap: () async {
              var test = await Navigator.push<String>(context, PageTransition(type: PageTransitionType.rightToLeft, child: EditProfile()));
              if (test != null) {
                getCurrentUserDetails();
              } else {
                print('cdcdc');
              }
            },
            child: Container(
              width: width,
              padding: EdgeInsets.all(fixPadding),
              color: whiteColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ClipOval(
                        child: Container(
                          width: 70.0,
                          height: 70.0,
                          child: profilePicture == null ? Image.asset(HelperClass.noImage) : Image.network(profilePicture, fit: BoxFit.cover),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            //  border: Border.all(color: whiteColor),
                          ),
                        ),
                      ),
                      widthSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '$firstName $lastName',
                            style: headingStyle,
                          ),
                          heightSpace,
                          Text(
                            phoneNumber,
                            style: lightGreyStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16.0,
                    color: Colors.grey.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(fixPadding),
            padding: EdgeInsets.all(fixPadding),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  blurRadius: 1.5,
                  spreadRadius: 1.5,
                  color: Colors.grey[200],
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: Notifications()));
                  },
                  child: getTile(Icon(Icons.notifications, color: Colors.grey.withOpacity(0.6)), 'Notifications'),
                ),
                InkWell(
                  onTap: () {},
                  child: getTile(Icon(Icons.language, color: Colors.grey.withOpacity(0.6)), 'Language'),
                ),
                InkWell(
                  onTap: () {},
                  child: getTile(Icon(Icons.settings, color: Colors.grey.withOpacity(0.6)), 'Settings'),
                ),
                InkWell(
                  onTap: () {},
                  child: getTile(Icon(Icons.group_add, color: Colors.grey.withOpacity(0.6)), 'Invite Friends'),
                ),
                InkWell(
                  onTap: () {},
                  child: getTile(Icon(Icons.headset_mic, color: Colors.grey.withOpacity(0.6)), 'Support'),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(fixPadding),
            padding: EdgeInsets.all(fixPadding),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  blurRadius: 1.5,
                  spreadRadius: 1.5,
                  color: Colors.grey[200],
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () => logoutDialogue(context),
                  child: getTile(Icon(Icons.exit_to_app, color: Colors.grey.withOpacity(0.6)), 'Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  logoutDialogue(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Dialog(
          elevation: 0.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            height: 130.0,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "You sure want to logout?",
                  style: headingStyle,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: (width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Cancel',
                          style: buttonBlackTextStyle,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        auth.signOut().then((value) => changeScreenReplacement(context, Login()));
                      },
                      child: Container(
                        width: (width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Log out',
                          style: wbuttonWhiteTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  getTile(Icon icon, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 40.0,
              width: 40.0,
              alignment: Alignment.center,
              child: icon,
            ),
            widthSpace,
            Text(
              title,
              style: listItemTitleStyle,
            ),
          ],
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16.0,
          color: Colors.grey.withOpacity(0.6),
        ),
      ],
    );
  }

  getCurrentUserDetails() async {
    await userServices.getUserById(auth.currentUser.uid).then((value) {
      print(value.phoneNumber);
      setState(() {
        profilePicture = value.profilePicture;
        phoneNumber = value.phoneNumber;
        firstName = value.firstName;
        lastName = value.lastName;
      });
    });
  }
}
