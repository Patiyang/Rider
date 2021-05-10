import 'package:delivery_boy/constant/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'views/splashScreen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await _configureLocalTimeZone();
    // final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    // String initialRoute = HomePage.routeName;
    // if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    //   selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    //   initialRoute = SecondPage.routeName;
    // }
    runApp(MyApp());
  });
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Boy',
      theme: ThemeData(
        primarySwatch: primaryColor,
        primaryColor: primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Helvetica',
        iconTheme: IconThemeData(color: blackColor),
        appBarTheme: AppBarTheme(
            // backgroundColor: blue,
            centerTitle: true,
            elevation: .3,
            textTheme: TextTheme(
              headline6: TextStyle(fontSize: 17, color: blackColor),
            )),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
