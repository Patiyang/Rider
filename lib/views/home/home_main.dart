import 'package:delivery_boy/constant/constant.dart';
import 'package:delivery_boy/services/userServices.dart';
import 'package:delivery_boy/widgets&helpers/helpers/changeScreen.dart';
import 'package:delivery_boy/widgets&helpers/helpers/helperClasses.dart';
import 'package:delivery_boy/widgets&helpers/helpers/sharedPrefs.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customButton.dart';
import 'package:delivery_boy/widgets&helpers/widgets/customText.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uuid/uuid.dart';
import 'active_order.dart';
import 'history.dart';
import 'new_order.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeMain extends StatefulWidget {
  final String title;
  final bool isOnline;

  const HomeMain({Key key, this.title, this.isOnline}) : super(key: key);
  @override
  _HomeMainState createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> with SingleTickerProviderStateMixin {
  TabController _controller;
  int _selectedIndex = 0;
  String userNames = '';
  String profilePicture = '';
  bool online = false;
  bool verified = false;
  bool loaded;
  AndroidNotificationSound androidNotificationSound;
  List<String> title = ['New Orders', 'Active Orders', 'History'];
  List<Widget> list = [
    Tab(text: 'New Orders'),
    Tab(text: 'Active Orders'),
    Tab(text: 'History'),
  ];
  UserServices userServices = new UserServices();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  void initState() {
    getCurrentUserDetails();
    super.initState();
    _controller = TabController(length: list.length, vsync: this, initialIndex: 1);
    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
      });
      print("Selected Index: " + _controller.index.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            ClipOval(
              child: Container(
                width: 35.0,
                height: 35.0,
                child: profilePicture == '' ? Image.asset(HelperClass.noImage) : Image.network(profilePicture, fit: BoxFit.cover),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  //  border: Border.all(color: whiteColor),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            CustomText(
              text: userNames,
              color: whiteColor,
            ),
          ],
        ),
        actions: [
          Center(child: CustomText(text: 'Go online', color: whiteColor)),
          Switch(
            activeColor: Colors.greenAccent,
            value: online,
            onChanged: (status) {
              initializeOneSignal(context);
              if (verified == null || verified == false) {
                showVerificationDialog();
              } else {
                setState(() {
                  online = status;
                });
                setIsOnline(online);
              }
            },
          )
        ],
        toolbarHeight: 100,
        bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                print(_selectedIndex);
              });
            },
            controller: _controller,
            tabs: list),
      ),
      body: TabBarView(
        children: [
          NewOrder(online: online),
          ActiveOrder(online: online, loaded: loaded),
          History(),
        ],
        controller: _controller,
      ),
    );
  }

  getCurrentUserDetails() async {
    await userServices.getUserById(_auth.currentUser.uid).then((value) {
      setState(() {
        userNames = value.firstName + ' ' + value.lastName;
        profilePicture = value.profilePicture ?? '';
        verified = value.verified;
      });
    }).whenComplete(() async {
      online = await getIsOnline();
      print(online);
      setState(() {
        loaded = true;
      });
      initializeOneSignal(context);
    });
  }

  showVerificationDialog() {
    // Can we have this,  under vehicle type, but ours will be bike, van, truck, towing van,
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  width: MediaQuery.of(context).size.width,
                  // height: 200,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Image.asset(
                          HelperClass.verificationImage,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                        CustomText(
                          text:
                              'Hello $userNames, Kindly visit the closest Armotale service center to complete the registration process as one of our partners',
                          maxLines: 10,
                          size: 20,
                          fontWeight: FontWeight.w300,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: CustomFlatButton(
                        //         color: Colors.red,
                        //         icon: Icons.cancel,
                        //         radius: 30,
                        //         text: 'Cancel',
                        //         textColor: whiteColor,
                        //         fontSize: 20,
                        //         callback: () => Navigator.pop(context),
                        //         iconSize: 22,
                        //       ),
                        //     ),
                        //     SizedBox(
                        //       width: 10,
                        //     ),
                        //     Expanded(
                        //       child: CustomFlatButton(
                        //         color: Colors.green,
                        //         icon: Icons.done_all,
                        //         radius: 30,
                        //         text: 'Proceed',
                        //         textColor: whiteColor,
                        //         fontSize: 20,
                        //         callback: () async {
                        //           var docsVerified = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => AccountVerification()));
                        //           setState(() {
                        //             verified = docsVerified;
                        //           });
                        //           if (docsVerified != null) {
                        //             Navigator.pop(context);
                        //           }
                        //         },
                        //         iconSize: 22,
                        //       ),
                        //     )
                        //   ],
                        // ),
                      ],
                    ),
                  )),
            ),
          );
        });
  }

  Future initializeOneSignal(BuildContext context) async {
    if (online == true) {
      print('the user is online ${online.toString()}');
      OneSignal.shared.init(HelperClass.oneSignalAppId);
      OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
      OneSignal.shared.setExternalUserId(_auth.currentUser.uid);

      OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
        // print(notification.payload.title);
        var id = Uuid();
        String channelId = notification.payload.notificationId;
        String channelName = notification.payload.title;
        String channelDescription = notification.payload.subtitle;
        AndroidNotificationDetails androidNotificationDetails = new AndroidNotificationDetails(channelId, channelName, channelDescription);
        // showEmailDialog(androidNotificationDetails, context, notification);
      });
      OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
        print('clicked');
      });
      OneSignal.shared.setInAppMessageClickedHandler((OSInAppMessageAction action) {
        print('inapp clicked');
      });
    } else {
      OneSignal.shared.removeExternalUserId();
      print('object');
      // OneSignal.shared.
    }
  }

  Future<void> _showFullScreenNotification(AndroidNotificationDetails notification) async {
    print('object');
    try {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Turn off your screen'),
          content: const Text('to see the full-screen intent in 5 seconds, press OK and TURN '
              'OFF your screen'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await flutterLocalNotificationsPlugin.zonedSchedule(
                    0,
                    'scheduled title',
                    'scheduled body',
                    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
                    NotificationDetails(
                      android: AndroidNotificationDetails(
                        notification.channelId,
                        notification.channelName,
                        notification.channelDescription,
                        priority: Priority.high,
                        importance: Importance.high,
                        fullScreenIntent: true,
                      ),
                    ),
                    androidAllowWhileIdle: true,
                    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);

                Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }
}
